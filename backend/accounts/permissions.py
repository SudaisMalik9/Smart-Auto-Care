
from rest_framework.permissions import BasePermission


class RolePermission(BasePermission):
    allowed_roles = []

    def has_permission(self, request, view):
        return (
            request.user
            and request.user.is_authenticated
            and request.user.role in self.allowed_roles
        )


class IsAdmin(RolePermission):
    allowed_roles = ["ADMIN"]


class IsWorkshopOwner(RolePermission):
    allowed_roles = ["WORKSHOP_OWNER"]


class IsCustomer(RolePermission):
    allowed_roles = ["CUSTOMER"]


class IsMechanic(RolePermission):
    allowed_roles = ["MECHANIC"]
