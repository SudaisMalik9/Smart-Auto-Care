
from django.contrib import admin
from django.urls import path
from website.views import home, admin_dashboard, workshop_dashboard

urlpatterns = [
    path("admin/", admin.site.urls),
    path("", home, name="home"),
    path("admin-dashboard/", admin_dashboard, name="admin_dashboard"),
    path("workshop-dashboard/", workshop_dashboard, name="workshop_dashboard"),
]
