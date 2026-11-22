
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
    permission_classes = [AllowAny]

    def post(self, request):
        raw_code = secrets.token_urlsafe(32)
        code_hash = hashlib.sha256(raw_code.encode()).hexdigest()

        pairing = WebsitePairingCode.objects.create(
            code_hash=code_hash,
        )

        return Response(
            {
                "message": "QR pairing generated.",
                "code": raw_code,
                "expires_in_seconds": 300,
                "expires_at": pairing.expires_at,
            },
            status=status.HTTP_201_CREATED,
        )


class WebsitePairingScanView(APIView):
    permission_classes = [IsWorkshopOwner]

    def post(self, request):
        raw_code = request.data.get("code")

        if not isinstance(raw_code, str) or not raw_code.strip():
            return Response(
                {"detail": "Valid QR code required."},
                status=status.HTTP_400_BAD_REQUEST,
            )

        code_hash = hashlib.sha256(
            raw_code.strip().encode()
        ).hexdigest()

        with transaction.atomic():
            pairing = (
                WebsitePairingCode.objects
                .select_for_update()
                .filter(code_hash=code_hash)
                .first()
            )

            if pairing is None:
                return Response(
                    {"detail": "Invalid QR code."},
                    status=status.HTTP_404_NOT_FOUND,
                )

            if pairing.used_at or pairing.rejected_at:
                return Response(
                    {"detail": "This QR request is no longer available."},
                    status=status.HTTP_400_BAD_REQUEST,
                )

            if pairing.expires_at <= timezone.now():
                return Response(
                    {"detail": "QR code expired."},
                    status=status.HTTP_400_BAD_REQUEST,
                )

            if pairing.user and pairing.user_id != request.user.id:
                return Response(
                    {"detail": "This QR code is already being used."},
                    status=status.HTTP_409_CONFLICT,
                )

            pairing.user = request.user

            if pairing.scanned_at is None:
                pairing.scanned_at = timezone.now()

            pairing.save(update_fields=["user", "scanned_at"])

            workshop_names = list(
                request.user.workshops.filter(
                    is_active=True
                ).values_list("name", flat=True)
            )

            return Response({
                "message": "QR scanned. Owner approval is required.",
                "workshop_owner": request.user.username,
                "workshops": workshop_names,
                "requires_approval": True,
            })


class WebsitePairingApproveView(APIView):
    permission_classes = [IsWorkshopOwner]

    def post(self, request):
        raw_code = request.data.get("code")
        approved = request.data.get("approved")

        if not isinstance(raw_code, str) or not raw_code.strip():
            return Response(
                {"detail": "Valid QR code required."},
                status=status.HTTP_400_BAD_REQUEST,
            )

        if not isinstance(approved, bool):
            return Response(
                {"detail": "Approval must be true or false."},
                status=status.HTTP_400_BAD_REQUEST,
            )

        code_hash = hashlib.sha256(
            raw_code.strip().encode()
        ).hexdigest()

        with transaction.atomic():
            pairing = (
                WebsitePairingCode.objects
                .select_for_update()
                .filter(code_hash=code_hash)
                .first()
            )

            if pairing is None:
                return Response(
                    {"detail": "Invalid QR code."},
                    status=status.HTTP_404_NOT_FOUND,
                )

            if pairing.user_id != request.user.id:
                return Response(
                    {"detail": "You cannot approve this QR request."},
                    status=status.HTTP_403_FORBIDDEN,
                )

            if pairing.used_at or pairing.approved_at or pairing.rejected_at:
                return Response(
                    {"detail": "This request has already been handled."},
                    status=status.HTTP_400_BAD_REQUEST,
                )

            if pairing.expires_at <= timezone.now():
                return Response(
                    {"detail": "QR code expired."},
                    status=status.HTTP_400_BAD_REQUEST,
                )

            if pairing.scanned_at is None:
                return Response(
                    {"detail": "Scan the QR code first."},
                    status=status.HTTP_400_BAD_REQUEST,
                )

            if approved:
                pairing.approved_at = timezone.now()
            else:
                pairing.rejected_at = timezone.now()

            pairing.save(
                update_fields=["approved_at", "rejected_at"]
            )

        return Response({
            "message": (
                "Website login approved."
                if approved
                else "Website login rejected."
            ),
            "approved": approved,
        })


class WebsitePairingExchangeView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        raw_code = request.data.get("code")

        if not isinstance(raw_code, str) or not raw_code.strip():
            return Response(
                {"detail": "A valid pairing code is required."},
                status=status.HTTP_400_BAD_REQUEST,
            )

        code_hash = hashlib.sha256(
            raw_code.strip().encode()
        ).hexdigest()

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

            if pairing.used_at:
                return Response(
                    {"detail": "This pairing code has already been used."},
                    status=status.HTTP_400_BAD_REQUEST,
                )

            if pairing.expires_at <= timezone.now():
                return Response(
                    {"detail": "This pairing code has expired."},
                    status=status.HTTP_400_BAD_REQUEST,
                )

            if pairing.rejected_at:
                return Response(
                    {"detail": "The Workshop Owner rejected this login."},
                    status=status.HTTP_403_FORBIDDEN,
                )

            if not pairing.approved_at:
                return Response(
                    {
                        "status": "pending",
                        "message": "Waiting for Workshop Owner approval.",
                    },
                    status=status.HTTP_202_ACCEPTED,
                )

            user = pairing.user

            if (
                user is None
                or not user.is_active
                or user.role != "WORKSHOP_OWNER"
            ):
                return Response(
                    {"detail": "This account cannot access the website."},
                    status=status.HTTP_403_FORBIDDEN,
                )

            pairing.used_at = timezone.now()
            pairing.save(update_fields=["used_at"])

            token, created = Token.objects.get_or_create(user=user)

            return Response({
                "message": "Website login successful.",
                "token": token.key,
                "user": UserProfileSerializer(user).data,
            })