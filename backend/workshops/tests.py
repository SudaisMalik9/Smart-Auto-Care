
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

from .models import (
    WorkshopBranch,
    BranchOperatingHours,
    WorkshopDepartment,
    WorkshopService,
)


class WorkshopManagementAPITests(APITestCase):

    def setUp(self):
        self.owner = User.objects.create_user(
            username="management_owner",
            email="management@example.com",
            password="TestPass123!",
            role="WORKSHOP_OWNER",
        )

        self.other_owner = User.objects.create_user(
            username="other_management_owner",
            email="other_management@example.com",
            password="TestPass123!",
            role="WORKSHOP_OWNER",
        )

        self.workshop = Workshop.objects.create(
            owner=self.owner,
            name="Management Workshop",
        )

        self.other_workshop = Workshop.objects.create(
            owner=self.other_owner,
            name="Other Management Workshop",
        )

        self.branch = WorkshopBranch.objects.create(
            workshop=self.workshop,
            name="Main Branch",
            address="Main Road",
            city="Lahore",
            is_primary=True,
        )

        self.other_branch = WorkshopBranch.objects.create(
            workshop=self.other_workshop,
            name="Other Branch",
            address="Other Road",
            city="Karachi",
            is_primary=True,
        )

        self.client.force_authenticate(user=self.owner)

    def test_owner_can_create_branch(self):
        response = self.client.post(
            f"/api/workshops/{self.workshop.id}/branches/",
            {
                "name": "Second Branch",
                "address": "Model Town",
                "city": "Lahore",
            },
            format="json",
        )

        self.assertEqual(response.status_code, status.HTTP_201_CREATED)

        branch = WorkshopBranch.objects.get(
            workshop=self.workshop,
            name="Second Branch",
        )

        self.assertFalse(branch.is_primary)
        self.assertTrue(branch.is_active)

    def test_first_branch_is_automatically_primary(self):
        new_workshop = Workshop.objects.create(
            owner=self.owner,
            name="New Workshop",
        )

        response = self.client.post(
            f"/api/workshops/{new_workshop.id}/branches/",
            {
                "name": "First Branch",
                "address": "Canal Road",
                "city": "Lahore",
            },
            format="json",
        )

        self.assertEqual(response.status_code, status.HTTP_201_CREATED)

        branch = WorkshopBranch.objects.get(
            workshop=new_workshop
        )

        self.assertTrue(branch.is_primary)

    def test_owner_cannot_access_another_owners_branches(self):
        response = self.client.get(
            f"/api/workshops/{self.other_workshop.id}/branches/"
        )

        self.assertEqual(
            response.status_code,
            status.HTTP_404_NOT_FOUND,
        )

    def test_owner_can_create_operating_hours(self):
        response = self.client.post(
            f"/api/workshops/branches/{self.branch.id}/operating-hours/",
            {
                "weekday": 0,
                "is_closed": False,
                "opening_time": "09:00:00",
                "closing_time": "18:00:00",
            },
            format="json",
        )

        self.assertEqual(response.status_code, status.HTTP_201_CREATED)

        hours = BranchOperatingHours.objects.get(
            branch=self.branch,
            weekday=0,
        )

        self.assertFalse(hours.is_closed)

    def test_duplicate_operating_hours_are_rejected(self):
        BranchOperatingHours.objects.create(
            branch=self.branch,
            weekday=0,
            is_closed=False,
            opening_time="09:00",
            closing_time="18:00",
        )

        response = self.client.post(
            f"/api/workshops/branches/{self.branch.id}/operating-hours/",
            {
                "weekday": 0,
                "is_closed": False,
                "opening_time": "10:00:00",
                "closing_time": "19:00:00",
            },
            format="json",
        )

        self.assertEqual(
            response.status_code,
            status.HTTP_400_BAD_REQUEST,
        )

    def test_closed_day_does_not_keep_opening_times(self):
        response = self.client.post(
            f"/api/workshops/branches/{self.branch.id}/operating-hours/",
            {
                "weekday": 6,
                "is_closed": True,
                "opening_time": "09:00:00",
                "closing_time": "18:00:00",
            },
            format="json",
        )

        self.assertEqual(response.status_code, status.HTTP_201_CREATED)

        hours = BranchOperatingHours.objects.get(
            branch=self.branch,
            weekday=6,
        )

        self.assertTrue(hours.is_closed)
        self.assertIsNone(hours.opening_time)
        self.assertIsNone(hours.closing_time)

    def test_owner_can_create_department(self):
        response = self.client.post(
            f"/api/workshops/branches/{self.branch.id}/departments/",
            {
                "name": "Mechanical",
                "description": "Engine and mechanical repairs.",
            },
            format="json",
        )

        self.assertEqual(response.status_code, status.HTTP_201_CREATED)

        department = WorkshopDepartment.objects.get(
            branch=self.branch,
            name="Mechanical",
        )

        self.assertTrue(department.is_active)

    def test_owner_can_create_service(self):
        department = WorkshopDepartment.objects.create(
            branch=self.branch,
            name="Mechanical",
        )

        response = self.client.post(
            f"/api/workshops/branches/{self.branch.id}/services/",
            {
                "department": department.id,
                "name": "Engine Oil Change",
                "description": "Engine oil replacement.",
                "price": "2500.00",
                "estimated_duration_minutes": 45,
            },
            format="json",
        )

        self.assertEqual(response.status_code, status.HTTP_201_CREATED)

        service = WorkshopService.objects.get(
            branch=self.branch,
            name="Engine Oil Change",
        )

        self.assertEqual(service.department, department)
        self.assertEqual(service.price, 2500)
        self.assertEqual(service.estimated_duration_minutes, 45)

    def test_service_cannot_use_department_from_another_branch(self):
        other_department = WorkshopDepartment.objects.create(
            branch=self.other_branch,
            name="Electrical",
        )

        response = self.client.post(
            f"/api/workshops/branches/{self.branch.id}/services/",
            {
                "department": other_department.id,
                "name": "Electrical Repair",
                "description": "Electrical system repair.",
                "price": "1500.00",
                "estimated_duration_minutes": 30,
            },
            format="json",
        )

        self.assertEqual(
            response.status_code,
            status.HTTP_400_BAD_REQUEST,
        )

    def test_negative_service_price_is_rejected(self):
        response = self.client.post(
            f"/api/workshops/branches/{self.branch.id}/services/",
            {
                "name": "Invalid Service",
                "description": "Invalid price test.",
                "price": "-100.00",
                "estimated_duration_minutes": 30,
            },
            format="json",
        )

        self.assertEqual(
            response.status_code,
            status.HTTP_400_BAD_REQUEST,
        )

    def test_owner_cannot_access_another_owners_services(self):
        response = self.client.get(
            f"/api/workshops/branches/{self.other_branch.id}/services/"
        )

        self.assertEqual(
            response.status_code,
            status.HTTP_404_NOT_FOUND,
        )
