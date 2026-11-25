
from types import SimpleNamespace

from django.contrib.auth import get_user_model
from rest_framework import status
from rest_framework.authtoken.models import Token
from rest_framework.test import APITestCase

from .permissions import (
    IsAdmin,
    IsWorkshopOwner,
    IsCustomer,
    IsMechanic,
)


User = get_user_model()


class AuthenticationAPITests(APITestCase):

    register_url = "/api/auth/register/"
    login_url = "/api/auth/login/"
    logout_url = "/api/auth/logout/"
    profile_url = "/api/auth/profile/"

    def setUp(self):
        self.user = User.objects.create_user(
            username="testcustomer",
            email="customer@example.com",
            password="TestPassword!7391",
            role=User.Role.CUSTOMER,
        )

    def test_customer_registration(self):
        response = self.client.post(
            self.register_url,
            {
                "username": "newcustomer",
                "email": "newcustomer@example.com",
                "first_name": "Test",
                "last_name": "Customer",
                "password": "StrongPassword!7391",
                "password_confirm": "StrongPassword!7391",
                "role": "ADMIN",
            },
            format="json",
        )

        self.assertEqual(response.status_code, status.HTTP_201_CREATED)

        new_user = User.objects.get(username="newcustomer")

        self.assertEqual(new_user.role, User.Role.CUSTOMER)
        self.assertFalse(new_user.is_staff)
        self.assertFalse(new_user.is_superuser)

    def test_registration_rejects_password_mismatch(self):
        response = self.client.post(
            self.register_url,
            {
                "username": "anothercustomer",
                "email": "another@example.com",
                "password": "StrongPassword!7391",
                "password_confirm": "DifferentPassword!7391",
            },
            format="json",
        )

        self.assertEqual(
            response.status_code,
            status.HTTP_400_BAD_REQUEST,
        )

    def test_login_returns_token(self):
        response = self.client.post(
            self.login_url,
            {
                "username": "testcustomer",
                "password": "TestPassword!7391",
            },
            format="json",
        )

        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIn("token", response.data)
        self.assertTrue(response.data["token"])
        self.assertEqual(
            response.data["user"]["username"],
            "testcustomer",
        )
        self.assertEqual(
            response.data["user"]["role"],
            User.Role.CUSTOMER,
        )

    def test_login_with_email_returns_token(self):
        response = self.client.post(
            self.login_url,
            {
                "email": "customer@example.com",
                "password": "TestPassword!7391",
            },
            format="json",
        )

        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIn("token", response.data)
        self.assertEqual(
            response.data["user"]["username"],
            "testcustomer",
        )

    def test_login_with_email_is_case_insensitive(self):
        response = self.client.post(
            self.login_url,
            {
                "email": "CUSTOMER@EXAMPLE.COM",
                "password": "TestPassword!7391",
            },
            format="json",
        )

        self.assertEqual(response.status_code, status.HTTP_200_OK)

    def test_login_rejects_both_username_and_email(self):
        response = self.client.post(
            self.login_url,
            {
                "username": "testcustomer",
                "email": "customer@example.com",
                "password": "TestPassword!7391",
            },
            format="json",
        )

        self.assertEqual(
            response.status_code,
            status.HTTP_400_BAD_REQUEST,
        )
    def test_login_rejects_invalid_credentials(self):
        response = self.client.post(
            self.login_url,
            {
                "email": "customer@example.com",
                "password": "WrongPassword!7391",
            },
            format="json",
        )

        self.assertEqual(
            response.status_code,
            status.HTTP_400_BAD_REQUEST,
        )

    def test_authenticated_user_can_view_profile(self):
        token = Token.objects.create(user=self.user)

        self.client.credentials(
            HTTP_AUTHORIZATION=f"Token {token.key}"
        )

        response = self.client.get(self.profile_url)

        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data["username"], "testcustomer")

    def test_unauthenticated_user_cannot_view_profile(self):
        response = self.client.get(self.profile_url)

        self.assertEqual(
            response.status_code,
            status.HTTP_401_UNAUTHORIZED,
        )

    def test_logout_deletes_token(self):
        token = Token.objects.create(user=self.user)

        self.client.credentials(
            HTTP_AUTHORIZATION=f"Token {token.key}"
        )

        response = self.client.post(self.logout_url)

        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertFalse(
            Token.objects.filter(user=self.user).exists()
        )

    def test_role_permissions(self):
        permission_classes = {
            User.Role.ADMIN: IsAdmin,
            User.Role.WORKSHOP_OWNER: IsWorkshopOwner,
            User.Role.CUSTOMER: IsCustomer,
            User.Role.MECHANIC: IsMechanic,
        }

        for role, allowed_permission in permission_classes.items():
            user = User.objects.create_user(
                username=f"user_{role.lower()}",
                email=f"permission_{role.lower()}@example.com",
                password="TestPassword!7391",
                role=role,
            )

            request = SimpleNamespace(user=user)

            for permission_class in permission_classes.values():
                permission = permission_class()
                result = permission.has_permission(request, None)

                if permission_class == allowed_permission:
                    self.assertTrue(result)
                else:
                    self.assertFalse(result)
