
const statusContainer = document.getElementById("connection-status");
const qrDisplay = document.getElementById("qr-display");
const retryButton = document.getElementById("retry-button");
const csrfToken = document.querySelector(
    '#csrf-form input[name="csrfmiddlewaretoken"]'
)?.value;

let pollingTimer = null;
let expiryTimer = null;
let isChecking = false;

function showState(title, message) {
    statusContainer.innerHTML = "";

    const heading = document.createElement("h3");
    heading.textContent = title;

    const paragraph = document.createElement("p");
    paragraph.textContent = message;

    statusContainer.appendChild(heading);
    statusContainer.appendChild(paragraph);
}

function stopTimers() {
    if (pollingTimer) {
        clearTimeout(pollingTimer);
        pollingTimer = null;
    }

    if (expiryTimer) {
        clearTimeout(expiryTimer);
        expiryTimer = null;
    }

    isChecking = false;
}

function showPlaceholder(message) {
    qrDisplay.innerHTML = "";

    const placeholder = document.createElement("div");
    placeholder.className = "qr-placeholder";

    const icon = document.createElement("span");
    icon.textContent = "▦";

    placeholder.appendChild(icon);
    placeholder.appendChild(document.createTextNode(message));

    qrDisplay.appendChild(placeholder);
}

async function postRequest(url) {
    if (!csrfToken) {
        throw new Error("Security token missing. Refresh the page.");
    }

    const response = await fetch(url, {
        method: "POST",
        headers: {
            "Content-Type": "application/json",
            "X-CSRFToken": csrfToken
        },
        credentials: "same-origin",
        body: JSON.stringify({})
    });

    const data = await response.json().catch(() => ({}));

    if (!response.ok && response.status !== 202) {
        throw new Error(
            data.detail || "The request could not be completed."
        );
    }

    return { response, data };
}

async function checkApproval() {
    if (isChecking) return;

    isChecking = true;

    try {
        const { response, data } = await postRequest(
            "/website-api/pairing/exchange/"
        );

        if (response.status === 202 || data.status === "pending") {
            showState(
                "Waiting for Approval",
                data.message || "Scan the QR code and approve the login from your mobile app."
            );

            isChecking = false;
            pollingTimer = setTimeout(checkApproval, 2500);
            return;
        }

        if (data.status === "authenticated" && data.redirect_url) {
            stopTimers();
            showState("Login Approved", "Opening your Workshop Dashboard...");
            window.location.assign(data.redirect_url);
            return;
        }

        throw new Error(data.detail || "Pairing could not be completed.");

    } catch (error) {
        stopTimers();
        showState("Login Failed", error.message);
        showPlaceholder("Please generate a new QR code.");
        retryButton.disabled = false;
    }
}

async function generateQR() {
    stopTimers();

    retryButton.disabled = true;
    showPlaceholder("Generating secure QR code...");
    showState("Connecting", "Generating your secure login request.");

    try {
        const { data } = await postRequest(
            "/website-api/pairing/generate/"
        );

        if (!data.qr_image) {
            throw new Error("Backend did not return a QR image.");
        }

        const image = document.createElement("img");
        image.src = data.qr_image;
        image.alt = "Secure Workshop Owner login QR code";

        qrDisplay.innerHTML = "";
        qrDisplay.appendChild(image);

        showState(
            "Waiting for QR Scan",
            "Open the mobile app, scan this QR code and approve the login request."
        );

        retryButton.disabled = false;

        const expiry = Math.max(
            1,
            Number(data.expires_in_seconds) || 300
        );

        expiryTimer = setTimeout(() => {
            stopTimers();
            showState(
                "QR Code Expired",
                "This login request has expired. Generate a new QR code."
            );
            showPlaceholder("QR code expired.");
            retryButton.disabled = false;
        }, expiry * 1000);

        pollingTimer = setTimeout(checkApproval, 2500);

    } catch (error) {
        stopTimers();
        showState("Connection Failed", error.message);
        showPlaceholder("Unable to generate QR code.");
        retryButton.disabled = false;
    }
}

retryButton.addEventListener("click", generateQR);

generateQR();
