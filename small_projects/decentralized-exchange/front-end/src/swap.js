import { useState } from "react";
import { MenuItem, Select } from "@mui/material";
import "bootstrap/dist/css/bootstrap.min.css";
import { ethers, utils } from "ethers";
import GSToken from "./GSToken.json";
import DAI from "./DAI.json";
import TokenPool from "./TokenPool.json";
import "./App.css";
import { toast, ToastContainer } from "react-toastify";
import "react-toastify/dist/ReactToastify.css";

function Exchange() {
  const provider = new ethers.providers.Web3Provider(window.ethereum);
  const signer = provider.getSigner();
  const dai_address = process.env.REACT_APP_DAI_ADDRESS;
  const gst_address = process.env.REACT_APP_GST_ADDRESS;
  const poolAddress = process.env.REACT_APP_POOL_ADDRESS;
  const poolABI = TokenPool.abi;
  const daiABI = DAI.abi;
  const gstABI = GSToken.abi;
  const dai_token = new ethers.Contract(dai_address, daiABI, signer);
  const gst_token = new ethers.Contract(gst_address, gstABI, signer);
  const pool = new ethers.Contract(poolAddress, poolABI, signer);

  const options = [
    { value: gst_token, label: "GHOST TOKEN", id: 0 },
    { value: dai_token, label: "DAI TOKEN", id: 1 },
  ];

  const [tokenSelected, setTokenSelected] = useState(options[0]);

  const [tokenAmount, setTokenAmount] = useState("");
  const [transactionStatus, setTransactionStatus] = useState(null);

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
  const notifyTokenUnsupported = () => {
    toast.warning("Token Not Supported", {
      position: toast.POSITION.TOP_RIGHT,
    });
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

  const handleTokenSelected = (event) => {
    event.preventDefault();
    setTokenSelected(event.target.value);
  };
  const tokenIndex = (id) => {
    for (let option = 0; option < options.length; option++) {
      if (options[option].id === id) {
        return option;
      }
    }
    return "";
  };

  const approveSwap = async (amount, token) => {
    const approve_swap_tx = await token.approve(poolAddress, amount);
    return approve_swap_tx;
  };

  const approve = async (amount, token) => {
    amount = utils.parseEther(amount);
    const status = await approveSwap(amount, token);
    return status;
  };

  const swapTokens = async (amount, token) => {
    // console.log(token.address);
    approve(amount, token)
      .then(async (status) => {
        //   console.log(status);
        if (status !== null || undefined) {
          if (token.address === gst_address) {
            try {
              await pool.swapTokens(
                utils.parseEther(amount),
                gst_address,
                dai_address
              );
              notifySucess();
              setTransactionStatus(null);
              setTokenAmount("");
            } catch (error) {
              if (error.reason === "invalid address") {
                notifyInvalidAddress();
                setTransactionStatus(null);
              } else if (
                error.reason ===
                "cannot estimate gas; transaction may fail or may require manual gas limit"
              ) {
                notifyPendingFailure();
                setTransactionStatus(null);
              } else {
                notifyFailure();
                setTransactionStatus(null);
              }
            }
          } else if (token.address === dai_address) {
            try {
              await pool.swapTokens(
                utils.parseEther(amount),
                dai_address,
                gst_address
              );
              notifySucess();
              setTransactionStatus(null);
              setTokenAmount("");
            } catch (error) {
              if (error.reason === "invalid address") {
                notifyInvalidAddress();
              } else if (
                error.reason ===
                "cannot estimate gas; transaction may fail or may require manual gas limit"
              ) {
                notifyPendingFailure();
              }
            }
          } else {
            notifyTokenUnsupported();
          }
        } else {
          notifyFailure();
        }
      })
      .catch(() => {
        setTransactionStatus(null);
        notifyFailure();
      });
  };

  function SubmitButton() {
    if (tokenAmount && transactionStatus !== "mining") {
      return (
        <button type="submit" className="blockButton btn btn-dark">
          SWAP
        </button>
      );
    } else if (tokenAmount && transactionStatus === "mining") {
      return (
        <button type="submit" disabled className="blockButton btn btn-dark">
          <span
            className="spinner-border spinner-border-sm"
            role="status"
            aria-hidden="true"
          ></span>
        </button>
      );
    } else {
      return <button className="blockButton btn btn-dark">SWAP</button>;
    }
  }

  return (
    <>
      <form
        onSubmit={(e) => {
          e.preventDefault();
          setTransactionStatus("mining");
          let token = tokenSelected.value;
          let amount = tokenAmount;
          swapTokens(amount, token);
        }}
        className=""
      >
        <h2>SELECT TOKEN TO SELL</h2>
        <br />
        <div className="d-flex justify-content-center align-items-center">
          <Select
            value={options[tokenIndex(tokenSelected.id)]}
            label="Token"
            onChange={handleTokenSelected}
          >
            {options.map((option) => {
              return (
                <MenuItem value={option} key={option.id}>
                  {option.label}
                </MenuItem>
              );
            })}
          </Select>
        </div>
        <br />
        <div className="d-flex justify-content-center align-items-center">
          <label htmlFor="tokenAmount">
            <h5>ENTER TOKEN AMOUNT</h5>
          </label>
        </div>
        <br />
        <div>
          <input
            value={tokenAmount}
            onInput={(e) => setTokenAmount(e.target.value)}
            id="tokenAmount"
            type="text"
            className="form-control form-control-lg"
            placeholder="Token Amount"
            required
          />
        </div>
        <br />
        <div className="d-flex justify-content-center align-items-center">
          <SubmitButton />
        </div>
        <ToastContainer />
      </form>
    </>
  );
}

export default Exchange;
