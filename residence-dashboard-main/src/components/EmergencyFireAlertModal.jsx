import React from "react";

const EmergencyFireAlertModal = ({
  alert,
  onClose,
 onResolve,
  onInProgress,
  securityMode = false,
}) => {
  if (!alert) return null;

  return (
    <div
      style={{
        position: "fixed",
        inset: 0,
        zIndex: 99999,
        background: "rgba(120, 0, 0, 0.92)",
        display: "flex",
        alignItems: "center",
        justifyContent: "center",
        padding: "24px",
        fontFamily: "system-ui, -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif",
      }}
    >
      <div
        style={{
          width: "min(720px, 94vw)",
          background: "#2b0f0f",
          border: "1px solid #ef4444",
          borderLeft: "10px solid #dc2626",
          borderRadius: "10px",
          padding: "34px",
          color: "#f8fafc",
          boxShadow: "0 22px 60px rgba(0,0,0,0.45)",
        }}
      >
        <h1
          style={{
            margin: "0 0 14px 0",
            color: "#fca5a5",
            fontSize: "34px",
            fontWeight: 700,
          }}
        >
          Fire Emergency Detected
        </h1>

        <p style={{ marginBottom: "22px", fontSize: "17px", color: "#f3f4f6" }}>
          Immediate attention is required. A fire alert has been reported by an IoT device.
        </p>

        <div
          style={{
            background: "#3f1515",
            border: "1px solid #7f1d1d",
            borderRadius: "8px",
            padding: "18px",
            marginBottom: "22px",
            lineHeight: "1.8",
          }}
        >
          <div><strong>Location:</strong> {alert.location || "Unknown"}</div>
          <div><strong>Description:</strong> {alert.description || "No description"}</div>
          <div><strong>Status:</strong> {alert.status}</div>
          <div><strong>Alert ID:</strong> #{alert.id}</div>
        </div>

        <div
          style={{
            marginBottom: "20px",
            padding: "12px",
            border: "1px solid #991b1b",
            borderRadius: "8px",
            color: "#fecaca",
            fontWeight: 600,
            textAlign: "center",
          }}
        >
          Emergency contact: Call 14 for firefighters
        </div>

        <div
  style={{
    display: "flex",
    gap: "12px",
    alignItems: "center",
    flexWrap: "wrap",
  }}
>

  {securityMode && (
    <>
      <button
        type="button"
        onClick={() => onInProgress(alert.id)}
        style={{
          background: "transparent",
          border: "1px solid #fca5a5",
          color: "#f8fafc",
          borderRadius: "6px",
          padding: "10px 20px",
          cursor: "pointer",
          fontSize: "15px",
        }}
      >
        Mark In Progress
      </button>

      <button
        type="button"
        onClick={() => onResolve(alert.id)}
        style={{
          background: "#991b1b",
          border: "1px solid #ef4444",
          color: "#ffffff",
          borderRadius: "6px",
          padding: "10px 20px",
          cursor: "pointer",
          fontSize: "15px",
        }}
      >
        Resolve
      </button>
    </>
  )}

  <button
    type="button"
    onClick={onClose}
    style={{
      background: "transparent",
      border: "1px solid #fca5a5",
      color: "#f8fafc",
      borderRadius: "6px",
      padding: "10px 20px",
      cursor: "pointer",
      fontSize: "15px",
    }}
  >
    Dismiss
  </button>

</div>
      </div>
    </div>
  );
};

export default EmergencyFireAlertModal;