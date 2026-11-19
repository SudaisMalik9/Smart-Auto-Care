
from django.urls import path

from .views import (
    RegisterView,
    LoginView,
    LogoutView,
    ProfileView,
    WebsitePairingGenerateView,
    WebsitePairingExchangeView,
)

urlpatterns = [
    path("register/", RegisterView.as_view(), name="register"),
    path("login/", LoginView.as_view(), name="login"),
    path("logout/", LogoutView.as_view(), name="logout"),
    path("profile/", ProfileView.as_view(), name="profile"),

    path(
        "website-pairing/generate/",
        WebsitePairingGenerateView.as_view(),
        name="website-pairing-generate",
    ),
    path(
        "website-pairing/exchange/",
        WebsitePairingExchangeView.as_view(),
        name="website-pairing-exchange",
    ),
]
