
from django.contrib import admin
from .models import CustomerProfile, CustomerVehicle


class CustomerVehicleInline(admin.TabularInline):
    model = CustomerVehicle
    extra = 0


@admin.register(CustomerProfile)
class CustomerProfileAdmin(admin.ModelAdmin):
    list_display = ("user", "phone", "city", "created_at")
    search_fields = ("user__username", "user__email", "phone")
    inlines = [CustomerVehicleInline]


@admin.register(CustomerVehicle)
class CustomerVehicleAdmin(admin.ModelAdmin):
    list_display = (
        "make",
        "model",
        "year",
        "customer",
        "registration_number",
        "fuel_type",
        "is_active",
    )
    list_filter = ("fuel_type", "transmission", "is_active")
    search_fields = (
        "make",
        "model",
        "registration_number",
        "customer__user__username",
    )
