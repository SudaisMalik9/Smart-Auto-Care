
from django.urls import path

from .views import (
    WorkshopOwnerApplicationListCreateView,
    AdminWorkshopApplicationListView,
    AdminWorkshopApplicationReviewView,
    WorkshopListCreateView,
    WorkshopDetailView,
)

urlpatterns = [
    # Workshop CRUD endpoints
    path(
        "",
        WorkshopListCreateView.as_view(),
        name="workshop-list-create",
    ),
    path(
        "<int:pk>/",
        WorkshopDetailView.as_view(),
        name="workshop-detail",
    ),

    # Customer application endpoints
    path(
        "applications/",
        WorkshopOwnerApplicationListCreateView.as_view(),
        name="workshop-application-list-create",
    ),

    # Admin application management endpoints
    path(
        "admin/applications/",
        AdminWorkshopApplicationListView.as_view(),
        name="admin-workshop-application-list",
    ),
    path(
        "admin/applications/<int:pk>/review/",
        AdminWorkshopApplicationReviewView.as_view(),
        name="admin-workshop-application-review",
    ),
]

