
import uuid
from datetime import timedelta

from django.conf import settings
from django.core.exceptions import ValidationError
from django.db import models
from django.db.models import Q
from django.utils import timezone

from workshops.models import WorkshopBranch, WorkshopDepartment


def default_invitation_expiry():
    return timezone.now() + timedelta(days=7)


class MechanicSkill(models.Model):
    name = models.CharField(max_length=100, unique=True)
    description = models.TextField(blank=True)
    is_active = models.BooleanField(default=True)

    class Meta:
        ordering = ["name"]

    def __str__(self):
        return self.name


class MechanicProfile(models.Model):
    user = models.OneToOneField(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name="mechanic_profile",
        limit_choices_to={"role": "MECHANIC"},
    )
    skills = models.ManyToManyField(
        MechanicSkill,
        blank=True,
        related_name="mechanics",
    )
    experience_years = models.PositiveSmallIntegerField(default=0)
    bio = models.TextField(blank=True)
    is_available = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"Mechanic: {self.user.username}"


class BranchStaff(models.Model):
    class Position(models.TextChoices):
        MECHANIC = "MECHANIC", "Mechanic"
        RECEPTIONIST = "RECEPTIONIST", "Receptionist"
        SERVICE_ADVISOR = "SERVICE_ADVISOR", "Service Advisor"
        BRANCH_ADMIN = "BRANCH_ADMIN", "Branch Admin"

    branch = models.ForeignKey(
        WorkshopBranch,
        on_delete=models.CASCADE,
        related_name="staff_members",
    )
    user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.PROTECT,
        related_name="branch_memberships",
    )
    position = models.CharField(
        max_length=30,
        choices=Position.choices,
    )
    departments = models.ManyToManyField(
        WorkshopDepartment,
        blank=True,
        related_name="staff_members",
    )
    is_active = models.BooleanField(default=True)
    joined_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ["branch__name", "user__username"]
        constraints = [
            models.UniqueConstraint(
                fields=["branch", "user"],
                name="unique_staff_member_per_branch",
            ),
        ]

    def __str__(self):
        return f"{self.user.username} - {self.branch.name}"


class StaffWorkingHours(models.Model):
    class Weekday(models.IntegerChoices):
        MONDAY = 0, "Monday"
        TUESDAY = 1, "Tuesday"
        WEDNESDAY = 2, "Wednesday"
        THURSDAY = 3, "Thursday"
        FRIDAY = 4, "Friday"
        SATURDAY = 5, "Saturday"
        SUNDAY = 6, "Sunday"

    staff_member = models.ForeignKey(
        BranchStaff,
        on_delete=models.CASCADE,
        related_name="working_hours",
    )
    weekday = models.IntegerField(choices=Weekday.choices)
    is_day_off = models.BooleanField(default=False)
    start_time = models.TimeField(null=True, blank=True)
    end_time = models.TimeField(null=True, blank=True)

    class Meta:
        ordering = ["weekday"]
        constraints = [
            models.UniqueConstraint(
                fields=["staff_member", "weekday"],
                name="unique_staff_hours_per_day",
            ),
            models.CheckConstraint(
                condition=(
                    Q(
                        is_day_off=True,
                        start_time__isnull=True,
                        end_time__isnull=True,
                    )
                    | Q(
                        is_day_off=False,
                        start_time__isnull=False,
                        end_time__isnull=False,
                        end_time__gt=models.F("start_time"),
                    )
                ),
                name="valid_staff_working_hours",
            ),
        ]

    def __str__(self):
        return f"{self.staff_member} - {self.get_weekday_display()}"

    def clean(self):
        super().clean()

        if self.is_day_off:
            self.start_time = None
            self.end_time = None
        elif not self.start_time or not self.end_time:
            raise ValidationError(
                "Start and end times are required for a working day."
            )
        elif self.end_time <= self.start_time:
            raise ValidationError(
                "End time must be later than start time."
            )


class MechanicInvitation(models.Model):
    class Status(models.TextChoices):
        PENDING = "PENDING", "Pending"
        ACCEPTED = "ACCEPTED", "Accepted"
        EXPIRED = "EXPIRED", "Expired"
        REVOKED = "REVOKED", "Revoked"

    branch = models.ForeignKey(
        WorkshopBranch,
        on_delete=models.CASCADE,
        related_name="mechanic_invitations",
    )
    email = models.EmailField()
    invited_by = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.PROTECT,
        related_name="sent_mechanic_invitations",
    )
    token = models.UUIDField(default=uuid.uuid4, unique=True, editable=False)
    status = models.CharField(
        max_length=10,
        choices=Status.choices,
        default=Status.PENDING,
    )
    expires_at = models.DateTimeField(default=default_invitation_expiry)
    accepted_by = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name="accepted_mechanic_invitations",
    )
    accepted_at = models.DateTimeField(null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ["-created_at"]
        indexes = [
            models.Index(fields=["email", "status"]),
            models.Index(fields=["token", "status"]),
        ]

    def __str__(self):
        return f"{self.email} - {self.branch.name} ({self.status})"

    @property
    def is_valid(self):
        return (
            self.status == self.Status.PENDING
            and self.expires_at > timezone.now()
        )
