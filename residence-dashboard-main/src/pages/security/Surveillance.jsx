import { useState, useEffect, useRef } from "react";
import PageWrapper from "../../components/layout/PageWrapper";
import "./Surveillance.css";

// ============================================================
// Radja: this page is a simulated camera feed dashboard.
// In production, replace the canvas simulation with real
// RTSP/HLS video streams using a video player library.
//
// Each camera should have:
// GET /security/cameras → list of cameras with status
// WebSocket: "camera.alert" event → highlight camera in red
// ============================================================

const cameras = [
  { id: "cam-1", name: "Main gate",        location: "Gate 1",          status: "online",  alert: true  },
  { id: "cam-2", name: "Secondary gate",   location: "Gate 2",          status: "online",  alert: false },
  { id: "cam-3", name: "Parking zone A",   location: "Parking A",       status: "online",  alert: false },
  { id: "cam-4", name: "Parking zone B",   location: "Parking B",       status: "offline", alert: false },
  { id: "cam-5", name: "Building A entry", location: "Building A",      status: "online",  alert: false },
  { id: "cam-6", name: "Building B entry", location: "Building B",      status: "online",  alert: false },
  { id: "cam-7", name: "Pool area",        location: "Common area",     status: "online",  alert: false },
  { id: "cam-8", name: "Basement parking", location: "Basement",        status: "online",  alert: true  },
];

// Simulated camera feed using canvas
const CameraFeed = ({ camera, isSelected }) => {
  const canvasRef = useRef(null);
  const animRef   = useRef(null);
  const timeRef   = useRef(0);

  useEffect(() => {
    if (camera.status === "offline") return;
    const canvas = canvasRef.current;
    if (!canvas) return;
    const ctx = canvas.getContext("2d");
    let frame = 0;

    // Simple noise particles to simulate camera grain
    const particles = Array.from({ length: 60 }, () => ({
      x: Math.random() * canvas.width,
      y: Math.random() * canvas.height,
      r: Math.random() * 1.5,
      dx: (Math.random() - 0.5) * 0.4,
      dy: (Math.random() - 0.5) * 0.4,
      opacity: Math.random() * 0.4 + 0.1,
    }));

    const draw = () => {
      frame++;
      ctx.fillStyle = camera.alert ? "#1a0a0a" : "#0a0f0a";
      ctx.fillRect(0, 0, canvas.width, canvas.height);

      // Grid lines for depth effect
      ctx.strokeStyle = camera.alert
        ? "rgba(200,50,50,0.06)"
        : "rgba(29,158,117,0.06)";
      ctx.lineWidth = 0.5;
      for (let x = 0; x < canvas.width; x += 20) {
        ctx.beginPath();
        ctx.moveTo(x, 0);
        ctx.lineTo(x, canvas.height);
        ctx.stroke();
      }
      for (let y = 0; y < canvas.height; y += 20) {
        ctx.beginPath();
        ctx.moveTo(0, y);
        ctx.lineTo(canvas.width, y);
        ctx.stroke();
      }

      // Moving particles
      particles.forEach((p) => {
        p.x += p.dx;
        p.y += p.dy;
        if (p.x < 0) p.x = canvas.width;
        if (p.x > canvas.width) p.x = 0;
        if (p.y < 0) p.y = canvas.height;
        if (p.y > canvas.height) p.y = 0;
        ctx.beginPath();
        ctx.arc(p.x, p.y, p.r, 0, Math.PI * 2);
        ctx.fillStyle = camera.alert
          ? `rgba(255,100,100,${p.opacity})`
          : `rgba(93,202,165,${p.opacity})`;
        ctx.fill();
      });

      // Scan line effect
      const scanY = (frame * 1.5) % canvas.height;
      const grad = ctx.createLinearGradient(0, scanY - 8, 0, scanY + 8);
      grad.addColorStop(0, "rgba(0,0,0,0)");
      grad.addColorStop(0.5, camera.alert
        ? "rgba(255,80,80,0.08)"
        : "rgba(93,202,165,0.08)");
      grad.addColorStop(1, "rgba(0,0,0,0)");
      ctx.fillStyle = grad;
      ctx.fillRect(0, scanY - 8, canvas.width, 16);

      // Alert pulse ring in center
      if (camera.alert) {
        const pulse = Math.sin(frame * 0.05) * 0.5 + 0.5;
        ctx.beginPath();
        ctx.arc(canvas.width / 2, canvas.height / 2, 20 + pulse * 8, 0, Math.PI * 2);
        ctx.strokeStyle = `rgba(255,80,80,${0.4 + pulse * 0.4})`;
        ctx.lineWidth = 1.5;
        ctx.stroke();
        ctx.beginPath();
        ctx.arc(canvas.width / 2, canvas.height / 2, 6, 0, Math.PI * 2);
        ctx.fillStyle = `rgba(255,80,80,${0.6 + pulse * 0.4})`;
        ctx.fill();
      }

      // Corner brackets (camera frame effect)
      const bColor = camera.alert ? "rgba(255,80,80,0.5)" : "rgba(93,202,165,0.4)";
      const bSize  = 10;
      const bPad   = 6;
      ctx.strokeStyle = bColor;
      ctx.lineWidth   = 1.5;
      [[bPad, bPad], [canvas.width - bPad, bPad],
       [bPad, canvas.height - bPad], [canvas.width - bPad, canvas.height - bPad]
      ].forEach(([cx, cy], idx) => {
        const xDir = idx % 2 === 0 ? 1 : -1;
        const yDir = idx < 2      ? 1 : -1;
        ctx.beginPath();
        ctx.moveTo(cx, cy + yDir * bSize);
        ctx.lineTo(cx, cy);
        ctx.lineTo(cx + xDir * bSize, cy);
        ctx.stroke();
      });

      animRef.current = requestAnimationFrame(draw);
    };

    animRef.current = requestAnimationFrame(draw);
    return () => cancelAnimationFrame(animRef.current);
  }, [camera.alert, camera.status]);

  if (camera.status === "offline") {
    return (
      <div className="cam-offline">
        <svg width="24" height="24" viewBox="0 0 24 24" fill="none"
          stroke="rgba(255,255,255,0.2)" strokeWidth="1.5">
          <path d="M23 7l-7 5 7 5V7z"/>
          <rect x="1" y="5" width="15" height="14" rx="2" ry="2"/>
          <line x1="1" y1="1" x2="23" y2="23"/>
        </svg>
        <span>Signal lost</span>
      </div>
    );
  }

  return <canvas ref={canvasRef} className="cam-canvas" width={320} height={180}/>;
};

// Live clock component
const LiveClock = () => {
  const [time, setTime] = useState(new Date());
  useEffect(() => {
    const t = setInterval(() => setTime(new Date()), 1000);
    return () => clearInterval(t);
  }, []);
  return (
    <span className="cam-clock">
      {time.toLocaleTimeString("en-GB", { hour: "2-digit", minute: "2-digit", second: "2-digit" })}
    </span>
  );
};

const Surveillance = () => {
  const [selected,  setSelected]  = useState(null);
  const [cameraList, setCameraList] = useState(cameras);

  const onlineCount  = cameraList.filter((c) => c.status === "online").length;
  const offlineCount = cameraList.filter((c) => c.status === "offline").length;
  const alertCount   = cameraList.filter((c) => c.alert).length;

  return (
    <PageWrapper>
      <div className="surv-layout">

        {/* ── Hero ── */}
        <div className="surv-hero">
          <div className="surv-hero-hex">
            <svg width="160" height="140" viewBox="0 0 160 140" fill="none">
              <path d="M80 8L144 44V116L80 152L16 116V44L80 8Z"
                stroke="white" strokeWidth="1" opacity="0.15"/>
              <path d="M80 32L120 55V101L80 124L40 101V55L80 32Z"
                stroke="white" strokeWidth="0.8" opacity="0.1"/>
            </svg>
          </div>
          <div className="surv-hero-left">
            <div className="surv-hero-tag">Security agent</div>
            <div className="surv-hero-title">
              Live Surveillance
              {alertCount > 0 && (
                <span className="surv-alert-badge">{alertCount} alerts</span>
              )}
            </div>
            <div className="surv-hero-stats">
              <div className="surv-hs">
                <span className="surv-hs-val">{cameraList.length}</span>
                <span className="surv-hs-label">Total cameras</span>
              </div>
              <div className="surv-hs-div"/>
              <div className="surv-hs">
                <span className="surv-hs-val" style={{ color: "#5DCAA5" }}>{onlineCount}</span>
                <span className="surv-hs-label">Online</span>
              </div>
              <div className="surv-hs-div"/>
              <div className="surv-hs">
                <span className="surv-hs-val" style={{ color: "#f08080" }}>{offlineCount}</span>
                <span className="surv-hs-label">Offline</span>
              </div>
              <div className="surv-hs-div"/>
              <div className="surv-hs">
                <span className="surv-hs-val" style={{ color: "#f08080" }}>{alertCount}</span>
                <span className="surv-hs-label">With alerts</span>
              </div>
            </div>
          </div>
          <div className="surv-hero-right">
            <div className="surv-live-indicator">
              <span className="surv-live-dot"/>
              LIVE
            </div>
            <LiveClock/>
          </div>
        </div>

        {/* ── Camera grid ── */}
        <div className="surv-grid">
          {cameraList.map((camera) => (
            <div
              key={camera.id}
              className={`surv-cam ${camera.alert ? "alert" : ""} ${camera.status === "offline" ? "offline" : ""} ${selected === camera.id ? "selected" : ""}`}
              onClick={() => setSelected(selected === camera.id ? null : camera.id)}
            >
              {/* Feed */}
              <div className="surv-cam-feed">
                <CameraFeed camera={camera} isSelected={selected === camera.id}/>

                {/* Overlay info */}
                <div className="surv-cam-overlay">
                  <div className="surv-cam-top">
                    <span className="surv-cam-id">{camera.id.toUpperCase()}</span>
                    {camera.alert && (
                      <span className="surv-cam-alert-pill">ALERT</span>
                    )}
                  </div>
                  <div className="surv-cam-bottom">
                    <LiveClock/>
                  </div>
                </div>
              </div>

              {/* Label */}
              <div className="surv-cam-label">
                <div className="surv-cam-name">{camera.name}</div>
                <div className="surv-cam-loc">{camera.location}</div>
                <div className={`surv-cam-status ${camera.status}`}>
                  <span className="surv-status-dot"/>
                  {camera.status === "online" ? "Online" : "Offline"}
                </div>
              </div>
            </div>
          ))}
        </div>

      </div>
    </PageWrapper>
  );
};

export default Surveillance;