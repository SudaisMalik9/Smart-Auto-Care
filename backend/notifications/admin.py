
from django.contrib import admin

from .models import Notification, DeviceToken


@admin.register(Notification)
class NotificationAdmin(admin.ModelAdmin):
    list_display = (
        "title",
        "recipient",
        "notification_type",
        "is_read",
        "created_at",
    )
    list_filter = (
        "notification_type",
        "is_read",
        "created_at",
    )
    search_fields = (
        "title",
        "message",
        "recipient__username",
        "recipient__email",
    )
    readonly_fields = ("created_at", "read_at")


@admin.register(DeviceToken)
class DeviceTokenAdmin(admin.ModelAdmin):
    list_display = (
        "user",
        "platform",
        "is_active",
        "created_at",
        "updated_at",
    )
    list_filter = ("platform", "is_active")
    search_fields = ("user__username", "user__email")
    readonly_fields = ("created_at", "updated_at")
