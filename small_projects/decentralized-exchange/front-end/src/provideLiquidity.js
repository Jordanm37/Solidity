import React, { useState } from "react";
import "bootstrap/dist/css/bootstrap.min.css";
import TokenPool from "./TokenPool.json";
import DAI from "./DAI.json";
import GSToken from "./GSToken.json";
import { ethers, utils } from "ethers";
import { MDBContainer } from "mdb-react-ui-kit";
import { toast, ToastContainer } from "react-toastify";
import "react-toastify/dist/ReactToastify.css";
import Header from "./header";

function Send() {
  const provider = new ethers.providers.Web3Provider(window.ethereum);
  const signer = provider.getSigner();
  const dai_address = process.env.REACT_APP_DAI_ADDRESS;
  const gst_address = process.env.REACT_APP_GST_ADDRESS;
  const daiABI = DAI.abi;
  const gstABI = GSToken.abi;
  const dai_token = new ethers.Contract(dai_address, daiABI, signer);
  const gst_token = new ethers.Contract(gst_address, gstABI, signer);

  // const [status, setStatus] = useState(null);
  const [transactionStatus, setTransactionStatus] = useState(null);

  const [tokenAmount1, setTokenAmount1] = useState("");
  const [tokenAmount2, setTokenAmount2] = useState("");
  // const [approval, setApproval] = useState();
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
    if (tokenAmount1 && tokenAmount2 && transactionStatus !== "mining") {
      return (
        <button type="submit" className="blockButton btn btn-light btn-lg">
          Send Tokens
        </button>
      );
    } else if (tokenAmount1 && tokenAmount2 && transactionStatus === "mining") {
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
          Send Tokens
        </button>
      );
    }
  }

  const approveDAI = async (daiAmount) => {
    const approve_dai_tx = await dai_token.approve(poolAddress, daiAmount);
    return approve_dai_tx;
  };

  const approveGST = async (gstAmount) => {
    const approve_gst_tx = await gst_token.approve(poolAddress, gstAmount);

    return approve_gst_tx;
  };

  const approve = async (daiAmount, gstAmount) => {
    if (daiAmount !== gstAmount) {
      console.log("Unequal amounts");
    } else {
      daiAmount = utils.parseEther(daiAmount);
      gstAmount = utils.parseEther(gstAmount);
      const status1 = await approveDAI(daiAmount);
      const status2 = await approveGST(gstAmount);

      return [status1, status2];
    }
  };

  const sendTokens = async (daiAmount, gstAmount) => {
    approve(daiAmount, gstAmount)
      .then(async (status) => {
        if (status !== null || undefined) {
          try {
            await pool.provideLiquidity(
              utils.parseEther(daiAmount),
              utils.parseEther(gstAmount),
              dai_address,
              gst_address
            );
            notifySucess();
            setTransactionStatus(null);
            setTokenAmount1("");
            setTokenAmount2("");
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
          sendTokens(tokenAmount1, tokenAmount2);
        }}
      >
        <MDBContainer
          style={{
            maxWidth: "25rem",
            height: "80vh",
            backgroundColor: "#333333",
          }}
          className="rounded text-light"
        >
          <div className="provideLiquidityHeader">
            <h5>PROVIDE EQUAL TOKEN AMOUNTS</h5>
          </div>
          <div className="form-group mr-sm-2">
            <label htmlFor="GSToken">
              <h6>GST AMOUNT</h6>
            </label>
            <input
              value={tokenAmount1}
              onInput={(e) => setTokenAmount1(e.target.value)}
              type="text"
              className="form-control"
              placeholder="Amount"
              required
            />
          </div>
          <div className="form-group" style={{ marginTop: "20px" }}>
            <label htmlFor="daiToken">
              <h6>DAI AMOUNT</h6>
            </label>
            <input
              value={tokenAmount2}
              onInput={(e) => setTokenAmount2(e.target.value)}
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

export default Send;
