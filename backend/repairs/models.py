
import uuid

from django.conf import settings
from django.core.validators import MinValueValidator
from django.db import models
from django.utils import timezone


class RepairJob(models.Model):
    class Status(models.TextChoices):
        VEHICLE_RECEIVED = "VEHICLE_RECEIVED", "Vehicle Received"
        INSPECTION = "INSPECTION", "Inspection"
        AWAITING_CUSTOMER_APPROVAL = (
            "AWAITING_CUSTOMER_APPROVAL",
            "Awaiting Customer Approval",
        )
        AWAITING_PARTS = "AWAITING_PARTS", "Awaiting Parts"
        IN_PROGRESS = "IN_PROGRESS", "In Progress"
        QUALITY_CHECK = "QUALITY_CHECK", "Quality Check"
        COMPLETED = "COMPLETED", "Completed"
        CANCELLED = "CANCELLED", "Cancelled"

    appointment = models.OneToOneField(
        "appointments.Appointment",
        on_delete=models.PROTECT,
        related_name="repair_job",
    )
    job_number = models.UUIDField(
        default=uuid.uuid4,
        unique=True,
        editable=False,
    )
    branch = models.ForeignKey(
        "workshops.WorkshopBranch",
        on_delete=models.PROTECT,
        related_name="repair_jobs",
    )
    vehicle = models.ForeignKey(
        "customers.CustomerVehicle",
        on_delete=models.PROTECT,
        related_name="repair_jobs",
    )
    customer = models.ForeignKey(
        "customers.CustomerProfile",
        on_delete=models.PROTECT,
        related_name="repair_jobs",
    )
    assigned_mechanic = models.ForeignKey(
        "staff.BranchStaff",
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name="repair_jobs",
    )
    status = models.CharField(
        max_length=40,
        choices=Status.choices,
        default=Status.VEHICLE_RECEIVED,
    )
    received_at = models.DateTimeField(default=timezone.now)
    started_at = models.DateTimeField(null=True, blank=True)
    completed_at = models.DateTimeField(null=True, blank=True)
    customer_concern = models.TextField(blank=True)
    internal_notes = models.TextField(blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def clean(self):
        from django.core.exceptions import ValidationError

        if self.appointment_id:
            appointment = self.appointment

            if self.branch_id and self.branch_id != appointment.branch_id:
                raise ValidationError(
                    {"branch": "Branch must match the appointment branch."}
                )

            if self.vehicle_id and self.vehicle_id != appointment.vehicle_id:
                raise ValidationError(
                    {"vehicle": "Vehicle must match the appointment vehicle."}
                )

            if self.customer_id and self.customer_id != appointment.customer_id:
                raise ValidationError(
                    {"customer": "Customer must match the appointment customer."}
                )

        if self.assigned_mechanic_id:
            mechanic = self.assigned_mechanic

            if mechanic.position != "MECHANIC" or not mechanic.is_active:
                raise ValidationError(
                    {"assigned_mechanic": "Select an active mechanic."}
                )

            if self.branch_id and mechanic.branch_id != self.branch_id:
                raise ValidationError(
                    {"assigned_mechanic": "Mechanic must belong to this branch."}
                )

    def __str__(self):
        return f"Repair Job {self.job_number}"


class VehicleInspection(models.Model):
    repair_job = models.ForeignKey(
        RepairJob,
        on_delete=models.CASCADE,
        related_name="inspections",
    )
    inspected_by = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.PROTECT,
        related_name="vehicle_inspections",
    )
    findings = models.TextField()
    recommended_work = models.TextField(blank=True)
    estimated_cost = models.DecimalField(
        max_digits=12,
        decimal_places=2,
        default=0,
        validators=[MinValueValidator(0)],
    )
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"Inspection - {self.repair_job.job_number}"


class RepairTask(models.Model):
    class Status(models.TextChoices):
        PENDING = "PENDING", "Pending"
        IN_PROGRESS = "IN_PROGRESS", "In Progress"
        COMPLETED = "COMPLETED", "Completed"
        BLOCKED = "BLOCKED", "Blocked"

    repair_job = models.ForeignKey(
        RepairJob,
        on_delete=models.CASCADE,
        related_name="tasks",
    )
    title = models.CharField(max_length=200)
    description = models.TextField(blank=True)
    assigned_mechanic = models.ForeignKey(
        "staff.BranchStaff",
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name="repair_tasks",
    )
    status = models.CharField(
        max_length=20,
        choices=Status.choices,
        default=Status.PENDING,
    )
    estimated_minutes = models.PositiveIntegerField(default=0)
    completed_at = models.DateTimeField(null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    def clean(self):
        from django.core.exceptions import ValidationError

        if self.assigned_mechanic_id:
            mechanic = self.assigned_mechanic

            if mechanic.position != "MECHANIC" or not mechanic.is_active:
                raise ValidationError(
                    {"assigned_mechanic": "Select an active mechanic."}
                )

            if mechanic.branch_id != self.repair_job.branch_id:
                raise ValidationError(
                    {"assigned_mechanic": "Mechanic must belong to this branch."}
                )

    def __str__(self):
        return self.title


class RepairApproval(models.Model):
    class Decision(models.TextChoices):
        PENDING = "PENDING", "Pending"
        APPROVED = "APPROVED", "Approved"
        DECLINED = "DECLINED", "Declined"

    repair_job = models.ForeignKey(
        RepairJob,
        on_delete=models.CASCADE,
        related_name="approvals",
    )
    inspection = models.ForeignKey(
        VehicleInspection,
        on_delete=models.PROTECT,
        related_name="approvals",
    )
    amount = models.DecimalField(
        max_digits=12,
        decimal_places=2,
        validators=[MinValueValidator(0)],
    )
    decision = models.CharField(
        max_length=10,
        choices=Decision.choices,
        default=Decision.PENDING,
    )
    customer_note = models.TextField(blank=True)
    responded_at = models.DateTimeField(null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    def clean(self):
        from django.core.exceptions import ValidationError

        if self.inspection_id and self.repair_job_id:
            if self.inspection.repair_job_id != self.repair_job_id:
                raise ValidationError(
                    {"inspection": "Inspection must belong to this repair job."}
                )

    def __str__(self):
        return f"Approval - {self.repair_job.job_number}"


class RepairStatusHistory(models.Model):
    repair_job = models.ForeignKey(
        RepairJob,
        on_delete=models.CASCADE,
        related_name="status_history",
    )
    previous_status = models.CharField(max_length=40, blank=True)
    new_status = models.CharField(
        max_length=40,
        choices=RepairJob.Status.choices,
    )
    changed_by = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name="repair_status_changes",
    )
    note = models.TextField(blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ["created_at"]

    def __str__(self):
        return f"{self.repair_job.job_number}: {self.new_status}"
