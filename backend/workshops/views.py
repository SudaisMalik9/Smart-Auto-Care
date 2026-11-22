
from django.db import transaction
from django.utils import timezone
from django.shortcuts import get_object_or_404

from rest_framework import generics
from rest_framework.exceptions import ValidationError

from accounts.models import User
from accounts.permissions import IsCustomer, IsAdmin, IsWorkshopOwner

from .models import (
    Workshop,
    WorkshopOwnerApplication,
    WorkshopBranch,
    BranchOperatingHours,
    WorkshopDepartment,
    WorkshopService,
)

from .serializers import (
    WorkshopOwnerApplicationSerializer,
    WorkshopOwnerApplicationReviewSerializer,
    WorkshopSerializer,
    WorkshopBranchSerializer,
    BranchOperatingHoursSerializer,
    WorkshopDepartmentSerializer,
    WorkshopServiceSerializer,
)


# -------------------------------------------------
# WORKSHOP OWNER APPLICATIONS
# -------------------------------------------------

class WorkshopOwnerApplicationListCreateView(generics.ListCreateAPIView):
    serializer_class = WorkshopOwnerApplicationSerializer
    permission_classes = [IsCustomer]

    def get_queryset(self):
        return WorkshopOwnerApplication.objects.filter(
            applicant=self.request.user
        ).order_by("-created_at")

    def perform_create(self, serializer):
        serializer.save(applicant=self.request.user)


class AdminWorkshopApplicationListView(generics.ListAPIView):
    serializer_class = WorkshopOwnerApplicationSerializer
    permission_classes = [IsAdmin]

    def get_queryset(self):
        queryset = WorkshopOwnerApplication.objects.select_related(
            "applicant", "reviewed_by"
        ).all()

        application_status = self.request.query_params.get("status")
        if application_status:
            queryset = queryset.filter(
                status=application_status.upper()
            )

        return queryset.order_by("-created_at")


class AdminWorkshopApplicationReviewView(generics.UpdateAPIView):
    serializer_class = WorkshopOwnerApplicationReviewSerializer
    permission_classes = [IsAdmin]
    http_method_names = ["patch", "options", "head"]

    def get_queryset(self):
        return WorkshopOwnerApplication.objects.all()

    @transaction.atomic
    def perform_update(self, serializer):
        application = get_object_or_404(
            WorkshopOwnerApplication.objects.select_for_update(),
            pk=serializer.instance.pk,
        )

        if application.status != WorkshopOwnerApplication.Status.PENDING:
            raise ValidationError(
                "This application has already been reviewed."
            )

        new_status = serializer.validated_data["status"]

        if (
            new_status == WorkshopOwnerApplication.Status.APPROVED
            and application.applicant.role != User.Role.CUSTOMER
        ):
            raise ValidationError(
                "Only customer accounts can be approved as Workshop Owners."
            )

        serializer.instance = application
        serializer.save(
            reviewed_by=self.request.user,
            reviewed_at=timezone.now(),
        )

        if new_status == WorkshopOwnerApplication.Status.APPROVED:
            application.applicant.role = User.Role.WORKSHOP_OWNER
            application.applicant.save(update_fields=["role"])


# -------------------------------------------------
# WORKSHOP CRUD
# -------------------------------------------------

class WorkshopListCreateView(generics.ListCreateAPIView):
    serializer_class = WorkshopSerializer
    permission_classes = [IsWorkshopOwner]

    def get_queryset(self):
        return Workshop.objects.filter(
            owner=self.request.user
        ).order_by("name")

    def perform_create(self, serializer):
        serializer.save(owner=self.request.user)


class WorkshopDetailView(generics.RetrieveUpdateDestroyAPIView):
    serializer_class = WorkshopSerializer
    permission_classes = [IsWorkshopOwner]
    http_method_names = [
        "get", "put", "patch", "delete", "head", "options",
    ]

    def get_queryset(self):
        return Workshop.objects.filter(owner=self.request.user)

    def perform_destroy(self, instance):
        instance.is_active = False
        instance.save(update_fields=["is_active", "updated_at"])


# -------------------------------------------------
# BRANCH CRUD
# -------------------------------------------------

class WorkshopBranchListCreateView(generics.ListCreateAPIView):
    serializer_class = WorkshopBranchSerializer
    permission_classes = [IsWorkshopOwner]

    def get_workshop(self):
        return get_object_or_404(
            Workshop,
            pk=self.kwargs["workshop_pk"],
            owner=self.request.user,
            is_active=True,
        )

    def get_queryset(self):
        return WorkshopBranch.objects.filter(
            workshop=self.get_workshop(),
            is_active=True,
        ).select_related("workshop").order_by("-is_primary", "name")

    @transaction.atomic
    def perform_create(self, serializer):
        workshop = self.get_workshop()

        first_branch = not WorkshopBranch.objects.filter(
            workshop=workshop
        ).exists()

        make_primary = (
            first_branch
            or serializer.validated_data.get("is_primary", False)
        )

        if make_primary:
            WorkshopBranch.objects.filter(
                workshop=workshop,
                is_primary=True,
            ).update(is_primary=False)

        serializer.save(
            workshop=workshop,
            is_primary=make_primary,
        )


class WorkshopBranchDetailView(generics.RetrieveUpdateDestroyAPIView):
    serializer_class = WorkshopBranchSerializer
    permission_classes = [IsWorkshopOwner]
    http_method_names = [
        "get", "put", "patch", "delete", "head", "options",
    ]

    def get_queryset(self):
        return WorkshopBranch.objects.filter(
            workshop__owner=self.request.user,
            workshop__is_active=True,
            is_active=True,
        ).select_related("workshop")

    @transaction.atomic
    def perform_update(self, serializer):
        branch = self.get_object()
        make_primary = serializer.validated_data.get(
            "is_primary", branch.is_primary
        )

        if make_primary:
            WorkshopBranch.objects.filter(
                workshop=branch.workshop,
                is_primary=True,
            ).exclude(pk=branch.pk).update(is_primary=False)

        serializer.save()

    @transaction.atomic
    def perform_destroy(self, instance):
        was_primary = instance.is_primary
        workshop = instance.workshop

        instance.is_active = False
        instance.is_primary = False
        instance.save(
            update_fields=["is_active", "is_primary", "updated_at"]
        )

        if was_primary:
            replacement = WorkshopBranch.objects.filter(
                workshop=workshop,
                is_active=True,
            ).order_by("created_at", "id").first()

            if replacement:
                replacement.is_primary = True
                replacement.save(update_fields=["is_primary"])


# -------------------------------------------------
# BRANCH OPERATING HOURS
# -------------------------------------------------

class BranchOperatingHoursListCreateView(generics.ListCreateAPIView):
    serializer_class = BranchOperatingHoursSerializer
    permission_classes = [IsWorkshopOwner]

    def get_branch(self):
        return get_object_or_404(
            WorkshopBranch,
            pk=self.kwargs["branch_pk"],
            workshop__owner=self.request.user,
            workshop__is_active=True,
            is_active=True,
        )

    def get_queryset(self):
        return BranchOperatingHours.objects.filter(
            branch=self.get_branch()
        ).select_related("branch")

    def perform_create(self, serializer):
        branch = self.get_branch()
        weekday = serializer.validated_data["weekday"]

        if BranchOperatingHours.objects.filter(
            branch=branch, weekday=weekday
        ).exists():
            raise ValidationError(
                "Operating hours for this weekday already exist."
            )

        serializer.save(branch=branch)


class BranchOperatingHoursDetailView(
    generics.RetrieveUpdateDestroyAPIView
):
    serializer_class = BranchOperatingHoursSerializer
    permission_classes = [IsWorkshopOwner]
    http_method_names = [
        "get", "put", "patch", "delete", "head", "options",
    ]

    def get_queryset(self):
        return BranchOperatingHours.objects.filter(
            branch__workshop__owner=self.request.user,
            branch__workshop__is_active=True,
            branch__is_active=True,
        ).select_related("branch")

    def perform_update(self, serializer):
        hours = self.get_object()
        weekday = serializer.validated_data.get(
            "weekday", hours.weekday
        )

        duplicate = BranchOperatingHours.objects.filter(
            branch=hours.branch,
            weekday=weekday,
        ).exclude(pk=hours.pk).exists()

        if duplicate:
            raise ValidationError(
                "Operating hours for this weekday already exist."
            )

        serializer.save()


# -------------------------------------------------
# DEPARTMENT CRUD
# -------------------------------------------------

class WorkshopDepartmentListCreateView(generics.ListCreateAPIView):
    serializer_class = WorkshopDepartmentSerializer
    permission_classes = [IsWorkshopOwner]

    def get_branch(self):
        return get_object_or_404(
            WorkshopBranch,
            pk=self.kwargs["branch_pk"],
            workshop__owner=self.request.user,
            workshop__is_active=True,
            is_active=True,
        )

    def get_queryset(self):
        return WorkshopDepartment.objects.filter(
            branch=self.get_branch(),
            is_active=True,
        ).order_by("name")

    def perform_create(self, serializer):
        serializer.save(branch=self.get_branch())


class WorkshopDepartmentDetailView(
    generics.RetrieveUpdateDestroyAPIView
):
    serializer_class = WorkshopDepartmentSerializer
    permission_classes = [IsWorkshopOwner]
    http_method_names = [
        "get", "put", "patch", "delete", "head", "options",
    ]

    def get_queryset(self):
        return WorkshopDepartment.objects.filter(
            branch__workshop__owner=self.request.user,
            branch__workshop__is_active=True,
            branch__is_active=True,
            is_active=True,
        )

    def perform_destroy(self, instance):
        instance.is_active = False
        instance.save(update_fields=["is_active"])


# -------------------------------------------------
# SERVICE CRUD
# -------------------------------------------------

class WorkshopServiceListCreateView(generics.ListCreateAPIView):
    serializer_class = WorkshopServiceSerializer
    permission_classes = [IsWorkshopOwner]

    def get_branch(self):
        return get_object_or_404(
            WorkshopBranch,
            pk=self.kwargs["branch_pk"],
            workshop__owner=self.request.user,
            workshop__is_active=True,
            is_active=True,
        )

    def get_queryset(self):
        return WorkshopService.objects.filter(
            branch=self.get_branch(),
            is_active=True,
        ).select_related("department").order_by("name")

    def get_serializer_context(self):
        context = super().get_serializer_context()
        context["branch"] = self.get_branch()
        return context

    def perform_create(self, serializer):
        serializer.save(branch=self.get_branch())


class WorkshopServiceDetailView(
    generics.RetrieveUpdateDestroyAPIView
):
    serializer_class = WorkshopServiceSerializer
    permission_classes = [IsWorkshopOwner]
    http_method_names = [
        "get", "put", "patch", "delete", "head", "options",
    ]

    def get_queryset(self):
        return WorkshopService.objects.filter(
            branch__workshop__owner=self.request.user,
            branch__workshop__is_active=True,
            branch__is_active=True,
            is_active=True,
        ).select_related("department", "branch")

    def perform_destroy(self, instance):
        instance.is_active = False
        instance.save(update_fields=["is_active", "updated_at"])
