
import hashlib
from datetime import timedelta

from django.utils import timezone
from rest_framework import status
from rest_framework.test import APITestCase

from .models import User, WebsitePairingCode


class WebsitePairingTests(APITestCase):
    generate_url = "/api/auth/website-pairing/generate/"
    scan_url = "/api/auth/website-pairing/scan/"
    approve_url = "/api/auth/website-pairing/approve/"
    exchange_url = "/api/auth/website-pairing/exchange/"

    def setUp(self):
        self.owner = User.objects.create_user(
            username="workshopowner",
            email="owner@example.com",
            password="TestPassword123!",
            role="WORKSHOP_OWNER",
        )
        self.other_owner = User.objects.create_user(
            username="otherowner",
            email="other@example.com",
            password="TestPassword123!",
            role="WORKSHOP_OWNER",
        )
        self.customer = User.objects.create_user(
            username="customer",
            email="customer@example.com",
            password="TestPassword123!",
            role="CUSTOMER",
        )

    def create_pairing(self, code, **kwargs):
        return WebsitePairingCode.objects.create(
            code_hash=hashlib.sha256(code.encode()).hexdigest(),
            **kwargs,
        )

    def scan(self, code):
        return self.client.post(
            self.scan_url, {"code": code}, format="json"
        )

    def approve(self, code, approved=True):
        return self.client.post(
            self.approve_url,
            {"code": code, "approved": approved},
            format="json",
        )

    def exchange(self, code):
        return self.client.post(
            self.exchange_url, {"code": code}, format="json"
        )

    def test_logged_out_user_can_generate_pairing_code(self):
        response = self.client.post(self.generate_url)
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)

        raw_code = response.data["code"]
        pairing = WebsitePairingCode.objects.get(
            code_hash=hashlib.sha256(raw_code.encode()).hexdigest()
        )
        self.assertIsNone(pairing.user)
        self.assertIsNone(pairing.used_at)
        self.assertNotEqual(pairing.code_hash, raw_code)

    def test_workshop_owner_can_generate_pairing_code(self):
        self.client.force_authenticate(user=self.owner)
        response = self.client.post(self.generate_url)
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)

        raw_code = response.data["code"]
        pairing = WebsitePairingCode.objects.get(
            code_hash=hashlib.sha256(raw_code.encode()).hexdigest()
        )
        self.assertIsNone(pairing.user)
        self.assertIsNone(pairing.used_at)

    def test_only_authenticated_workshop_owner_can_scan(self):
        self.create_pairing("scan-permission-code")

        response = self.scan("scan-permission-code")
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)

        self.client.force_authenticate(user=self.customer)
        response = self.scan("scan-permission-code")
        self.assertEqual(response.status_code, status.HTTP_403_FORBIDDEN)

        self.client.force_authenticate(user=self.owner)
        response = self.scan("scan-permission-code")
        self.assertEqual(response.status_code, status.HTTP_200_OK)

    def test_scanning_assigns_owner_but_does_not_approve(self):
        pairing = self.create_pairing("scan-approval-code")
        self.client.force_authenticate(user=self.owner)

        response = self.scan("scan-approval-code")
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertTrue(response.data["requires_approval"])

        pairing.refresh_from_db()
        self.assertEqual(pairing.user, self.owner)
        self.assertIsNotNone(pairing.scanned_at)
        self.assertIsNone(pairing.approved_at)

        self.client.force_authenticate(user=None)
        response = self.exchange("scan-approval-code")
        self.assertEqual(response.status_code, status.HTTP_202_ACCEPTED)

    def test_approval_is_required_before_successful_exchange(self):
        self.create_pairing("approved-flow-code")
        self.client.force_authenticate(user=self.owner)

        self.assertEqual(
            self.scan("approved-flow-code").status_code,
            status.HTTP_200_OK,
        )

        self.client.force_authenticate(user=None)
        pending = self.exchange("approved-flow-code")
        self.assertEqual(pending.status_code, status.HTTP_202_ACCEPTED)

        self.client.force_authenticate(user=self.owner)
        approval = self.approve("approved-flow-code", True)
        self.assertEqual(approval.status_code, status.HTTP_200_OK)

        self.client.force_authenticate(user=None)
        response = self.exchange("approved-flow-code")
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertTrue(response.data["token"])
        self.assertEqual(
            response.data["user"]["username"], self.owner.username
        )
        self.assertEqual(
            response.data["user"]["role"], "WORKSHOP_OWNER"
        )

    def test_rejected_pairing_cannot_be_exchanged(self):
        self.create_pairing("rejected-flow-code")
        self.client.force_authenticate(user=self.owner)
        self.assertEqual(
            self.scan("rejected-flow-code").status_code,
            status.HTTP_200_OK,
        )
        response = self.approve("rejected-flow-code", False)
        self.assertEqual(response.status_code, status.HTTP_200_OK)

        self.client.force_authenticate(user=None)
        response = self.exchange("rejected-flow-code")
        self.assertEqual(response.status_code, status.HTTP_403_FORBIDDEN)

    def test_another_owner_cannot_approve_pairing(self):
        self.create_pairing(
            "wrong-owner-code",
            user=self.owner,
            scanned_at=timezone.now(),
        )
        self.client.force_authenticate(user=self.other_owner)

        response = self.approve("wrong-owner-code", True)
        self.assertEqual(response.status_code, status.HTTP_403_FORBIDDEN)

    def test_invalid_code_is_rejected(self):
        self.client.force_authenticate(user=self.owner)

        self.assertEqual(
            self.scan("invalid-code").status_code,
            status.HTTP_404_NOT_FOUND,
        )
        self.assertEqual(
            self.approve("invalid-code").status_code,
            status.HTTP_404_NOT_FOUND,
        )

        self.client.force_authenticate(user=None)
        self.assertEqual(
            self.exchange("invalid-code").status_code,
            status.HTTP_400_BAD_REQUEST,
        )

    def test_expired_pairing_code_is_rejected(self):
        self.create_pairing(
            "expired-code",
            user=self.owner,
            scanned_at=timezone.now(),
            expires_at=timezone.now() - timedelta(minutes=1),
        )

        self.client.force_authenticate(user=self.owner)
        self.assertEqual(
            self.scan("expired-code").status_code,
            status.HTTP_400_BAD_REQUEST,
        )
        self.assertEqual(
            self.approve("expired-code").status_code,
            status.HTTP_400_BAD_REQUEST,
        )

        self.client.force_authenticate(user=None)
        self.assertEqual(
            self.exchange("expired-code").status_code,
            status.HTTP_400_BAD_REQUEST,
        )

    def test_pairing_code_cannot_be_reused(self):
        self.create_pairing(
            "reusable-code",
            user=self.owner,
            approved_at=timezone.now(),
        )

        first = self.exchange("reusable-code")
        second = self.exchange("reusable-code")

        self.assertEqual(first.status_code, status.HTTP_200_OK)
        self.assertEqual(second.status_code, status.HTTP_400_BAD_REQUEST)

    def test_used_pairing_cannot_be_scanned_again(self):
        self.create_pairing(
            "used-code",
            user=self.owner,
            approved_at=timezone.now(),
            used_at=timezone.now(),
        )
        self.client.force_authenticate(user=self.owner)

        response = self.scan("used-code")
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_missing_pairing_code_is_rejected(self):
        response = self.client.post(self.exchange_url, {}, format="json")
        self.assertEqual(
            response.status_code, status.HTTP_400_BAD_REQUEST
        )
