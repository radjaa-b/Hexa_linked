import { useEffect, useRef, useState } from "react";
import { Html5Qrcode } from "html5-qrcode";
import PageWrapper from "../../components/layout/PageWrapper";
import {
  scanVisitorPass,
 scanResidentQR,
  markVisitorArrived,
} from "../../services/visitorRequestsService";

const QRScanner = () => {
  const scannerRef = useRef(null);
  const html5QrCodeRef = useRef(null);

  const [scanning, setScanning] = useState(false);
  const [result, setResult] = useState(null);
  const [qrType, setQrType] = useState(null);
  const [error, setError] = useState("");
  const [processing, setProcessing] = useState(false);

  const stopScanner = async () => {
    try {
      if (html5QrCodeRef.current && scanning) {
        await html5QrCodeRef.current.stop();
        await html5QrCodeRef.current.clear();
      }
    } catch (err) {
      console.warn("Scanner stop warning:", err);
    } finally {
      setScanning(false);
    }
  };

  const detectQrType = (decodedText) => {
    const code = decodedText.trim();

    if (code.startsWith("VST-")) return "visitor";
    if (code.startsWith("RES-")) return "resident";

    return "unknown";
  };

  const startScanner = async () => {
    setError("");
    setResult(null);
    setQrType(null);

    try {
      const html5QrCode = new Html5Qrcode("qr-reader");
      html5QrCodeRef.current = html5QrCode;

      await html5QrCode.start(
        { facingMode: "environment" },
        { fps: 10, qrbox: { width: 260, height: 260 } },
        async (decodedText) => {
          await stopScanner();

          try {
            setProcessing(true);
            setError("");
            setResult(null);
            setQrType(null);

            const code = decodedText.trim();
            const type = detectQrType(code);

            if (type === "unknown") {
              setError("Unknown QR code type. Please scan a valid visitor or resident QR.");
              return;
            }

            if (type === "visitor") {
              const data = await scanVisitorPass(code);
              setQrType("visitor");
              setResult(data);
              return;
            }

            if (type === "resident") {
              const data = await scanResidentQR(code);
              setQrType("resident");
              setResult(data);
            }
          } catch (err) {
            setResult(null);
            setQrType(null);

            const detail = err?.response?.data?.detail;

            if (detail?.includes("ARRIVED")) {
              setError("This visitor pass has already been used for entry.");
            } else if (detail?.includes("EXITED")) {
              setError("This visitor already exited the residence.");
            } else if (detail?.includes("REJECTED")) {
              setError("This visitor request was rejected.");
            } else if (detail?.includes("CANCELLED")) {
              setError("This visitor request was cancelled.");
            } else {
              setError(detail || "Invalid QR code.");
            }
          } finally {
            setProcessing(false);
          }
        }
      );

      setScanning(true);
    } catch (err) {
      console.error(err);
      setResult(null);
      setQrType(null);
      setError("Could not access camera. Allow camera permission and try again.");
    }
  };

  const handleAllowEntry = async () => {
    if (!result?.request_id || qrType !== "visitor") return;

    try {
      setProcessing(true);
      await markVisitorArrived(result.request_id);
      setError("");
      setResult((prev) => ({
        ...prev,
        status: "ARRIVED",
        message: "Visitor marked as arrived successfully.",
      }));
    } catch (err) {
      setResult(null);
      setQrType(null);
      setError(err?.response?.data?.detail || "Failed to mark visitor as arrived.");
    } finally {
      setProcessing(false);
    }
  };

  useEffect(() => {
    return () => {
      stopScanner();
    };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  const renderResultCard = () => {
    if (!result) return null;

    if (qrType === "resident") {
      return (
        <>
          <div
            style={{
              background: "#edfaf5",
              color: "#0F6E56",
              padding: "12px",
              borderRadius: "14px",
              fontWeight: "800",
              marginBottom: "20px",
            }}
          >
            ✅ {result.message}
          </div>

          <div
            style={{
              background: "#f8faf9",
              border: "1px solid #d7e7df",
              padding: "14px",
              borderRadius: "16px",
              marginBottom: "18px",
              fontWeight: "800",
              color: "#1c3b2e",
            }}
          >
            🏠 Resident Access
          </div>

          <p>
            <strong>Resident:</strong> {result.full_name || result.username}
          </p>
          <p>
            <strong>Username:</strong> {result.username}
          </p>
          <p>
            <strong>Email:</strong> {result.email}
          </p>
          <p>
            <strong>Phone:</strong> {result.phone_number || "N/A"}
          </p>
          <p>
            <strong>Unit:</strong> {result.unit_number || "N/A"}
          </p>
          <p>
            <strong>Status:</strong> {result.status}
          </p>

          <div
            style={{
              marginTop: "22px",
              background: "#edfaf5",
              color: "#0F6E56",
              padding: "14px",
              borderRadius: "16px",
              fontWeight: "800",
              textAlign: "center",
            }}
          >
            🚪 Resident access granted
          </div>
        </>
      );
    }

    return (
      <>
        <div
          style={{
            background: "#edfaf5",
            color: "#0F6E56",
            padding: "12px",
            borderRadius: "14px",
            fontWeight: "800",
            marginBottom: "20px",
          }}
        >
          ✅ {result.message}
        </div>

        <div
          style={{
            background: "#f8faf9",
            border: "1px solid #d7e7df",
            padding: "14px",
            borderRadius: "16px",
            marginBottom: "18px",
            fontWeight: "800",
            color: "#1c3b2e",
          }}
        >
          👤 Visitor Access
        </div>

        <p>
          <strong>Visitor:</strong> {result.visitor_name}
        </p>
        <p>
          <strong>Phone:</strong> {result.visitor_phone}
        </p>
        <p>
          <strong>Email:</strong> {result.visitor_email}
        </p>
        <p>
          <strong>Purpose:</strong> {result.purpose}
        </p>
        <p>
          <strong>Date:</strong> {result.visit_date}
        </p>
        <p>
          <strong>Time:</strong> {result.start_time} - {result.end_time}
        </p>
        <p>
          <strong>Resident:</strong> {result.resident_username}
        </p>
        <p>
          <strong>Unit:</strong> {result.unit_number}
        </p>
        <p>
          <strong>Status:</strong> {result.status}
        </p>

        {result.status === "APPROVED" && (
          <button
            onClick={handleAllowEntry}
            disabled={processing}
            style={{
              marginTop: "22px",
              width: "100%",
              background: "#1c3b2e",
              color: "#e8d9b5",
              padding: "14px",
              border: "none",
              borderRadius: "16px",
              fontSize: "15px",
              fontWeight: "800",
              cursor: processing ? "not-allowed" : "pointer",
              boxShadow: "0 8px 24px rgba(28,59,46,.25)",
              opacity: processing ? 0.7 : 1,
            }}
          >
            {processing ? "Updating..." : "🚪 Allow Entry"}
          </button>
        )}
      </>
    );
  };

  return (
    <PageWrapper>
      <div style={{ padding: "24px" }}>
        <h1 style={{ marginBottom: "8px" }}>Scan Access QR</h1>

        <p style={{ marginBottom: "24px", color: "#444" }}>
          Use the computer camera to scan a visitor pass or resident access QR.
        </p>

        <div
          style={{
            display: "grid",
            gridTemplateColumns: "1.2fr 0.8fr",
            gap: "24px",
            alignItems: "start",
          }}
        >
          <div
            style={{
              background: "#fff",
              padding: "24px",
              borderRadius: "24px",
              boxShadow: "0 14px 40px rgba(0,0,0,.08)",
            }}
          >
            <div
              id="qr-reader"
              ref={scannerRef}
              style={{
                width: "100%",
                minHeight: "360px",
                background: "#f5f5f5",
                borderRadius: "18px",
                overflow: "hidden",
              }}
            />

            <div
              style={{
                display: "flex",
                gap: "12px",
                marginTop: "18px",
              }}
            >
              <button
                onClick={startScanner}
                disabled={scanning || processing}
                style={{
                  background: "#1c3b2e",
                  color: "#e8d9b5",
                  border: "none",
                  padding: "12px 22px",
                  borderRadius: "14px",
                  fontWeight: "700",
                  cursor: scanning || processing ? "not-allowed" : "pointer",
                  boxShadow: "0 8px 25px rgba(28,59,46,.25)",
                  opacity: scanning || processing ? 0.7 : 1,
                }}
              >
                {scanning ? "📷 Scanning..." : "📷 Start Scanner"}
              </button>

              <button
                onClick={stopScanner}
                disabled={!scanning}
                style={{
                  background: "#f5f5f5",
                  color: "#555",
                  border: "none",
                  padding: "12px 22px",
                  borderRadius: "14px",
                  fontWeight: "700",
                  cursor: !scanning ? "not-allowed" : "pointer",
                  boxShadow: "0 8px 20px rgba(0,0,0,.08)",
                  opacity: !scanning ? 0.55 : 1,
                }}
              >
                ⛔ Stop
              </button>
            </div>
          </div>

          <div
            style={{
              background: "#fff",
              padding: "24px",
              borderRadius: "24px",
              boxShadow: "0 14px 40px rgba(0,0,0,.08)",
              minHeight: "430px",
            }}
          >
            {processing && <p>Checking QR code...</p>}

            {error && (
              <div
                style={{
                  color: "#dc2626",
                  background: "#fef2f2",
                  padding: "14px",
                  borderRadius: "14px",
                  fontWeight: "700",
                  lineHeight: "1.5",
                }}
              >
                {error}
              </div>
            )}

            {!result && !processing && !error && (
              <div
                style={{
                  color: "#888",
                  marginTop: "130px",
                  textAlign: "center",
                  fontWeight: "600",
                }}
              >
                📷 Waiting for QR scan
              </div>
            )}

            {renderResultCard()}
          </div>
        </div>
      </div>
    </PageWrapper>
  );
};

export default QRScanner;