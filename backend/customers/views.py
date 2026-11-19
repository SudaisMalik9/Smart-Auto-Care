
from django.shortcuts import get_object_or_404
from rest_framework.response import Response
from rest_framework import generics
from rest_framework.exceptions import NotFound

from accounts.permissions import IsCustomer

from .models import CustomerProfile, CustomerVehicle
from .serializers import (
    CustomerProfileSerializer,
    CustomerVehicleSerializer,
)


class CustomerProfileView(generics.RetrieveUpdateAPIView):
    serializer_class = CustomerProfileSerializer
    permission_classes = [IsCustomer]
    http_method_names = ["get", "patch", "head", "options"]

    def get_object(self):
        try:
            return CustomerProfile.objects.get(user=self.request.user)
        except CustomerProfile.DoesNotExist:
            raise NotFound("Customer profile was not found.")


class CustomerVehicleListCreateView(generics.ListCreateAPIView):
    serializer_class = CustomerVehicleSerializer
    permission_classes = [IsCustomer]

    def get_queryset(self):
        return CustomerVehicle.objects.filter(
            customer__user=self.request.user,
            is_active=True,
        ).order_by("-created_at")

    def perform_create(self, serializer):
        profile, created = CustomerProfile.objects.get_or_create(
            user=self.request.user
        )
        serializer.save(customer=profile)


class CustomerVehicleDetailView(generics.RetrieveUpdateAPIView):
    serializer_class = CustomerVehicleSerializer
    permission_classes = [IsCustomer]
    http_method_names = ["get", "patch", "head", "options"]

    def get_queryset(self):
        return CustomerVehicle.objects.filter(
            customer__user=self.request.user,
            is_active=True,
        )


class CustomerVehicleDeleteView(generics.GenericAPIView):
    permission_classes = [IsCustomer]
    http_method_names = ["delete", "options"]

    def get_queryset(self):
        return CustomerVehicle.objects.filter(
            customer__user=self.request.user,
            is_active=True,
        )

    def delete(self, request, *args, **kwargs):
        vehicle = get_object_or_404(
            self.get_queryset(),
            pk=kwargs["pk"],
        )
        vehicle.is_active = False
        vehicle.save(update_fields=["is_active", "updated_at"])

        return Response(
            {"message": "Vehicle deactivated successfully."},
            status=200,
        )
