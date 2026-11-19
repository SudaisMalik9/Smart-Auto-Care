
from django.contrib.auth import authenticate, get_user_model
from django.contrib.auth.password_validation import validate_password
from django.db import transaction
from rest_framework import serializers

from customers.models import CustomerProfile


User = get_user_model()


class RegistrationSerializer(serializers.ModelSerializer):
    password = serializers.CharField(
        write_only=True,
        required=True,
        validators=[validate_password],
    )
    password_confirm = serializers.CharField(
        write_only=True,
        required=True,
    )

    class Meta:
        model = User
        fields = [
            "id",
            "username",
            "email",
            "first_name",
            "last_name",
            "password",
            "password_confirm",
        ]
        read_only_fields = ["id"]

    def validate(self, attrs):
        if attrs["password"] != attrs["password_confirm"]:
            raise serializers.ValidationError({
                "password_confirm": "Passwords do not match."
            })
        return attrs

    @transaction.atomic
    def create(self, validated_data):
        validated_data.pop("password_confirm")
        password = validated_data.pop("password")

        user = User.objects.create_user(
            password=password,
            role=User.Role.CUSTOMER,
            **validated_data,
        )

        CustomerProfile.objects.create(user=user)

        return user


class LoginSerializer(serializers.Serializer):
    username = serializers.CharField(
        required=False,
        allow_blank=False,
    )
    email = serializers.EmailField(
        required=False,
        allow_blank=False,
    )
    password = serializers.CharField(write_only=True)

    def validate(self, attrs):
        request = self.context.get("request")

        username = attrs.get("username")
        email = attrs.get("email")

        if not username and not email:
            raise serializers.ValidationError(
                "Provide either username or email."
            )

        if username and email:
            raise serializers.ValidationError(
                "Provide username or email, not both."
            )

        if email:
            matching_users = User.objects.filter(
                email__iexact=email
            )

            if matching_users.count() != 1:
                raise serializers.ValidationError(
                    "Invalid username/email or password."
                )

            username = matching_users.first().username

        user = authenticate(
            request=request,
            username=username,
            password=attrs["password"],
        )

        if user is None:
            raise serializers.ValidationError(
                "Invalid username/email or password."
            )

        if not user.is_active:
            raise serializers.ValidationError(
                "This account is inactive."
            )

        attrs["user"] = user
        return attrs


class UserProfileSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = [
            "id",
            "username",
            "email",
            "first_name",
            "last_name",
            "role",
        ]
        read_only_fields = fields
