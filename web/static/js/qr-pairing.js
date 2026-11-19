
const statusContainer = document.getElementById("connection-status");
const qrDisplay = document.getElementById("qr-display");
const retryButton = document.getElementById("retry-button");

function showState(state) {
    switch (state) {

        case "waiting":
            statusContainer.innerHTML = `
                <h3>Waiting for QR Scan</h3>
                <p>Waiting for the mobile app to start pairing.</p>
            `;
            qrDisplay.innerHTML = `
                <p>Waiting for QR pairing setup.</p>
            `;
            break;

        case "qr":
            statusContainer.innerHTML = `
                <h3>QR Code Displayed</h3>
                <p>Scan the QR code using the Smart Auto Care mobile app.</p>
            `;
            qrDisplay.innerHTML = `
                <p>Development Sample: QR code placeholder.</p>
                <p>This is not a real or scannable QR code.</p>
            `;
            break;

        case "connecting":
            statusContainer.innerHTML = `
                <h3>Connecting...</h3>
                <p>Waiting for backend verification.</p>
            `;
            qrDisplay.innerHTML = `
                <p>Development Sample: Connection in progress.</p>
            `;
            break;

        case "connected":
            statusContainer.innerHTML = `
                <h3>Sample Connected State</h3>
                <p>Development preview only. No device is actually connected.</p>
            `;
            qrDisplay.innerHTML = "";
            break;

        case "expired":
            statusContainer.innerHTML = `
                <h3>QR Code Expired</h3>
                <p>This sample QR session has expired.</p>
            `;
            qrDisplay.innerHTML = "";
            break;

        case "failed":
            statusContainer.innerHTML = `
                <h3>Connection Failed</h3>
                <p>Pairing could not be completed. Please try again.</p>
            `;
            qrDisplay.innerHTML = "";
            break;
    }
}

// Development-only sample state controls
document.querySelectorAll("[data-state]").forEach(button => {
    button.addEventListener("click", () => {
        showState(button.dataset.state);
    });
});

// Development-only retry interface
retryButton.addEventListener("click", () => {
    showState("waiting");
});

// Initial state
showState("waiting");
