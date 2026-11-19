from django.test import TestCase
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

    def test_workshop_dashboard_loads(self):
        response = self.client.get(reverse("workshop_dashboard"))

        self.assertEqual(response.status_code, 200)
        self.assertContains(response, "Workshop Dashboard")
        self.assertContains(response, "Development Preview")

    def test_qr_pairing_page_loads(self):
        response = self.client.get(reverse("qr_pairing"))

        self.assertEqual(response.status_code, 200)
        self.assertContains(response, "Connect Your Workshop")
        self.assertContains(response, "Waiting for QR Scan")
        self.assertContains(response, "Development Mode")