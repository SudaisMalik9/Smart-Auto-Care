
from django.urls import path

from .views import (
    CustomerProfileView,
    CustomerVehicleListCreateView,
    CustomerVehicleDetailView,
    CustomerVehicleDeleteView,
)

urlpatterns = [
    path(
        "profile/",
        CustomerProfileView.as_view(),
        name="customer-profile",
    ),
    path(
        "vehicles/",
        CustomerVehicleListCreateView.as_view(),
        name="customer-vehicles",
    ),
    path(
        "vehicles/<int:pk>/",
        CustomerVehicleDetailView.as_view(),
        name="customer-vehicle-detail",
    ),
    path(
        "vehicles/<int:pk>/delete/",
        CustomerVehicleDeleteView.as_view(),
        name="customer-vehicle-delete",
    ),
]
