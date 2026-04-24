import PageWrapper from "../../components/layout/PageWrapper";
import "./ImportantNumbers.css";

const emergencyNumbers = [
  {
    label: "Civil Protection",
    description: "Fire, rescue, ambulance and urgent accidents.",
    number: "14",
    tag: "Fire / Ambulance",
    type: "danger",
  },
  {
    label: "National Security",
    description: "Police assistance, crimes, threats and public safety.",
    number: "1548",
    tag: "Police",
    type: "security",
  },
  {
    label: "National Gendarmerie",
    description: "Inter-city, rural areas and road security support.",
    number: "1055",
    tag: "Gendarmerie",
    type: "security",
  },
  {
    label: "General Inquiries",
    description: "General phone information and assistance.",
    number: "19",
    tag: "Information",
    type: "info",
  },
];

const ImportantNumbers = () => {
  return (
    <PageWrapper>
      <div className="numbers-layout">
        <div className="numbers-hero">
          <div className="numbers-hero-hex">
            <svg width="160" height="140" viewBox="0 0 160 140" fill="none">
              <path
                d="M80 8L144 44V116L80 152L16 116V44L80 8Z"
                stroke="white"
                strokeWidth="1"
                opacity="0.15"
              />
              <path
                d="M80 32L120 55V101L80 124L40 101V55L80 32Z"
                stroke="white"
                strokeWidth="0.8"
                opacity="0.1"
              />
            </svg>
          </div>

          <div className="numbers-hero-tag">Security Agent</div>
          <div className="numbers-hero-title">Important Numbers</div>
          <p className="numbers-hero-sub">
            Quick access to emergency contacts used in Algeria.
          </p>
        </div>

        <div className="numbers-grid">
          {emergencyNumbers.map((item) => (
            <div key={item.number} className={`number-card ${item.type}`}>
              <div className="number-card-top">
                <span className="number-tag">{item.tag}</span>
                <span className="number-main">{item.number}</span>
              </div>

              <h3>{item.label}</h3>
              <p>{item.description}</p>

              <a className="number-call-btn" href={`tel:${item.number}`}>
                Call {item.number}
              </a>
            </div>
          ))}
        </div>

        <div className="numbers-note">
          Keep these numbers visible for the security team during incident
          handling. 
        </div>

        <div className="numbers-contact">
  <div className="numbers-contact-title">Admin Contact</div>

  <div className="numbers-contact-row">
    <span className="numbers-contact-label">Email</span>

    <a
      href="mailto:hexagate.admin@gmail.com"
      className="numbers-contact-email"
    >
      radjabennamoun05@gmail.com
    </a>
  </div>
</div>
      </div>
    </PageWrapper>
  );
};

export default ImportantNumbers;