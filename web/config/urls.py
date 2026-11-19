
from django.contrib import admin
from django.urls import path
from website import views

urlpatterns = [
    path("django-admin/", admin.site.urls),

    path("admin-dashboard/", views.admin_dashboard, name="admin_dashboard"),

    path("workshop-dashboard/", views.workshop_dashboard, name="workshop_dashboard"),

    path("workshop-pairing/", views.qr_pairing, name="qr_pairing"),

    path("admin-login/", views.admin_login, name="admin_login"),
]
