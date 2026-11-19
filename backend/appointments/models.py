
from django.conf import settings
from django.core.exceptions import ValidationError
from django.db import models

from customers.models import CustomerProfile, CustomerVehicle
from workshops.models import WorkshopBranch, WorkshopService
from staff.models import BranchStaff


class Appointment(models.Model):

    class Status(models.TextChoices):
        PENDING = "PENDING", "Pending"
        CONFIRMED = "CONFIRMED", "Confirmed"
        ALTERNATIVE_PROPOSED = "ALTERNATIVE_PROPOSED", "Alternative Proposed"
        CUSTOMER_RESPONSE_REQUIRED = "CUSTOMER_RESPONSE_REQUIRED", "Customer Response Required"
        REJECTED = "REJECTED", "Rejected"
        CANCELLED = "CANCELLED", "Cancelled"
        IN_PROGRESS = "IN_PROGRESS", "In Progress"
        COMPLETED = "COMPLETED", "Completed"

    customer = models.ForeignKey(
        CustomerProfile,
        on_delete=models.PROTECT,
        related_name="appointments",
    )
    vehicle = models.ForeignKey(
        CustomerVehicle,
        on_delete=models.PROTECT,
        related_name="appointments",
    )
    branch = models.ForeignKey(
        WorkshopBranch,
        on_delete=models.PROTECT,
        related_name="appointments",
    )
    service = models.ForeignKey(
        WorkshopService,
        on_delete=models.PROTECT,
        related_name="appointments",
    )
    assigned_mechanic = models.ForeignKey(
        BranchStaff,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name="assigned_appointments",
        limit_choices_to={"position": "MECHANIC"},
    )

    preferred_datetime = models.DateTimeField()
    scheduled_datetime = models.DateTimeField(null=True, blank=True)

    status = models.CharField(
        max_length=35,
        choices=Status.choices,
        default=Status.PENDING,
    )

    customer_notes = models.TextField(blank=True)
    rejection_reason = models.TextField(blank=True)
    cancellation_reason = models.TextField(blank=True)

    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ["-created_at"]
        indexes = [
            models.Index(fields=["branch", "status"]),
            models.Index(fields=["customer", "status"]),
            models.Index(fields=["preferred_datetime"]),
            models.Index(fields=["assigned_mechanic", "status"]),
        ]

    def __str__(self):
        return f"Appointment #{self.pk} - {self.customer.user.username}"

    def clean(self):
        super().clean()
        errors = {}

        if self.vehicle_id and self.customer_id:
            if self.vehicle.customer_id != self.customer_id:
                errors["vehicle"] = (
                    "The selected vehicle does not belong to this customer."
                )

        if self.service_id and self.branch_id:
            if self.service.branch_id != self.branch_id:
                errors["service"] = (
                    "The selected service does not belong to this branch."
                )

        if self.assigned_mechanic_id and self.branch_id:
            if self.assigned_mechanic.branch_id != self.branch_id:
                errors["assigned_mechanic"] = (
                    "The mechanic must belong to the appointment branch."
                )
            elif self.assigned_mechanic.position != BranchStaff.Position.MECHANIC:
                errors["assigned_mechanic"] = (
                    "Only mechanics can be assigned to appointments."
                )
            elif not self.assigned_mechanic.is_active:
                errors["assigned_mechanic"] = (
                    "An inactive staff member cannot be assigned."
                )

        if errors:
            raise ValidationError(errors)


class AppointmentAlternative(models.Model):

    class ResponseStatus(models.TextChoices):
        PENDING = "PENDING", "Awaiting Customer"
        ACCEPTED = "ACCEPTED", "Accepted"
        DECLINED = "DECLINED", "Declined"
        WITHDRAWN = "WITHDRAWN", "Withdrawn"

    appointment = models.ForeignKey(
        Appointment,
        on_delete=models.CASCADE,
        related_name="alternatives",
    )
    proposed_datetime = models.DateTimeField()
    proposed_by = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.PROTECT,
        related_name="appointment_alternatives_proposed",
    )
    response_status = models.CharField(
        max_length=10,
        choices=ResponseStatus.choices,
        default=ResponseStatus.PENDING,
    )
    customer_response_note = models.TextField(blank=True)
    responded_at = models.DateTimeField(null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ["-created_at"]

    def __str__(self):
        return (
            f"Alternative for appointment "
            f"#{self.appointment_id} - {self.response_status}"
        )


class AppointmentStatusHistory(models.Model):
    appointment = models.ForeignKey(
        Appointment,
        on_delete=models.CASCADE,
        related_name="status_history",
    )
    previous_status = models.CharField(
        max_length=35,
        choices=Appointment.Status.choices,
        blank=True,
    )
    new_status = models.CharField(
        max_length=35,
        choices=Appointment.Status.choices,
    )
    changed_by = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name="appointment_status_changes",
    )
    note = models.TextField(blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ["created_at"]

    def __str__(self):
        return (
            f"Appointment #{self.appointment_id}: "
            f"{self.previous_status or 'NEW'} -> {self.new_status}"
        )
