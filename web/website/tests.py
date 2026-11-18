from django.test import TestCase
from django.urls import reverse


class QRPairingPageTests(TestCase):

    def test_qr_pairing_page_loads(self):
        response = self.client.get(reverse("qr_pairing"))

        self.assertEqual(response.status_code, 200)
        self.assertContains(response, "Connect Your Workshop")
        self.assertContains(response, "Waiting for QR Scan")
        self.assertContains(response, "Development Mode")