import { useEffect, useRef, useState } from "react";
import { useLocation } from "react-router-dom";
import Topbar from "./Topbar";
import StaffContactAdminButton from "../contactAdmin/StaffContactAdminButton";
import EmergencyFireAlertModal from "../EmergencyFireAlertModal";
import axios from "../../api/axiosInstance";
import "./PageWrapper.css";

const PageWrapper = ({ children, title }) => {
  const location = useLocation();

  const [fireAlert, setFireAlert] = useState(null);
  const dismissedFireAlertIdsRef = useRef([]);

  const audioRef = useRef(new Audio("/sounds/sos-alarm.mp3"));

  const isSecurityPage = location.pathname.includes("/security");
  const isAdminPage = location.pathname.includes("/admin");

  useEffect(() => {
    if (!isSecurityPage && !isAdminPage) return;

    const checkFireAlerts = async () => {
      try {
        const response = await axios.get("/alerts");

        const fireAlerts = response.data.filter(
          (alert) =>
            alert.incident_type === "fire" &&
            alert.status !== "resolved" &&
            !dismissedFireAlertIdsRef.current.includes(alert.id)
        );

        if (fireAlerts.length === 0) {
          setFireAlert(null);
          audioRef.current.pause();
          audioRef.current.currentTime = 0;
          return;
        }

        const latestFire = fireAlerts[0];

        setFireAlert(latestFire);
        audioRef.current.loop = true;
        audioRef.current.play().catch(() => {});
      } catch (error) {
        console.error("Error checking fire alerts:", error);
      }
    };

    checkFireAlerts();

    const interval = setInterval(checkFireAlerts, 2000);

    return () => {
      clearInterval(interval);
      audioRef.current.pause();
      audioRef.current.currentTime = 0;
    };
  }, [isSecurityPage, isAdminPage]);

  const handleCloseFireAlert = () => {
    if (
      fireAlert?.id &&
      !dismissedFireAlertIdsRef.current.includes(fireAlert.id)
    ) {
      dismissedFireAlertIdsRef.current.push(fireAlert.id);
    }

    setFireAlert(null);
    audioRef.current.pause();
    audioRef.current.currentTime = 0;
  };

  const handleResolveFireAlert = async (id) => {
    try {
      await axios.patch(`/alerts/${id}/status`, {
        status: "resolved",
      });

      handleCloseFireAlert();
    } catch (error) {
      console.error(error);
    }
  };

  const handleInProgressFireAlert = async (id) => {
    try {
      await axios.patch(`/alerts/${id}/status`, {
        status: "in_progress",
      });

      handleCloseFireAlert();
    } catch (error) {
      console.error(error);
    }
  };

  return (
    <div className="pw-shell">
      <Topbar currentPath={location.pathname} />

      <div className="pw-body">
        <main className="pw-main">{children}</main>
      </div>

      <StaffContactAdminButton />

      <EmergencyFireAlertModal
        alert={fireAlert}
        onClose={handleCloseFireAlert}
        onResolve={handleResolveFireAlert}
        onInProgress={handleInProgressFireAlert}
        securityMode={isSecurityPage}
      />
    </div>
  );
};

export default PageWrapper;