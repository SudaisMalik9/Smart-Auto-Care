
from django.conf import settings
from django.core.exceptions import ValidationError
from django.db import models
from django.db.models import Q


class Workshop(models.Model):
    owner = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.PROTECT,
        related_name="workshops",
        limit_choices_to={"role": "WORKSHOP_OWNER"},
    )
    name = models.CharField(max_length=150)
    description = models.TextField(blank=True)
    email = models.EmailField(blank=True)
    phone = models.CharField(max_length=30, blank=True)
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ["name"]

    def __str__(self):
        return self.name


class WorkshopBranch(models.Model):
    workshop = models.ForeignKey(
        Workshop,
        on_delete=models.CASCADE,
        related_name="branches",
    )
    name = models.CharField(max_length=150)
    address = models.TextField()
    city = models.CharField(max_length=100)
    phone = models.CharField(max_length=30, blank=True)
    email = models.EmailField(blank=True)
    is_primary = models.BooleanField(default=False)
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ["workshop__name", "name"]
        constraints = [
            models.UniqueConstraint(
                fields=["workshop", "name"],
                name="unique_branch_name_per_workshop",
            ),
            models.UniqueConstraint(
                fields=["workshop"],
                condition=Q(is_primary=True),
                name="one_primary_branch_per_workshop",
            ),
        ]

    def __str__(self):
        return f"{self.workshop.name} - {self.name}"


class BranchOperatingHours(models.Model):
    class Weekday(models.IntegerChoices):
        MONDAY = 0, "Monday"
        TUESDAY = 1, "Tuesday"
        WEDNESDAY = 2, "Wednesday"
        THURSDAY = 3, "Thursday"
        FRIDAY = 4, "Friday"
        SATURDAY = 5, "Saturday"
        SUNDAY = 6, "Sunday"

    branch = models.ForeignKey(
        WorkshopBranch,
        on_delete=models.CASCADE,
        related_name="operating_hours",
    )
    weekday = models.IntegerField(choices=Weekday.choices)
    is_closed = models.BooleanField(default=False)
    opening_time = models.TimeField(null=True, blank=True)
    closing_time = models.TimeField(null=True, blank=True)

    class Meta:
        ordering = ["weekday"]
        constraints = [
            models.UniqueConstraint(
                fields=["branch", "weekday"],
                name="unique_operating_hours_per_day",
            ),
            models.CheckConstraint(
                condition=(
                    Q(
                        is_closed=True,
                        opening_time__isnull=True,
                        closing_time__isnull=True,
                    )
                    | Q(
                        is_closed=False,
                        opening_time__isnull=False,
                        closing_time__isnull=False,
                        closing_time__gt=models.F("opening_time"),
                    )
                ),
                name="valid_branch_operating_hours",
            ),
        ]

    def __str__(self):
        return f"{self.branch} - {self.get_weekday_display()}"

    def clean(self):
        super().clean()

        if self.is_closed:
            self.opening_time = None
            self.closing_time = None
        elif not self.opening_time or not self.closing_time:
            raise ValidationError(
                "Opening and closing times are required when the branch is open."
            )
        elif self.closing_time <= self.opening_time:
            raise ValidationError(
                "Closing time must be later than opening time."
            )


class WorkshopDepartment(models.Model):
    branch = models.ForeignKey(
        WorkshopBranch,
        on_delete=models.CASCADE,
        related_name="departments",
    )
    name = models.CharField(max_length=100)
    description = models.TextField(blank=True)
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ["name"]
        constraints = [
            models.UniqueConstraint(
                fields=["branch", "name"],
                name="unique_department_per_branch",
            ),
        ]

    def __str__(self):
        return f"{self.branch.name} - {self.name}"


class WorkshopService(models.Model):
    branch = models.ForeignKey(
        WorkshopBranch,
        on_delete=models.CASCADE,
        related_name="services",
    )
    department = models.ForeignKey(
        WorkshopDepartment,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name="services",
    )
    name = models.CharField(max_length=150)
    description = models.TextField(blank=True)
    price = models.DecimalField(max_digits=10, decimal_places=2)
    estimated_duration_minutes = models.PositiveIntegerField()
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ["name"]
        constraints = [
            models.UniqueConstraint(
                fields=["branch", "name"],
                name="unique_service_per_branch",
            ),
            models.CheckConstraint(
                condition=Q(price__gte=0),
                name="service_price_non_negative",
            ),
            models.CheckConstraint(
                condition=Q(estimated_duration_minutes__gt=0),
                name="service_duration_positive",
            ),
        ]

    def __str__(self):
        return f"{self.branch.name} - {self.name}"

class WorkshopOwnerApplication(models.Model):

    class Status(models.TextChoices):
        PENDING = "PENDING", "Pending"
        APPROVED = "APPROVED", "Approved"
        REJECTED = "REJECTED", "Rejected"

    applicant = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.PROTECT,
        related_name="workshop_owner_applications",
        limit_choices_to={"role": "CUSTOMER"},
    )

    business_name = models.CharField(max_length=150)
    business_email = models.EmailField()
    business_phone = models.CharField(max_length=30)
    business_address = models.TextField()
    city = models.CharField(max_length=100)
    description = models.TextField(blank=True)

    status = models.CharField(
        max_length=20,
        choices=Status.choices,
        default=Status.PENDING,
    )

    admin_note = models.TextField(blank=True)

    reviewed_by = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name="reviewed_workshop_applications",
    )

    reviewed_at = models.DateTimeField(null=True, blank=True)

    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ["-created_at"]
        constraints = [
            models.UniqueConstraint(
                fields=["applicant"],
                condition=Q(status="PENDING"),
                name="one_pending_workshop_application_per_user",
            ),
        ]

    def __str__(self):
        return f"{self.business_name} - {self.status}"
