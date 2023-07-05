import "bootstrap/dist/css/bootstrap.min.css";
import { Link } from "react-router-dom";

function Header() {
  return (
    <header>
      <nav
        className="navbar navbar-expand-lg navbar-dark me-auto"
        style={{ backgroundColor: "#2d3a3d" }}
      >
        <div className="navbar-nav me-auto">
          <Link to="/">
            <button
              type="button"
              className="btn btn-outline-light"
              style={{ marginLeft: "20px" }}
            >
              Swap
            </button>
          </Link>
        </div>
        <div className="navbar-nav ms-auto">
          <Link to="/provide-liquidity">
            <button
              type="button"
              className="btn btn-outline-light"
              style={{ marginRight: "20px" }}
            >
              Provide Liquidity
            </button>
          </Link>
          <Link to="/redeem">
            <button
              type="button"
              className="btn btn-outline-light"
              style={{ marginRight: "20px" }}
            >
              Redeem Shares
            </button>
          </Link>
        </div>
      </nav>
    </header>
  );
}

export default Header;
