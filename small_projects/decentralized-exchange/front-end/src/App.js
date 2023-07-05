import EnableWeb3 from "./enableWeb3";
import Homepage from "./Homepage";

function App() {
  if (window.ethereum) {
    return <Homepage />;
  } else {
    return <EnableWeb3 />;
  }
}

export default App;
