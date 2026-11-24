
import hashlib
from datetime import timedelta

from django.utils import timezone
from rest_framework import status
from rest_framework.test import APITestCase

from .models import User, WebsitePairingCode


class WebsitePairingTests(APITestCase):

    def setUp(self):
        self.owner = User.objects.create_user(
            username="workshopowner",
            email="owner@example.com",
            password="TestPassword123!",
            role="WORKSHOP_OWNER",
        )

        self.customer = User.objects.create_user(
            username="customer",
            email="customer@example.com",
            password="TestPassword123!",
            role="CUSTOMER",
        )

    def test_workshop_owner_can_generate_pairing_code(self):
        self.client.force_authenticate(user=self.owner)

        response = self.client.post(
            "/api/auth/website-pairing/generate/"
        )

        self.assertEqual(response.status_code, status.HTTP_201_CREATED)

        raw_code = response.data["code"]
        code_hash = hashlib.sha256(raw_code.encode()).hexdigest()

        pairing = WebsitePairingCode.objects.get(code_hash=code_hash)

        self.assertEqual(pairing.user, self.owner)
        self.assertIsNone(pairing.used_at)
        self.assertNotEqual(pairing.code_hash, raw_code)

    def test_customer_cannot_generate_pairing_code(self):
        self.client.force_authenticate(user=self.customer)

        response = self.client.post(
            "/api/auth/website-pairing/generate/"
        )

        self.assertEqual(response.status_code, status.HTTP_403_FORBIDDEN)

    def test_valid_code_can_be_exchanged(self):
        raw_code = "test-one-time-pairing-code"

        pairing = WebsitePairingCode.objects.create(
            user=self.owner,
            code_hash=hashlib.sha256(raw_code.encode()).hexdigest(),
            approved_at=timezone.now(),
        )

        response = self.client.post(
            "/api/auth/website-pairing/exchange/",
            {"code": raw_code},
            format="json",
        )

        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIn("token", response.data)
        self.assertEqual(response.data["user"]["role"], "WORKSHOP_OWNER")

        pairing.refresh_from_db()
        self.assertIsNotNone(pairing.used_at)

    def test_pairing_code_cannot_be_reused(self):
        raw_code = "test-reusable-code"

        WebsitePairingCode.objects.create(
            user=self.owner,
            code_hash=hashlib.sha256(raw_code.encode()).hexdigest(),
            approved_at=timezone.now(),
        )

        first_response = self.client.post(
            "/api/auth/website-pairing/exchange/",
            {"code": raw_code},
            format="json",
        )

        second_response = self.client.post(
            "/api/auth/website-pairing/exchange/",
            {"code": raw_code},
            format="json",
        )

        self.assertEqual(first_response.status_code, status.HTTP_200_OK)
        self.assertEqual(
            second_response.status_code,
            status.HTTP_400_BAD_REQUEST,
        )

    def test_expired_pairing_code_is_rejected(self):
        raw_code = "test-expired-code"

        WebsitePairingCode.objects.create(
            user=self.owner,
            code_hash=hashlib.sha256(raw_code.encode()).hexdigest(),
            expires_at=timezone.now() - timedelta(minutes=1),
        )

        response = self.client.post(
            "/api/auth/website-pairing/exchange/",
            {"code": raw_code},
            format="json",
        )

        self.assertEqual(
            response.status_code,
            status.HTTP_400_BAD_REQUEST,
        )

    def test_missing_pairing_code_is_rejected(self):
        response = self.client.post(
            "/api/auth/website-pairing/exchange/",
            {},
            format="json",
        )

        self.assertEqual(
            response.status_code,
            status.HTTP_400_BAD_REQUEST,
        )
