
from django.contrib import admin

from .models import (
    MechanicSkill,
    MechanicProfile,
    BranchStaff,
    StaffWorkingHours,
    MechanicInvitation,
)


class StaffWorkingHoursInline(admin.TabularInline):
    model = StaffWorkingHours
    extra = 0


@admin.register(MechanicSkill)
class MechanicSkillAdmin(admin.ModelAdmin):
    list_display = ("name", "is_active")
    list_filter = ("is_active",)
    search_fields = ("name",)


@admin.register(MechanicProfile)
class MechanicProfileAdmin(admin.ModelAdmin):
    list_display = ("user", "experience_years", "is_available")
    list_filter = ("is_available",)
    search_fields = ("user__username", "user__email")
    filter_horizontal = ("skills",)


@admin.register(BranchStaff)
class BranchStaffAdmin(admin.ModelAdmin):
    list_display = ("user", "branch", "position", "is_active")
    list_filter = ("position", "is_active", "branch")
    search_fields = ("user__username", "branch__name")
    filter_horizontal = ("departments",)
    inlines = [StaffWorkingHoursInline]


@admin.register(StaffWorkingHours)
class StaffWorkingHoursAdmin(admin.ModelAdmin):
    list_display = (
        "staff_member",
        "weekday",
        "is_day_off",
        "start_time",
        "end_time",
    )
    list_filter = ("weekday", "is_day_off")


@admin.register(MechanicInvitation)
class MechanicInvitationAdmin(admin.ModelAdmin):
    list_display = (
        "email",
        "branch",
        "invited_by",
        "status",
        "expires_at",
        "created_at",
    )
    list_filter = ("status", "branch")
    search_fields = ("email", "branch__name")
    readonly_fields = ("token", "created_at", "accepted_at")
