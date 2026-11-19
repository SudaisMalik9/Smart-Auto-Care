
import hashlib
import secrets

from django.db import transaction
from django.utils import timezone

from rest_framework import generics, status
from rest_framework.authtoken.models import Token
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView

from .models import WebsitePairingCode
from .permissions import IsWorkshopOwner
from .serializers import (
    RegistrationSerializer,
    LoginSerializer,
    UserProfileSerializer,
)


class RegisterView(generics.CreateAPIView):
    serializer_class = RegistrationSerializer
    permission_classes = [AllowAny]


class LoginView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        serializer = LoginSerializer(
            data=request.data,
            context={"request": request},
        )
        serializer.is_valid(raise_exception=True)

        user = serializer.validated_data["user"]
        token, created = Token.objects.get_or_create(user=user)

        return Response(
            {
                "message": "Login successful.",
                "token": token.key,
                "user": UserProfileSerializer(user).data,
            },
            status=status.HTTP_200_OK,
        )


class LogoutView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        Token.objects.filter(user=request.user).delete()

        return Response(
            {"message": "Logout successful."},
            status=status.HTTP_200_OK,
        )


class ProfileView(generics.RetrieveAPIView):
    serializer_class = UserProfileSerializer
    permission_classes = [IsAuthenticated]

    def get_object(self):
        return self.request.user


class WebsitePairingGenerateView(APIView):
    permission_classes = [IsWorkshopOwner]

    def post(self, request):
        raw_code = secrets.token_urlsafe(32)
        code_hash = hashlib.sha256(raw_code.encode()).hexdigest()

        pairing = WebsitePairingCode.objects.create(
            user=request.user,
            code_hash=code_hash,
        )

        return Response(
            {
                "message": "QR pairing code generated.",
                "code": raw_code,
                "expires_at": pairing.expires_at,
                "expires_in_seconds": 300,
            },
            status=status.HTTP_201_CREATED,
        )


class WebsitePairingExchangeView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        raw_code = request.data.get("code")

        if not isinstance(raw_code, str) or not raw_code.strip():
            return Response(
                {"detail": "A valid pairing code is required."},
                status=status.HTTP_400_BAD_REQUEST,
            )

        code_hash = hashlib.sha256(raw_code.strip().encode()).hexdigest()

        with transaction.atomic():
            pairing = (
                WebsitePairingCode.objects
                .select_for_update()
                .select_related("user")
                .filter(code_hash=code_hash)
                .first()
            )

            if pairing is None:
                return Response(
                    {"detail": "Invalid pairing code."},
                    status=status.HTTP_400_BAD_REQUEST,
                )

            if pairing.used_at is not None:
                return Response(
                    {"detail": "This pairing code has already been used."},
                    status=status.HTTP_400_BAD_REQUEST,
                )

            if pairing.expires_at <= timezone.now():
                return Response(
                    {"detail": "This pairing code has expired."},
                    status=status.HTTP_400_BAD_REQUEST,
                )

            user = pairing.user

            if not user.is_active or user.role != "WORKSHOP_OWNER":
                return Response(
                    {"detail": "This account cannot pair with the website."},
                    status=status.HTTP_403_FORBIDDEN,
                )

            pairing.used_at = timezone.now()
            pairing.save(update_fields=["used_at"])

            token, created = Token.objects.get_or_create(user=user)

            return Response(
                {
                    "message": "Website and mobile app connected successfully.",
                    "token": token.key,
                    "user": UserProfileSerializer(user).data,
                },
                status=status.HTTP_200_OK,
            )
