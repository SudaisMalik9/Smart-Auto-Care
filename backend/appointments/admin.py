
from django.contrib import admin

from .models import (
    Appointment,
    AppointmentAlternative,
    AppointmentStatusHistory,
)


class AppointmentAlternativeInline(admin.TabularInline):
    model = AppointmentAlternative
    extra = 0
    readonly_fields = ("created_at", "responded_at")


class AppointmentStatusHistoryInline(admin.TabularInline):
    model = AppointmentStatusHistory
    extra = 0
    readonly_fields = ("created_at",)


@admin.register(Appointment)
class AppointmentAdmin(admin.ModelAdmin):
    list_display = (
        "id",
        "customer",
        "branch",
        "service",
        "preferred_datetime",
        "status",
        "assigned_mechanic",
    )
    list_filter = ("status", "branch", "preferred_datetime")
    search_fields = (
        "customer__user__username",
        "customer__user__email",
        "vehicle__registration_number",
        "branch__name",
        "service__name",
    )
    readonly_fields = ("created_at", "updated_at")
    inlines = [
        AppointmentAlternativeInline,
        AppointmentStatusHistoryInline,
    ]


@admin.register(AppointmentAlternative)
class AppointmentAlternativeAdmin(admin.ModelAdmin):
    list_display = (
        "appointment",
        "proposed_datetime",
        "response_status",
        "proposed_by",
        "created_at",
    )
    list_filter = ("response_status",)
    search_fields = ("appointment__customer__user__username",)


@admin.register(AppointmentStatusHistory)
class AppointmentStatusHistoryAdmin(admin.ModelAdmin):
    list_display = (
        "appointment",
        "previous_status",
        "new_status",
        "changed_by",
        "created_at",
    )
    list_filter = ("new_status", "created_at")
    search_fields = ("appointment__customer__user__username",)
    readonly_fields = ("created_at",)
