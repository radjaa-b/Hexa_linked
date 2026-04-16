import { useLocation } from "react-router-dom";
import Topbar from "./Topbar";
import "./PageWrapper.css";

// Wraps every protected page with the topbar + layout
// Usage: wrap any page content with <PageWrapper title="Page title">

const PageWrapper = ({ children, title }) => {
  const location = useLocation();

  return (
    <div className="pw-shell">
      <Topbar currentPath={location.pathname} />
      <div className="pw-body">
        <main className="pw-main">
          {children}
        </main>
      </div>
    </div>
  );
};

export default PageWrapper;