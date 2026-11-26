
import base64

from unittest.mock import patch

from django.test import TestCase, override_settings
from django.urls import reverse


class WebsitePageTests(TestCase):

    def test_admin_login_page_loads(self):
        response = self.client.get(reverse("admin_login"))

        self.assertEqual(response.status_code, 200)
        self.assertContains(response, "Admin Login")
        self.assertContains(response, "Email or Username")
        self.assertContains(response, "Password")
        self.assertContains(response, "Login")

    def test_admin_dashboard_loads(self):
        response = self.client.get(reverse("admin_dashboard"))

        self.assertEqual(response.status_code, 200)
        self.assertContains(response, "Admin Dashboard")
        self.assertContains(response, "Development Preview")

    def test_workshop_dashboard_redirects_without_login(self):
        response = self.client.get(reverse("workshop_dashboard"))

        self.assertRedirects(response, reverse("qr_pairing"))

    def test_qr_pairing_page_loads(self):
        response = self.client.get(reverse("qr_pairing"))

        self.assertEqual(response.status_code, 200)
        self.assertContains(response, "Workshop Owner Login")
        self.assertContains(response, "Scan to Login")
        self.assertContains(response, "retry-button")
        self.assertContains(response, "qr-pairing.js")


class PairingEndpointTests(TestCase):

    @patch("website.views.backend_post")
    def test_pairing_generate_returns_real_qr_image(self, mock_backend):
        mock_backend.return_value = (
            201,
            {
                "code": "test-secure-pairing-code",
                "expires_in_seconds": 300,
            },
        )

        response = self.client.post(
            reverse("pairing_generate"),
            content_type="application/json",
            HTTP_X_CSRFTOKEN="test-csrf-token",
        )

        self.assertEqual(response.status_code, 200)

        data = response.json()

        self.assertTrue(data["qr_image"].startswith("data:image/png;base64,"))
        self.assertEqual(data["expires_in_seconds"], 300)
        self.assertEqual(
            self.client.session["website_pairing_code"],
            "test-secure-pairing-code",
        )

        image_data = data["qr_image"].split(",", 1)[1]
        self.assertTrue(base64.b64decode(image_data))

    @patch("website.views.backend_post")
    def test_pairing_exchange_returns_pending_until_approval(
        self,
        mock_backend,
    ):
        session = self.client.session
        session["website_pairing_code"] = "test-pairing-code"
        session.save()

        mock_backend.return_value = (
            202,
            {"detail": "Approval is pending."},
        )

        response = self.client.post(
            reverse("pairing_exchange"),
            content_type="application/json",
            HTTP_X_CSRFTOKEN="test-csrf-token",
        )

        self.assertEqual(response.status_code, 202)
        self.assertEqual(response.json()["status"], "pending")

    @patch("website.views.backend_post")
    def test_pairing_exchange_creates_workshop_owner_session(
        self,
        mock_backend,
    ):
        session = self.client.session
        session["website_pairing_code"] = "test-pairing-code"
        session.save()

        mock_backend.return_value = (
            200,
            {
                "token": "server-side-test-token",
                "user": {
                    "id": 1,
                    "username": "workshop-owner",
                    "role": "WORKSHOP_OWNER",
                },
            },
        )

        response = self.client.post(
            reverse("pairing_exchange"),
            content_type="application/json",
            HTTP_X_CSRFTOKEN="test-csrf-token",
        )

        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.json()["status"], "authenticated")
        self.assertNotIn("token", response.json())

        session = self.client.session

        self.assertEqual(
            session["website_access_token"],
            "server-side-test-token",
        )
        self.assertTrue(session["website_authenticated"])
        self.assertEqual(
            session["website_user"]["role"],
            "WORKSHOP_OWNER",
        )

    @patch("website.views.backend_post")
    def test_pairing_exchange_rejects_non_workshop_owner(
        self,
        mock_backend,
    ):
        session = self.client.session
        session["website_pairing_code"] = "test-pairing-code"
        session.save()

        mock_backend.return_value = (
            200,
            {
                "token": "test-token",
                "user": {
                    "id": 2,
                    "username": "customer",
                    "role": "CUSTOMER",
                },
            },
        )

        response = self.client.post(
            reverse("pairing_exchange"),
            content_type="application/json",
            HTTP_X_CSRFTOKEN="test-csrf-token",
        )

        self.assertEqual(response.status_code, 403)
        self.assertNotIn("website_authenticated", self.client.session)

    def test_pairing_exchange_requires_existing_pairing_session(self):
        response = self.client.post(
            reverse("pairing_exchange"),
            content_type="application/json",
            HTTP_X_CSRFTOKEN="test-csrf-token",
        )

        self.assertEqual(response.status_code, 400)
class WorkshopLogoutTests(TestCase):

    @patch("website.views.backend_post")
    def test_logout_clears_website_session_without_deleting_backend_token(
        self,
        mock_backend,
    ):
        session = self.client.session
        session["website_authenticated"] = True
        session["website_access_token"] = "test-backend-token"
        session["website_user"] = {
            "id": 1,
            "username": "workshop-owner",
            "role": "WORKSHOP_OWNER",
        }
        session.save()

        response = self.client.post(reverse("website_logout"))

        self.assertRedirects(response, reverse("qr_pairing"))
        self.assertEqual(dict(self.client.session), {})
        mock_backend.assert_not_called()

    def test_logout_rejects_get_request(self):
        response = self.client.get(reverse("website_logout"))

        self.assertEqual(response.status_code, 405)