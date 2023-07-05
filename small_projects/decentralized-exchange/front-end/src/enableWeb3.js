import "bootstrap/dist/css/bootstrap.min.css";

function EnableWeb3() {
  return (
    <div className="mask homepage">
      <div
        className="d-flex justify-content-center align-items-center"
        style={{ marginTop: "50px" }}
      >
        <div className="text-dark">
          <h2>Your web browser in not web3 enabled</h2>
        </div>
      </div>
      <div
        className="d-flex justify-content-center align-items-center"
        style={{ marginTop: "50px" }}
      >
        <div className="text-dark">
          <h2>Install MetaMask to Continue</h2>
          <br />
        </div>
      </div>
      <div
        className="d-flex justify-content-center align-items-center text-white"
        style={{ marginTop: "30px" }}
      >
        <a
          className="btn btn-outline-light btn-lg"
          type="button"
          href="https://metamask.io/"
          target="_blank"
          rel="noreferrer noopener"
        >
          Install MetaMask
        </a>
      </div>
    </div>
  );
}

export default EnableWeb3;
