
from django.shortcuts import render


def admin_login(request):
    return render(request, "website/admin_login.html")


def admin_dashboard(request):
    return render(request, "admin/dashboard.html")


def workshop_dashboard(request):
    return render(request, "workshop/dashboard.html")


def qr_pairing(request):
    return render(request, "website/qr_pairing.html")
