
from django.contrib import admin

from .models import (
    Workshop,
    WorkshopBranch,
    BranchOperatingHours,
    WorkshopDepartment,
    WorkshopService,
    WorkshopOwnerApplication,
)


class BranchOperatingHoursInline(admin.TabularInline):
    model = BranchOperatingHours
    extra = 1


class WorkshopDepartmentInline(admin.TabularInline):
    model = WorkshopDepartment
    extra = 0


class WorkshopServiceInline(admin.TabularInline):
    model = WorkshopService
    extra = 0


@admin.register(Workshop)
class WorkshopAdmin(admin.ModelAdmin):
    list_display = ("name", "owner", "email", "phone", "is_active")
    list_filter = ("is_active",)
    search_fields = ("name", "owner__username", "owner__email")


@admin.register(WorkshopBranch)
class WorkshopBranchAdmin(admin.ModelAdmin):
    list_display = ("name", "workshop", "city", "is_primary", "is_active")
    list_filter = ("is_active", "is_primary", "city")
    search_fields = ("name", "workshop__name", "city")
    inlines = [
        BranchOperatingHoursInline,
        WorkshopDepartmentInline,
        WorkshopServiceInline,
    ]


@admin.register(BranchOperatingHours)
class BranchOperatingHoursAdmin(admin.ModelAdmin):
    list_display = (
        "branch",
        "weekday",
        "is_closed",
        "opening_time",
        "closing_time",
    )
    list_filter = ("weekday", "is_closed")


@admin.register(WorkshopDepartment)
class WorkshopDepartmentAdmin(admin.ModelAdmin):
    list_display = ("name", "branch", "is_active")
    list_filter = ("is_active",)
    search_fields = ("name", "branch__name")


@admin.register(WorkshopService)
class WorkshopServiceAdmin(admin.ModelAdmin):
    list_display = (
        "name",
        "branch",
        "department",
        "price",
        "estimated_duration_minutes",
        "is_active",
    )
    list_filter = ("is_active", "branch")
    search_fields = ("name", "branch__name", "department__name")


@admin.register(WorkshopOwnerApplication)
class WorkshopOwnerApplicationAdmin(admin.ModelAdmin):
    list_display = (
        "business_name",
        "applicant",
        "city",
        "status",
        "created_at",
        "reviewed_by",
    )

    list_filter = ("status", "city", "created_at")

    search_fields = (
        "business_name",
        "business_email",
        "applicant__username",
        "applicant__email",
    )

    readonly_fields = (
        "applicant",
        "created_at",
        "updated_at",
        "reviewed_by",
        "reviewed_at",
    )

    fields = (
        "applicant",
        "business_name",
        "business_email",
        "business_phone",
        "business_address",
        "city",
        "description",
        "status",
        "admin_note",
        "reviewed_by",
        "reviewed_at",
        "created_at",
        "updated_at",
    )
