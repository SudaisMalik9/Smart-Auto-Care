
from rest_framework.test import APITestCase
from rest_framework import status

from accounts.models import User
from .models import CustomerProfile, CustomerVehicle


class CustomerAPITests(APITestCase):

    def setUp(self):
        self.customer = User.objects.create_user(
            username="customer1",
            email="customer1@example.com",
            password="TestPass123!",
            role="CUSTOMER",
        )

        self.other_customer = User.objects.create_user(
            username="customer2",
            email="customer2@example.com",
            password="TestPass123!",
            role="CUSTOMER",
        )

        self.admin = User.objects.create_user(
            username="admin1",
            email="admin1@example.com",
            password="TestPass123!",
            role="ADMIN",
        )

        self.profile = CustomerProfile.objects.create(
            user=self.customer,
            phone="03001234567",
            city="Lahore",
        )

        self.other_profile = CustomerProfile.objects.create(
            user=self.other_customer,
        )

        self.vehicle = CustomerVehicle.objects.create(
            customer=self.profile,
            make="Toyota",
            model="Corolla",
            year=2022,
        )

    def test_customer_can_view_profile(self):
        self.client.force_authenticate(user=self.customer)

        response = self.client.get("/api/customers/profile/")

        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data["username"], "customer1")

    def test_customer_can_update_profile(self):
        self.client.force_authenticate(user=self.customer)

        response = self.client.patch(
            "/api/customers/profile/",
            {"city": "Karachi"},
            format="json",
        )

        self.assertEqual(response.status_code, status.HTTP_200_OK)

        self.profile.refresh_from_db()
        self.assertEqual(self.profile.city, "Karachi")

    def test_customer_can_create_vehicle(self):
        self.client.force_authenticate(user=self.customer)

        response = self.client.post(
            "/api/customers/vehicles/",
            {
                "make": "Honda",
                "model": "Civic",
                "year": 2024,
                "color": "Black",
            },
            format="json",
        )

        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertEqual(
            CustomerVehicle.objects.filter(
                customer=self.profile
            ).count(),
            2,
        )

    def test_customer_can_list_own_vehicles(self):
        self.client.force_authenticate(user=self.customer)

        response = self.client.get("/api/customers/vehicles/")

        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(len(response.data), 1)

    def test_customer_can_update_own_vehicle(self):
        self.client.force_authenticate(user=self.customer)

        response = self.client.patch(
            f"/api/customers/vehicles/{self.vehicle.id}/",
            {"color": "White"},
            format="json",
        )

        self.assertEqual(response.status_code, status.HTTP_200_OK)

        self.vehicle.refresh_from_db()
        self.assertEqual(self.vehicle.color, "White")

    def test_customer_can_deactivate_own_vehicle(self):
        self.client.force_authenticate(user=self.customer)

        response = self.client.delete(
            f"/api/customers/vehicles/{self.vehicle.id}/delete/"
        )

        self.assertEqual(response.status_code, status.HTTP_200_OK)

        self.vehicle.refresh_from_db()
        self.assertFalse(self.vehicle.is_active)

    def test_customer_cannot_access_other_customer_vehicle(self):
        other_vehicle = CustomerVehicle.objects.create(
            customer=self.other_profile,
            make="Suzuki",
            model="Swift",
            year=2023,
        )

        self.client.force_authenticate(user=self.customer)

        response = self.client.get(
            f"/api/customers/vehicles/{other_vehicle.id}/"
        )

        self.assertEqual(response.status_code, status.HTTP_404_NOT_FOUND)

    def test_admin_cannot_access_customer_api(self):
        self.client.force_authenticate(user=self.admin)

        response = self.client.get("/api/customers/profile/")

        self.assertEqual(response.status_code, status.HTTP_403_FORBIDDEN)
