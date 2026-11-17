from django.shortcuts import render


def admin_dashboard(request):
    return render(request, "admin/dashboard.html")


def workshop_dashboard(request):
    return render(request, "workshop/dashboard.html")
