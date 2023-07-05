import React, { useState } from "react";
import { ethers } from "ethers";
import "bootstrap/dist/css/bootstrap.min.css";
import {
  MDBCard,
  MDBCardTitle,
  MDBCardText,
  MDBCardOverlay,
  MDBCardImage,
  MDBCardBody,
  MDBCardHeader,
  MDBBtn,
} from "mdb-react-ui-kit";
import { Link } from "react-router-dom";
import ERC20 from "./ABIs/GSToken.json";
import "./App.css";
import walletBackground from "./assets/dark-knight.jpg";
import bgImage from "./assets/bg1.jpg";

function App() {
  const getProvider = () => {
    try {
      const provider = new ethers.providers.InfuraProvider(
        "kovan",
        process.env.REACT_APP_INFURA_ID
      );
      return provider;
    } catch (error) {
      console.log("No wallet found");
    }
  };

  const [balance, setBalance] = useState(0);
  const [GSTBalance, setGSTBalance] = useState(0);
  const [myAdress, setMyAddress] = useState("");
  const privateKey = process.env.REACT_APP_PRIVATE_KEY;
  const provider = getProvider();
  const wallet = new ethers.Wallet(privateKey, provider);
  const account = () => {
    wallet.getAddress().then((walletAddress) => setMyAddress(walletAddress));
    return myAdress;
  };

  const accountAddress = account();

  const erc20ABI = ERC20.abi;
  const erc20Address = process.env.REACT_APP_TOKEN_ADDRESS;
  const erc20 = new ethers.Contract(erc20Address, erc20ABI, wallet);

  const fetchGSTBalance = async () => {
    const tokenBalance = await erc20.balanceOf(wallet.getAddress());
    return tokenBalance;
  };
  const getGSTBalance = () => {
    fetchGSTBalance()
      .then((value) => {
        value = ethers.utils.formatEther(value);
        return value;
      })
      .then((GSTBalance) => setGSTBalance(GSTBalance));
  };
  const ghostBalance = () => {
    getGSTBalance();
    return GSTBalance;
  };
  const fetchBalance = async () => {
    const fetchedBalance = await wallet.getBalance();
    return fetchedBalance;
  };

  const walletBalance = () => {
    fetchBalance()
      .then((value) => {
        value = ethers.utils.formatEther(value);
        return value;
      })
      .then((ethBalance) => setBalance(ethBalance))
      .catch((err) => console.log(err));
  };
  const newBalance = () => {
    walletBalance();
    return balance;
  };
  const myGSTBalance = ghostBalance();
  const myETHBalance = newBalance();

  return (
    <>
      <section
        className="homepage-bgimage center"
        style={{ backgroundImage: `url(${bgImage})` }}
      >
        <MDBCard
          background="dark"
          className="text-white"
          style={{ maxWidth: "25rem" }}
          alignment="center"
        >
          <MDBCardImage overlay src={walletBackground} />
          <MDBCardOverlay>
            <MDBCardHeader className="border">
              <MDBCardTitle>GHOST WALLET</MDBCardTitle>
            </MDBCardHeader>
            <br />
            <MDBCardBody className="shadow-lg p-3 mb-5 border rounded">
              <MDBCardHeader className="rounded shadow-5 border-bottom">
                <MDBCardTitle>ADRESSS</MDBCardTitle>
              </MDBCardHeader>
              <br />
              <MDBCardText>{accountAddress}</MDBCardText>
            </MDBCardBody>
            <MDBCardBody className="shadow-lg p-3 mb-5 border rounded">
              <MDBCardHeader className="border-bottom">
                <MDBCardTitle>BALANCES</MDBCardTitle>
              </MDBCardHeader>
              <br />
              <MDBCardText>{myGSTBalance} GST</MDBCardText>
              <MDBCardText>{myETHBalance} ETH</MDBCardText>
            </MDBCardBody>
            <Link to="/send">
              <div className="d-grid gap-2">
                <MDBBtn size="lg">send</MDBBtn>
              </div>
            </Link>
          </MDBCardOverlay>
        </MDBCard>
      </section>
    </>
  );
}
export default App;
