
from django.contrib import admin

from .models import Invoice, InvoiceItem, PaymentRecord


class InvoiceItemInline(admin.TabularInline):
    model = InvoiceItem
    extra = 1


class PaymentRecordInline(admin.TabularInline):
    model = PaymentRecord
    extra = 0
    readonly_fields = ("created_at",)


@admin.register(Invoice)
class InvoiceAdmin(admin.ModelAdmin):
    list_display = (
        "invoice_number",
        "customer",
        "branch",
        "total_amount",
        "status",
        "issue_date",
        "due_date",
    )
    list_filter = ("status", "branch", "issue_date")
    search_fields = (
        "invoice_number",
        "customer__user__username",
        "repair_job__job_number",
    )
    readonly_fields = ("created_at", "updated_at")
    inlines = [InvoiceItemInline, PaymentRecordInline]


@admin.register(InvoiceItem)
class InvoiceItemAdmin(admin.ModelAdmin):
    list_display = (
        "description",
        "invoice",
        "item_type",
        "quantity",
        "unit_price",
        "line_total",
    )
    list_filter = ("item_type",)
    search_fields = ("description", "invoice__invoice_number")


@admin.register(PaymentRecord)
class PaymentRecordAdmin(admin.ModelAdmin):
    list_display = (
        "invoice",
        "amount",
        "method",
        "status",
        "received_at",
        "recorded_by",
    )
    list_filter = ("method", "status", "received_at")
    search_fields = (
        "invoice__invoice_number",
        "reference_number",
    )
