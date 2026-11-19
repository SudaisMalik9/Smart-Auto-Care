
from rest_framework import serializers

from .models import Workshop, WorkshopOwnerApplication


class WorkshopOwnerApplicationSerializer(serializers.ModelSerializer):
    applicant_username = serializers.CharField(
        source="applicant.username",
        read_only=True,
    )

    class Meta:
        model = WorkshopOwnerApplication
        fields = [
            "id",
            "applicant_username",
            "business_name",
            "business_email",
            "business_phone",
            "business_address",
            "city",
            "description",
            "status",
            "admin_note",
            "reviewed_at",
            "created_at",
            "updated_at",
        ]

        read_only_fields = [
            "id",
            "applicant_username",
            "status",
            "admin_note",
            "reviewed_at",
            "created_at",
            "updated_at",
        ]

    def validate(self, attrs):
        request = self.context.get("request")

        if request and request.user.is_authenticated:
            existing = WorkshopOwnerApplication.objects.filter(
                applicant=request.user,
                status=WorkshopOwnerApplication.Status.PENDING,
            )

            if self.instance:
                existing = existing.exclude(pk=self.instance.pk)

            if existing.exists():
                raise serializers.ValidationError(
                    "You already have a pending Workshop Owner application."
                )

        return attrs


class WorkshopOwnerApplicationReviewSerializer(serializers.ModelSerializer):
    class Meta:
        model = WorkshopOwnerApplication
        fields = ["status", "admin_note"]

    def validate_status(self, value):
        if value not in [
            WorkshopOwnerApplication.Status.APPROVED,
            WorkshopOwnerApplication.Status.REJECTED,
        ]:
            raise serializers.ValidationError(
                "An application can only be approved or rejected."
            )

        return value

    def validate(self, attrs):
        if attrs["status"] == WorkshopOwnerApplication.Status.REJECTED:
            if not attrs.get("admin_note", "").strip():
                raise serializers.ValidationError({
                    "admin_note": "A rejection reason is required."
                })

        return attrs




class WorkshopSerializer(serializers.ModelSerializer):
    owner_username = serializers.CharField(
        source="owner.username",
        read_only=True,
    )

    class Meta:
        model = Workshop
        fields = [
            "id",
            "owner_username",
            "name",
            "description",
            "email",
            "phone",
            "is_active",
            "created_at",
            "updated_at",
        ]
        read_only_fields = [
            "id",
            "owner_username",
            "is_active",
            "created_at",
            "updated_at",
        ]
