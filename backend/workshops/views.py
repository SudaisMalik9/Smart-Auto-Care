
from django.db import transaction
from django.utils import timezone
from django.shortcuts import get_object_or_404

from rest_framework import generics
from rest_framework.exceptions import ValidationError

from accounts.models import User
from accounts.permissions import IsCustomer, IsAdmin, IsWorkshopOwner

from .models import Workshop, WorkshopOwnerApplication
from .serializers import (
    WorkshopOwnerApplicationSerializer,
    WorkshopOwnerApplicationReviewSerializer,
    WorkshopSerializer,
)


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
            "applicant",
            "reviewed_by",
        ).all()

        application_status = self.request.query_params.get("status")

        if application_status:
            queryset = queryset.filter(status=application_status.upper())

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
        "get",
        "put",
        "patch",
        "delete",
        "head",
        "options",
    ]

    def get_queryset(self):
        return Workshop.objects.filter(
            owner=self.request.user
        )

    def perform_destroy(self, instance):
        instance.is_active = False
        instance.save(update_fields=["is_active", "updated_at"])
