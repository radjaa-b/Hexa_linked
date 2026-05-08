import { useLocation } from "react-router-dom";
import Topbar from "./Topbar";
import StaffContactAdminButton from "../contactAdmin/StaffContactAdminButton";
import "./PageWrapper.css";

const PageWrapper = ({ children, title }) => {
  const location = useLocation();

  return (
    <div className="pw-shell">
      <Topbar currentPath={location.pathname} />
      <div className="pw-body">
        <main className="pw-main">{children}</main>
      </div>

      <StaffContactAdminButton />
    </div>
  );
};

export default PageWrapper;