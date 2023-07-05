import { useState, useEffect } from "react";
import { ethers } from "ethers";
import "./App.css";
import Header from "./header";
import Exchange from "./swap";
import "bootstrap/dist/css/bootstrap.min.css";

function Homepage() {
  const [address, setAddress] = useState("");

  const provider = new ethers.providers.Web3Provider(window.ethereum);
  const signer = provider.getSigner();

  const connectWalletHandler = async () => {
    if (provider) {
      await provider.send("eth_requestAccounts");
      const loadedAddress = await signer.getAddress();
      setAddress(loadedAddress);
    } else {
      console.log("Install metamask");
    }
  };

  useEffect(() => {
    signer.getAddress().then((currentAddress) => setAddress(currentAddress));
  }, [address]);
  const isConnected = () => {
    if (address !== "") {
      return true;
    }
    return false;
  };

  if (isConnected() === true) {
    return (
      <section className="homepage">
        <Header />
        <div className="d-flex justify-content-center align-items-center">
          <Exchange />
        </div>
      </section>
    );
  } else {
    return (
      <div className="mask homepage">
        <div
          className="d-flex justify-content-center align-items-center"
          style={{ marginTop: "100px" }}
        >
          <div className="text-dark">
            <h2>connect your wallet to get started</h2>
          </div>
        </div>
        <div
          className="d-flex justify-content-center align-items-center text-white"
          style={{ marginTop: "50px" }}
        >
          <button
            className="btn btn-outline-light btn-lg"
            type="button"
            onClick={connectWalletHandler}
          >
            Connect Wallet
          </button>
        </div>
      </div>
    );
  }
}

export default Homepage;
