
// async function connectWallet() {
//     if(window.ethereum) {
//         try{
//             await window.ethereum.request( { method: 'eth_requestAccounts'});

//             const provider = new ethers.providers.Web3Provider(window.ethereum);
//             const signer = provider.getSigner();
//             return signer;
//         } catch(error) {
//             console.error(error);
//             return false;
//         }

//     }else {
//         console.error(error);
//         return false;
//      }

//     }


// async function disconnectWallet() {
//     if (window.ethereum) {
//         try {
//             await window.ethereum.request({ method: 'eth_requestAccounts' });
//         window.ethereum._cachedProvider = null;
//         return true;
//         } catch (error) {
//         console.error(error);
//         return false;
//         }
//     } else {
//             console.error('No Ethereum wallet found. Please install a wallet like MetaMask.');
//         return false;
//     }
//     }

// document.getElementById('transfer').addEventListener('click', async () => {
//     const signer = await connectWallet();
//     if (signer) {
//         const transaction = await signer.sendTransaction({
//         to: '999999', 
//         value: ethers.utils.parseEther('0.1'), 
//         });
//         console.log(`Transaction sent: ${transaction.hash}`);
//     }
//     });



// document.getElementById('connect-wallet-button').addEventListener('click', () => {
//     // Perform some action when the button is clicked
//     console.log('Button clicked!');
//     });