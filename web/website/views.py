
import base64
import json
from io import BytesIO
from urllib.error import HTTPError, URLError
from urllib.request import Request, urlopen

import qrcode

from django.conf import settings
from django.http import JsonResponse
from django.shortcuts import redirect, render
from django.urls import reverse
from django.views.decorators.http import require_POST


def backend_post(endpoint, payload):
    base_url = getattr(
        settings,
        "BACKEND_API_URL",
        "http://127.0.0.1:8000/api/",
    )

    url = base_url.rstrip("/") + "/" + endpoint.lstrip("/")

    request = Request(
        url,
        data=json.dumps(payload).encode("utf-8"),
        headers={"Content-Type": "application/json"},
        method="POST",
    )

    try:
        with urlopen(request, timeout=10) as response:
            data = json.loads(response.read().decode("utf-8"))
            return response.status, data

    except HTTPError as error:
        try:
            data = json.loads(error.read().decode("utf-8"))
        except (ValueError, UnicodeDecodeError):
            data = {"detail": "Backend request failed."}

        return error.code, data

    except (URLError, TimeoutError, OSError):
        return 503, {"detail": "Cannot connect to the backend server."}


def make_qr_data_uri(code):
    image = qrcode.make(code)
    buffer = BytesIO()
    image.save(buffer, format="PNG")

    encoded = base64.b64encode(buffer.getvalue()).decode("ascii")
    return f"data:image/png;base64,{encoded}"


def admin_login(request):
    return render(request, "website/admin_login.html")


def admin_dashboard(request):
    return render(request, "admin/dashboard.html")


def workshop_dashboard(request):
    if not request.session.get("website_authenticated"):
        return redirect("qr_pairing")

    user = request.session.get("website_user", {})

    if user.get("role") != "WORKSHOP_OWNER":
        request.session.flush()
        return redirect("qr_pairing")

    return render(request, "workshop/dashboard.html")


def qr_pairing(request):
    if request.session.get("website_authenticated"):
        user = request.session.get("website_user", {})

        if user.get("role") == "WORKSHOP_OWNER":
            return redirect("workshop_dashboard")

        request.session.flush()

    return render(request, "website/qr_pairing.html")


@require_POST
def pairing_generate(request):
    status_code, data = backend_post(
        "auth/website-pairing/generate/",
        {},
    )

    if status_code != 201 or not data.get("code"):
        return JsonResponse(
            {"detail": data.get("detail", "QR generation failed.")},
            status=status_code if status_code >= 400 else 502,
        )

    code = data["code"]

    request.session["website_pairing_code"] = code
    request.session.set_expiry(300)

    return JsonResponse({
        "qr_image": make_qr_data_uri(code),
        "expires_in_seconds": data.get("expires_in_seconds", 300),
    })


@require_POST
def pairing_exchange(request):
    code = request.session.get("website_pairing_code")

    if not code:
        return JsonResponse(
            {"detail": "Pairing session expired. Generate a new QR code."},
            status=400,
        )

    status_code, data = backend_post(
        "auth/website-pairing/exchange/",
        {"code": code},
    )

    if status_code == 202:
        return JsonResponse({
            "status": "pending",
            "message": "Waiting for Workshop Owner approval.",
        }, status=202)

    if status_code != 200 or not data.get("token"):
        request.session.pop("website_pairing_code", None)

        return JsonResponse({
            "status": "failed",
            "detail": data.get("detail", "Pairing failed or expired."),
        }, status=status_code if status_code >= 400 else 502)

    user = data.get("user") or {}

    if user.get("role") != "WORKSHOP_OWNER":
        request.session.flush()
        return JsonResponse(
            {"detail": "Only Workshop Owners can access this website."},
            status=403,
        )

    # Rotate the session key after successful authentication.
    request.session.cycle_key()

    # Keep the backend token on the server, never in browser JavaScript.
    request.session["website_access_token"] = data["token"]
    request.session["website_user"] = user
    request.session["website_authenticated"] = True
    request.session.pop("website_pairing_code", None)

    # QR expires in 5 minutes; authenticated website session lasts 8 hours.
    request.session.set_expiry(8 * 60 * 60)

    return JsonResponse({
        "status": "authenticated",
        "redirect_url": reverse("workshop_dashboard"),
    })
@require_POST
def website_logout(request):
    request.session.flush()
    return redirect("qr_pairing")