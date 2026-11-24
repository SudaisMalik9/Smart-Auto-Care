
from rest_framework import serializers

from .models import (
    Workshop,
    WorkshopOwnerApplication,
    WorkshopBranch,
    BranchOperatingHours,
    WorkshopDepartment,
    WorkshopService,
)


class WorkshopOwnerApplicationSerializer(serializers.ModelSerializer):
    applicant_username = serializers.CharField(
        source="applicant.username",
        read_only=True,
    )

    class Meta:
        model = WorkshopOwnerApplication
        fields = [
            "id", "applicant_username", "business_name",
            "business_email", "business_phone", "business_address",
            "city", "description", "status", "admin_note",
            "reviewed_at", "created_at", "updated_at",
        ]
        read_only_fields = [
            "id", "applicant_username", "status", "admin_note",
            "reviewed_at", "created_at", "updated_at",
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
            "id", "owner_username", "name", "description",
            "email", "phone", "is_active", "created_at", "updated_at",
        ]
        read_only_fields = [
            "id", "owner_username", "is_active",
            "created_at", "updated_at",
        ]


class WorkshopBranchSerializer(serializers.ModelSerializer):
    workshop = serializers.PrimaryKeyRelatedField(read_only=True)

    class Meta:
        model = WorkshopBranch
        fields = [
            "id", "workshop", "name", "address", "city",
            "phone", "email", "is_primary", "is_active",
            "created_at", "updated_at",
        ]
        read_only_fields = [
            "id", "workshop", "is_active",
            "created_at", "updated_at",
        ]


class BranchOperatingHoursSerializer(serializers.ModelSerializer):
    weekday_display = serializers.CharField(
        source="get_weekday_display",
        read_only=True,
    )
    branch = serializers.PrimaryKeyRelatedField(read_only=True)

    class Meta:
        model = BranchOperatingHours
        fields = [
            "id", "branch", "weekday", "weekday_display",
            "is_closed", "opening_time", "closing_time",
        ]
        read_only_fields = ["id", "branch", "weekday_display"]

    def validate(self, attrs):
        current = self.instance

        is_closed = attrs.get(
            "is_closed",
            current.is_closed if current else False,
        )
        opening_time = attrs.get(
            "opening_time",
            current.opening_time if current else None,
        )
        closing_time = attrs.get(
            "closing_time",
            current.closing_time if current else None,
        )

        if is_closed:
            attrs["opening_time"] = None
            attrs["closing_time"] = None
        elif not opening_time or not closing_time:
            raise serializers.ValidationError(
                "Opening and closing times are required."
            )
        elif closing_time <= opening_time:
            raise serializers.ValidationError(
                "Closing time must be later than opening time."
            )

        return attrs


class WorkshopDepartmentSerializer(serializers.ModelSerializer):
    branch = serializers.PrimaryKeyRelatedField(read_only=True)

    class Meta:
        model = WorkshopDepartment
        fields = [
            "id", "branch", "name", "description",
            "is_active", "created_at",
        ]
        read_only_fields = [
            "id", "branch", "is_active", "created_at",
        ]


class WorkshopServiceSerializer(serializers.ModelSerializer):
    branch = serializers.PrimaryKeyRelatedField(read_only=True)

    class Meta:
        model = WorkshopService
        fields = [
            "id", "branch", "department", "name", "description",
            "price", "estimated_duration_minutes", "is_active",
            "created_at", "updated_at",
        ]
        read_only_fields = [
            "id", "branch", "is_active", "created_at", "updated_at",
        ]

    def validate(self, attrs):
        current = self.instance
        branch = (
            current.branch if current
            else self.context.get("branch")
        )
        department = attrs.get(
            "department",
            current.department if current else None,
        )

        if department and branch and department.branch_id != branch.id:
            raise serializers.ValidationError({
                "department": (
                    "The selected department must belong to this branch."
                )
            })

        if "price" in attrs and attrs["price"] < 0:
            raise serializers.ValidationError({
                "price": "Price cannot be negative."
            })

        if (
            "estimated_duration_minutes" in attrs
            and attrs["estimated_duration_minutes"] <= 0
        ):
            raise serializers.ValidationError({
                "estimated_duration_minutes": (
                    "Duration must be greater than zero."
                )
            })

        return attrs
