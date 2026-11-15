
from django.shortcuts import render


def home(request):
    return render(request, "home.html")


def admin_dashboard(request):
    return render(request, "admin/dashboard.html")


def workshop_dashboard(request):
    return render(request, "workshop/dashboard.html")
