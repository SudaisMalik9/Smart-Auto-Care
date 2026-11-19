
from rest_framework.test import APITestCase
from rest_framework import status

from accounts.models import User
from .models import WorkshopOwnerApplication


class WorkshopOwnerApplicationTests(APITestCase):

    def setUp(self):
        self.customer = User.objects.create_user(
            username="applicant1",
            email="applicant1@example.com",
            password="TestPass123!",
            role="CUSTOMER",
        )

        self.other_customer = User.objects.create_user(
            username="applicant2",
            email="applicant2@example.com",
            password="TestPass123!",
            role="CUSTOMER",
        )

        self.admin = User.objects.create_user(
            username="admin1",
            email="admin1@example.com",
            password="TestPass123!",
            role="ADMIN",
        )

        self.application_data = {
            "business_name": "Smart Auto Workshop",
            "business_email": "workshop@example.com",
            "business_phone": "03001234567",
            "business_address": "Main Boulevard",
            "city": "Lahore",
            "description": "Vehicle repair and maintenance services.",
        }

    def create_application(self):
        return WorkshopOwnerApplication.objects.create(
            applicant=self.customer,
            **self.application_data,
        )

    def test_customer_can_submit_application(self):
        self.client.force_authenticate(user=self.customer)

        response = self.client.post(
            "/api/workshops/applications/",
            self.application_data,
            format="json",
        )

        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertEqual(response.data["status"], "PENDING")

        self.customer.refresh_from_db()
        self.assertEqual(self.customer.role, "CUSTOMER")

    def test_customer_can_view_own_applications(self):
        self.create_application()
        self.client.force_authenticate(user=self.customer)

        response = self.client.get("/api/workshops/applications/")

        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(len(response.data), 1)

    def test_customer_cannot_view_other_users_applications(self):
        self.create_application()
        self.client.force_authenticate(user=self.other_customer)

        response = self.client.get("/api/workshops/applications/")

        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(len(response.data), 0)

    def test_customer_cannot_submit_duplicate_pending_application(self):
        self.create_application()
        self.client.force_authenticate(user=self.customer)

        response = self.client.post(
            "/api/workshops/applications/",
            self.application_data,
            format="json",
        )

        self.assertEqual(
            response.status_code,
            status.HTTP_400_BAD_REQUEST,
        )

    def test_admin_can_view_all_applications(self):
        self.create_application()
        self.client.force_authenticate(user=self.admin)

        response = self.client.get(
            "/api/workshops/admin/applications/"
        )

        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(len(response.data), 1)

    def test_admin_can_approve_application(self):
        application = self.create_application()
        self.client.force_authenticate(user=self.admin)

        response = self.client.patch(
            f"/api/workshops/admin/applications/{application.id}/review/",
            {"status": "APPROVED"},
            format="json",
        )

        self.assertEqual(response.status_code, status.HTTP_200_OK)

        application.refresh_from_db()
        self.customer.refresh_from_db()

        self.assertEqual(application.status, "APPROVED")
        self.assertEqual(self.customer.role, "WORKSHOP_OWNER")
        self.assertEqual(application.reviewed_by, self.admin)
        self.assertIsNotNone(application.reviewed_at)

    def test_admin_can_reject_application_with_reason(self):
        application = self.create_application()
        self.client.force_authenticate(user=self.admin)

        response = self.client.patch(
            f"/api/workshops/admin/applications/{application.id}/review/",
            {
                "status": "REJECTED",
                "admin_note": "Please provide valid business details.",
            },
            format="json",
        )

        self.assertEqual(response.status_code, status.HTTP_200_OK)

        application.refresh_from_db()
        self.customer.refresh_from_db()

        self.assertEqual(application.status, "REJECTED")
        self.assertEqual(self.customer.role, "CUSTOMER")
        self.assertEqual(
            application.admin_note,
            "Please provide valid business details.",
        )

    def test_rejection_requires_reason(self):
        application = self.create_application()
        self.client.force_authenticate(user=self.admin)

        response = self.client.patch(
            f"/api/workshops/admin/applications/{application.id}/review/",
            {"status": "REJECTED"},
            format="json",
        )

        self.assertEqual(
            response.status_code,
            status.HTTP_400_BAD_REQUEST,
        )

    def test_customer_cannot_review_application(self):
        application = self.create_application()
        self.client.force_authenticate(user=self.customer)

        response = self.client.patch(
            f"/api/workshops/admin/applications/{application.id}/review/",
            {"status": "APPROVED"},
            format="json",
        )

        self.assertEqual(
            response.status_code,
            status.HTTP_403_FORBIDDEN,
        )

    def test_application_cannot_be_reviewed_twice(self):
        application = self.create_application()
        application.status = "REJECTED"
        application.admin_note = "Rejected."
        application.save()

        self.client.force_authenticate(user=self.admin)

        response = self.client.patch(
            f"/api/workshops/admin/applications/{application.id}/review/",
            {"status": "APPROVED"},
            format="json",
        )

        self.assertEqual(
            response.status_code,
            status.HTTP_400_BAD_REQUEST,
        )

        self.customer.refresh_from_db()
        self.assertEqual(self.customer.role, "CUSTOMER")

from workshops.models import Workshop


class WorkshopCRUDTests(APITestCase):

    def setUp(self):
        self.owner = User.objects.create_user(
            username="owner1",
            email="owner1@example.com",
            password="TestPass123!",
            role="WORKSHOP_OWNER",
        )

        self.other_owner = User.objects.create_user(
            username="owner2",
            email="owner2@example.com",
            password="TestPass123!",
            role="WORKSHOP_OWNER",
        )

        self.customer = User.objects.create_user(
            username="customer1",
            email="customer1@example.com",
            password="TestPass123!",
            role="CUSTOMER",
        )

        self.admin = User.objects.create_user(
            username="admin2",
            email="admin2@example.com",
            password="TestPass123!",
            role="ADMIN",
        )

        self.workshop_data = {
            "name": "Smart Auto Care",
            "description": "Vehicle repair and maintenance.",
            "email": "smartauto@example.com",
            "phone": "03001234567",
        }

        self.workshop = Workshop.objects.create(
            owner=self.owner,
            **self.workshop_data,
        )

    def test_owner_can_create_workshop(self):
        self.client.force_authenticate(user=self.owner)

        response = self.client.post(
            "/api/workshops/",
            self.workshop_data,
            format="json",
        )

        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertEqual(
            Workshop.objects.filter(owner=self.owner).count(),
            2,
        )

    def test_owner_can_view_own_workshops(self):
        self.client.force_authenticate(user=self.owner)

        response = self.client.get("/api/workshops/")

        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(len(response.data), 1)

    def test_owner_cannot_view_other_owner_workshops(self):
        other_workshop = Workshop.objects.create(
            owner=self.other_owner,
            name="Other Workshop",
        )

        self.client.force_authenticate(user=self.owner)

        response = self.client.get(
            f"/api/workshops/{other_workshop.id}/"
        )

        self.assertEqual(response.status_code, status.HTTP_404_NOT_FOUND)

    def test_owner_can_update_own_workshop(self):
        self.client.force_authenticate(user=self.owner)

        response = self.client.patch(
            f"/api/workshops/{self.workshop.id}/",
            {"name": "Updated Workshop"},
            format="json",
        )

        self.assertEqual(response.status_code, status.HTTP_200_OK)

        self.workshop.refresh_from_db()
        self.assertEqual(self.workshop.name, "Updated Workshop")

    def test_owner_can_soft_delete_workshop(self):
        self.client.force_authenticate(user=self.owner)

        response = self.client.delete(
            f"/api/workshops/{self.workshop.id}/"
        )

        self.assertEqual(response.status_code, status.HTTP_204_NO_CONTENT)

        self.workshop.refresh_from_db()
        self.assertFalse(self.workshop.is_active)

    def test_owner_cannot_delete_other_owner_workshop(self):
        other_workshop = Workshop.objects.create(
            owner=self.other_owner,
            name="Other Workshop",
        )

        self.client.force_authenticate(user=self.owner)

        response = self.client.delete(
            f"/api/workshops/{other_workshop.id}/"
        )

        self.assertEqual(response.status_code, status.HTTP_404_NOT_FOUND)

        other_workshop.refresh_from_db()
        self.assertTrue(other_workshop.is_active)

    def test_customer_cannot_access_workshop_api(self):
        self.client.force_authenticate(user=self.customer)

        response = self.client.get("/api/workshops/")

        self.assertEqual(response.status_code, status.HTTP_403_FORBIDDEN)

    def test_admin_cannot_access_workshop_owner_api(self):
        self.client.force_authenticate(user=self.admin)

        response = self.client.get("/api/workshops/")

        self.assertEqual(response.status_code, status.HTTP_403_FORBIDDEN)

    
    def test_client_cannot_assign_workshop_to_another_owner(self):
        self.client.force_authenticate(user=self.owner)

        response = self.client.post(
            "/api/workshops/",
            {
                **self.workshop_data,
                "owner": self.other_owner.id,
            },
            format="json",
        )

        self.assertEqual(response.status_code, status.HTTP_201_CREATED)

        created_workshop = Workshop.objects.get(
            pk=response.data["id"]
        )

        self.assertEqual(created_workshop.owner, self.owner)
        self.assertNotEqual(created_workshop.owner, self.other_owner)


    def test_owner_cannot_update_other_owner_workshop(self):
        other_workshop = Workshop.objects.create(
            owner=self.other_owner,
            name="Private Workshop",
        )

        self.client.force_authenticate(user=self.owner)

        response = self.client.patch(
            f"/api/workshops/{other_workshop.id}/",
            {"name": "Hacked Workshop"},
            format="json",
        )

        self.assertEqual(response.status_code, status.HTTP_404_NOT_FOUND)

        other_workshop.refresh_from_db()
        self.assertEqual(other_workshop.name, "Private Workshop")
