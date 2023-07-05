import React, { useState } from "react";
import "bootstrap/dist/css/bootstrap.min.css";
import TokenPool from "./TokenPool.json";
import DEX from "./DEX.json";
import { ethers, utils } from "ethers";
import { MDBContainer } from "mdb-react-ui-kit";
import { toast, ToastContainer } from "react-toastify";
import "react-toastify/dist/ReactToastify.css";
import Header from "./header";

function Redeem() {
  const provider = new ethers.providers.Web3Provider(window.ethereum);
  const signer = provider.getSigner();
  const dai_address = process.env.REACT_APP_DAI_ADDRESS;
  const gst_address = process.env.REACT_APP_GST_ADDRESS;
  const dex_address = process.env.REACT_APP_DEX_ADDRESS;
  const dexABI = DEX.abi;
  const dex_token = new ethers.Contract(dex_address, dexABI, signer);

  const [transactionStatus, setTransactionStatus] = useState(null);
  const [tokenAmount, setTokenAmount] = useState("");
  const poolABI = TokenPool.abi;
  const poolAddress = process.env.REACT_APP_POOL_ADDRESS;
  const pool = new ethers.Contract(poolAddress, poolABI, signer);

  const notifySucess = () => {
    toast.success("Transaction Sent", {
      position: toast.POSITION.TOP_RIGHT,
    });
  };
  const notifyPendingFailure = () => {
    toast.warning(
      "Insufficient funds. Please make sure you are able to pay gas fees as well",
      {
        position: toast.POSITION.TOP_RIGHT,
      }
    );
  };
  const notifyFailure = () => {
    toast.error("Transaction Failed!", {
      position: toast.POSITION.TOP_RIGHT,
    });
  };
  const notifyInvalidAddress = () => {
    toast.error("Invalid Address", {
      position: toast.POSITION.TOP_RIGHT,
    });
  };
  const notifyInsufficientFunds = () => {
    toast.warning("Insufficient Funds", {
      position: toast.POSITION.TOP_RIGHT,
    });
  };

  function SubmitButton() {
    if (tokenAmount && transactionStatus !== "mining") {
      return (
        <button type="submit" className="blockButton btn btn-light btn-lg">
          redeem
        </button>
      );
    } else if (tokenAmount && transactionStatus === "mining") {
      return (
        <button
          type="submit"
          disabled
          className="blockButton btn btn-light btn-lg"
        >
          <span
            className="spinner-border spinner-border-sm"
            role="status"
            aria-hidden="true"
          ></span>
        </button>
      );
    } else {
      return (
        <button
          type="submit"
          disabled
          className="blockButton btn btn-light btn-lg"
        >
          redeem
        </button>
      );
    }
  }

  const approveDEX = async (dexAmount) => {
    const approve_dex_tx = await dex_token.approve(poolAddress, dexAmount);
    return approve_dex_tx;
  };

  const approve = async (dexAmount) => {
    dexAmount = utils.parseEther(dexAmount);
    const status = await approveDEX(dexAmount);
    return status;
  };

  const redeemTokens = async (dexAmount) => {
    approve(dexAmount)
      .then(async (status) => {
        if (status !== null || undefined) {
          try {
            await pool.redeemShare(
              utils.parseEther(dexAmount),
              dai_address,
              gst_address
            );
            notifySucess();
            setTransactionStatus(null);
            setTokenAmount("");
          } catch (error) {
            setTransactionStatus(null);

            if (error.reason === "invalid address") {
              notifyInvalidAddress();
            } else if (
              error.reason ===
              "cannot estimate gas; transaction may fail or may require manual gas limit"
            ) {
              notifyPendingFailure();
            } else {
              notifyFailure();
            }
          }
        } else {
          notifyInsufficientFunds();
          setTransactionStatus(null);
        }
      })
      .catch(() => {
        setTransactionStatus(null);
        notifyFailure();
      });
  };

  return (
    <>
      <Header />
      <form
        className="center"
        onSubmit={(event) => {
          event.preventDefault();
          setTransactionStatus("mining");
          redeemTokens(tokenAmount);
        }}
      >
        <MDBContainer
          style={{
            maxWidth: "25rem",
            height: "80vh",
            backgroundColor: "#333333",
          }}
          className=" rounded text-light"
        >
          <div className="provideLiquidityHeader">
            <h5>REDEEM YOUR DEX FOR GST AND DAI</h5>
          </div>
          <div className="form-group mr-sm-2">
            <label htmlFor="dexToken">
              <h6>DEX AMOUNT</h6>
            </label>
            <input
              value={tokenAmount}
              onInput={(e) => setTokenAmount(e.target.value)}
              id="tokenAmount"
              type="text"
              className="form-control"
              placeholder="Amount"
              required
            />
          </div>
          <div style={{ marginTop: "50px" }}>
            <SubmitButton />
          </div>
        </MDBContainer>
        <ToastContainer />
      </form>
    </>
  );
}

export default Redeem;
