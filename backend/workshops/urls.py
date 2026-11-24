
from django.urls import path

from .views import (
    WorkshopOwnerApplicationListCreateView,
    AdminWorkshopApplicationListView,
    AdminWorkshopApplicationReviewView,
    WorkshopListCreateView,
    WorkshopDetailView,
    WorkshopBranchListCreateView,
    WorkshopBranchDetailView,
    BranchOperatingHoursListCreateView,
    BranchOperatingHoursDetailView,
    WorkshopDepartmentListCreateView,
    WorkshopDepartmentDetailView,
    WorkshopServiceListCreateView,
    WorkshopServiceDetailView,
)

urlpatterns = [
    # Workshop
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

    # Workshop Owner applications
    path(
        "applications/",
        WorkshopOwnerApplicationListCreateView.as_view(),
        name="workshop-application-list-create",
    ),

    # Admin application management
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

    # Branches
    path(
        "<int:workshop_pk>/branches/",
        WorkshopBranchListCreateView.as_view(),
        name="workshop-branch-list-create",
    ),
    path(
        "branches/<int:pk>/",
        WorkshopBranchDetailView.as_view(),
        name="workshop-branch-detail",
    ),

    # Operating hours
    path(
        "branches/<int:branch_pk>/operating-hours/",
        BranchOperatingHoursListCreateView.as_view(),
        name="branch-operating-hours-list-create",
    ),
    path(
        "operating-hours/<int:pk>/",
        BranchOperatingHoursDetailView.as_view(),
        name="branch-operating-hours-detail",
    ),

    # Departments
    path(
        "branches/<int:branch_pk>/departments/",
        WorkshopDepartmentListCreateView.as_view(),
        name="workshop-department-list-create",
    ),
    path(
        "departments/<int:pk>/",
        WorkshopDepartmentDetailView.as_view(),
        name="workshop-department-detail",
    ),

    # Services
    path(
        "branches/<int:branch_pk>/services/",
        WorkshopServiceListCreateView.as_view(),
        name="workshop-service-list-create",
    ),
    path(
        "services/<int:pk>/",
        WorkshopServiceDetailView.as_view(),
        name="workshop-service-detail",
    ),
]
