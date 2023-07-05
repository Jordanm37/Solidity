import { BrowserRouter as Router, Routes, Route } from "react-router-dom";

import App from "./App";
import Send from "./provideLiquidity";
import Redeem from "./reedemShares";

const AppRouter = () => {
  return (
    <Router>
      <Routes>
        <Route path="/" element={<App />} />
        <Route path="/provide-liquidity" element={<Send />} />
        <Route path="/redeem" element={<Redeem />} />
      </Routes>
    </Router>
  );
};

export default AppRouter;
