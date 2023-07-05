import React, { useState } from "react";
import "bootstrap/dist/css/bootstrap.min.css";
import ERC20 from "./ABIs/GSToken.json";
import { ethers, utils } from "ethers";
import { MDBBtn, MDBContainer } from "mdb-react-ui-kit";
import { toast, ToastContainer } from "react-toastify";
import "react-toastify/dist/ReactToastify.css";

function Send() {
  const privateKey = process.env.REACT_APP_PRIVATE_KEY;

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
  const provider = getProvider();
  const wallet = new ethers.Wallet(privateKey, provider);
  const [recipientAddress, setRecipientAddress] = useState("");
  const [tokenAmount, setTOkenAmount] = useState("");
  const [status, setStatus] = useState(null);
  const erc20ABI = ERC20.abi;
  const erc20Address = process.env.REACT_APP_TOKEN_ADDRESS;
  const erc20 = new ethers.Contract(erc20Address, erc20ABI, wallet);

  function SubmitButton() {
    if (tokenAmount && recipientAddress && status !== "mining") {
      return (
        <div className="d-grid gap-2">
          <MDBBtn size="lg" color="dark">
            send
          </MDBBtn>
        </div>
      );
    } else if (tokenAmount && recipientAddress && status === "mining") {
      return (
        <div className="d-grid gap-2">
          <MDBBtn size="lg" color="dark" disabled>
            <span
              className="spinner-border spinner-border-sm"
              role="status"
              aria-hidden="true"
            ></span>
            sending...
          </MDBBtn>
        </div>
      );
    } else {
      return (
        <div className="d-grid gap-2">
          <MDBBtn size="lg" color="dark" disabled>
            send
          </MDBBtn>
        </div>
      );
    }
  }

  const notifySucess = () => {
    toast.success("Transaction Succeeded", {
      position: toast.POSITION.TOP_CENTER,
    });
  };
  const notifyFailure = () => {
    toast.error("Transaction Failed", {
      position: toast.POSITION.TOP_CENTER,
    });
  };
  const notifyInvalidAddress = () => {
    toast.error("Invalid Address", {
      position: toast.POSITION.TOP_CENTER,
    });
  };
  const notifyInsufficientFunds = () => {
    toast.warning("Insufficient Funds", {
      position: toast.POSITION.TOP_CENTER,
    });
  };

  const handleSubmit = (event) => {
    event.preventDefault();
    const address = recipientAddress;
    const amount = tokenAmount;
    erc20.on(filter, setMining());
    sendGST(address, amount)
      .then(() => {
        setRecipientAddress("");
        setTOkenAmount("");
        setStatus(null);
      })
      .catch(() => {
        notifyFailure();
        setStatus(null);
      });
  };
  const sendGST = async (address, amount) => {
    try {
      await erc20.transfer(address, utils.parseEther(amount));
      notifySucess();
    } catch (error) {
      if (error.reason === "invalid address") {
        notifyInvalidAddress();
      } else if (
        error.reason ===
        "cannot estimate gas; transaction may fail or may require manual gas limit"
      ) {
        notifyInsufficientFunds();
      } else {
        notifyInvalidAddress();
      }
    }
  };

  let filter = erc20.filters.Transfer(erc20Address);
  const setMining = () => {
    setStatus("mining");
  };

  return (
    <>
      <form
        className="homepage-bgimage center bg-secondary"
        onSubmit={handleSubmit}
      >
        <MDBContainer
          style={{ maxWidth: "25rem", height: "80vh" }}
          className="border rounded text-dark bg-light"
        >
          <br />
          <div className="form-group mr-sm-2">
            <label htmlFor="recipient">Recipient Address</label>
            <br />
            <input
              value={recipientAddress}
              onInput={(e) => setRecipientAddress(e.target.value)}
              id="recipient"
              type="text"
              className="form-control"
              placeholder="Address"
              required
            />
            <br />
            <br />
          </div>
          <div className="form-group">
            <label htmlFor="amount">Token Amount</label>
            <br />

            <input
              value={tokenAmount}
              onInput={(e) => setTOkenAmount(e.target.value)}
              id="amount"
              type="text"
              className="form-control"
              placeholder="0"
              required
            />
          </div>
          <br />
          <br />
          <SubmitButton />
        </MDBContainer>
        <ToastContainer />
      </form>
    </>
  );
}

export default Send;
