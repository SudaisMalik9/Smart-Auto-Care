
from django.contrib import admin

from .models import (
    RepairJob,
    RepairStatusHistory,
    RepairTask,
    VehicleInspection,
    RepairApproval,
)


class RepairTaskInline(admin.TabularInline):
    model = RepairTask
    extra = 0


class VehicleInspectionInline(admin.TabularInline):
    model = VehicleInspection
    extra = 0


class RepairApprovalInline(admin.TabularInline):
    model = RepairApproval
    extra = 0


class RepairStatusHistoryInline(admin.TabularInline):
    model = RepairStatusHistory
    extra = 0
    readonly_fields = ("created_at",)


@admin.register(RepairJob)
class RepairJobAdmin(admin.ModelAdmin):
    list_display = (
        "job_number",
        "appointment",
        "branch",
        "vehicle",
        "assigned_mechanic",
        "status",
        "received_at",
    )
    list_filter = ("status", "branch", "received_at")
    search_fields = (
        "job_number",
        "customer__user__username",
        "vehicle__make",
        "vehicle__model",
    )
    readonly_fields = (
        "job_number",
        "created_at",
        "updated_at",
    )
    inlines = [
        VehicleInspectionInline,
        RepairTaskInline,
        RepairApprovalInline,
        RepairStatusHistoryInline,
    ]


@admin.register(VehicleInspection)
class VehicleInspectionAdmin(admin.ModelAdmin):
    list_display = (
        "repair_job",
        "inspected_by",
        "estimated_cost",
        "created_at",
    )
    list_filter = ("created_at",)
    search_fields = ("repair_job__job_number", "findings")


@admin.register(RepairTask)
class RepairTaskAdmin(admin.ModelAdmin):
    list_display = (
        "title",
        "repair_job",
        "assigned_mechanic",
        "status",
        "estimated_minutes",
    )
    list_filter = ("status",)
    search_fields = ("title", "repair_job__job_number")


@admin.register(RepairApproval)
class RepairApprovalAdmin(admin.ModelAdmin):
    list_display = (
        "repair_job",
        "inspection",
        "amount",
        "decision",
        "created_at",
    )
    list_filter = ("decision", "created_at")
    search_fields = ("repair_job__job_number",)


@admin.register(RepairStatusHistory)
class RepairStatusHistoryAdmin(admin.ModelAdmin):
    list_display = (
        "repair_job",
        "previous_status",
        "new_status",
        "changed_by",
        "created_at",
    )
    list_filter = ("new_status", "created_at")
    search_fields = ("repair_job__job_number",)
    readonly_fields = ("created_at",)
