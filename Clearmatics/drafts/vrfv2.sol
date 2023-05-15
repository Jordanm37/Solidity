// SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@chainlink/contracts/src/v0.8/VRFV2WrapperConsumerBase.sol";

contract Lottery is VRFV2WrapperConsumerBase, Ownable {
    address VRF_COORDINATOR = 0x6168499c0cFfCaCD319c818142124B7A15E857ab;
    uint256 public constant FEE = 0.1 * 10**18;
    uint256 public requestId;
    bytes32 constant KEY_HASH = 0x79d3d8832d904592c0bf9818b621522c988bb8b0c05cdc3b15aea1b6e8db0c15;
    uint32 constant callbackGasLimit = 500000;
    uint16 constant requestConfirmations = 3;
    uint32 constant numWords = 6;
    uint256[] private winningNumbers;
    uint public N = 100;

    constructor(address _vrfCoordinator, address _linkToken)
        VRFV2WrapperConsumerBase(_vrfCoordinator, _linkToken)
    {}

    function computeWinningNumbers() public onlyOwner {
        require(LINK.balanceOf(address(this)) >= FEE, "Not enough LINK");
        require(
            winningNumbers.length == 0,
            "Winning numbers have already been computed."
        );
        requestId = requestRandomness(
            callbackGasLimit,
            requestConfirmations,
            numWords
        );
    }

    function fulfillRandomWords(uint256 _requestId, uint256[] memory _randomWords)
        internal
        override
    {
        fulfillRandomness(uint256(_requestId), _randomWords[0]);
    }

    function fulfillRandomness(uint256 _requestId, uint256 randomness)
        internal
    {
        require(requestId == _requestId, "Wrong request ID.");
        winningNumbers = new uint256[](6); // Clears the array before adding new numbers
        for (uint256 i = 0; i < 6; i++) {
            uint256 randomNumber = (randomness >> (i * 8)) % N + 1;
            winningNumbers.push(randomNumber);
        }
    }

    function getWinningNumbers() public view returns (uint256[] memory) {
        return winningNumbers;
    }


}




// //     // Define a function that requests and receives randomness from Chainlink VRFV2
// //     function getRandomNumber() public returns (uint256 requestId) {
// //         require(LINK.balanceOf(address(this)) >= fee, "Not enough LINK"); // Check if the contract has enough LINK to pay the fee
// //         return requestRandomWords(callbackGasLimit, requestConfirmations, numWords); // Call the requestRandomWords function and return the request ID
// //     }

// //     // Define a callback function that receives the random value, the request ID, and the sub ID from Chainlink VRFV2
// //     function fulfillRandomWords(uint256 randomness, uint256 requestId, uint256 subId) internal override {
// //         randomResult = (randomness%N)+1; // Store the random value in the randomResult variable
// //         winningNumbers = randomResult;
// //     }
// // }


   

//     /**
//      * @notice Function to calculate the winner
//      * Only owner could call this function
//      * @dev Will revert if subscription is not set and funded
//      *
//      * Emits a {RequestedRandomness} event.
//      */
//     function _pickWinner() private {
//         require(_lotteryState == LOTTERY_STATE.CALCULATING_WINNER, "Lottery not ended yet");
//         requestId = _coordinator.requestRandomWords(
//             _keyHash,
//             _subscriptionId,
//             _REQUEST_CONFIRMATIONS,
//             _CALLBACK_GAS_LIMIT,
//             _NUM_WORDS
//         );
//         emit RequestedRandomness(requestId);
//     }


//     /**
//      * @notice Get random number, pick winner and sent prize to winner
//      * @dev Function can be fulfilled only from _vrfcoordinator
//      * @param reqId_ requestId for generating random number
//      * @param random_ received number from VRFv2
//      *
//      * Requirements:
//      *
//      * - The first random word must be higher than zero.
//      *
//      * Emits a {ReceivedRandomness} event.
//      * Emits a {LotteryEnded} event.
//      */
//     function fulfillRandomWords(
//         uint256 reqId_, /* requestId */
//         uint256[] memory random_
//     ) internal override {
//         _randomWord = random_;
//         require(_randomWord[0] > 0, "Random number not found");
//         uint256 winnerTicket = (_randomWord[0] % _numberOfTicket) + 1;
//         _lotteryWinners[_lotteryId] = _userTickets[winnerTicket];
//         bool success = _lotCoin.transfer(_userTickets[winnerTicket], (_lotteryBalance * _percentageWinner) / 100);
//         require(success, "Transfer of funds to the winner ended in failure");
//         success = _lotCoin.transfer(owner(), (_lotteryBalance * _percentageOwner) / 100);
//         require(success, "Transfer of funds to the owner ended in failure");
//         _lotteryState = LOTTERY_STATE.CLOSED;
//         emit ReceivedRandomness(reqId_, random_[0]);
//         emit LotteryEnded(_lotteryId, _userTickets[winnerTicket]);
//     }

//   VRFCoordinatorV2Interface COORDINATOR;

//   // Your subscription ID.
//   uint64 s_subscriptionId;

//   // Rinkeby coordinator. For other networks,
//   // see https://docs.chain.link/docs/vrf-contracts/#configurations
//   address vrfCoordinator = 0x6168499c0cFfCaCD319c818142124B7A15E857ab;

//   // The gas lane to use, which specifies the maximum gas price to bump to.
//   // For a list of available gas lanes on each network,
//   // see https://docs.chain.link/docs/vrf-contracts/#configurations
//   bytes32 keyHash = 0xd89b2bf150e3b9e13446986e571fb9cab24b13cea0a43ea20a6049a85cc807cc;

//   // Depends on the number of requested values that you want sent to the
//   // fulfillRandomWords() function. Storing each word costs about 20,000 gas,
//   // so 100,000 is a safe default for this example contract. Test and adjust
//   // this limit based on the network that you select, the size of the request,
//   // and the processing of the callback request in the fulfillRandomWords()
//   // function.
//   uint32 callbackGasLimit = 100000;

//   // The default is 3, but you can set this higher.
//   uint16 requestConfirmations = 3;

//   // For this example, retrieve 2 random values in one request.
//   // Cannot exceed VRFCoordinatorV2.MAX_NUM_WORDS.
//   uint32 numWords =  2;

//   uint256[] public s_randomWords;
//   uint256 public s_requestId;
//   address s_owner;

//   constructor(uint64 subscriptionId) VRFConsumerBaseV2(vrfCoordinator) {
//     COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator);
//     s_owner = msg.sender;
//     s_subscriptionId = subscriptionId;
//   }

//   // Assumes the subscription is funded sufficiently.
//   function requestRandomWords() external onlyOwner {
//     // Will revert if subscription is not set and funded.
//     s_requestId = COORDINATOR.requestRandomWords(
//       keyHash,
//       s_subscriptionId,
//       requestConfirmations,
//       callbackGasLimit,
//       numWords
//     );
//   }
  
//   function fulfillRandomWords(
//     uint256, /* requestId */
//     uint256[] memory randomWords
//   ) internal override {
//     s_randomWords = randomWords;
//   }


// function fulfillRandomWords(
//   uint256, /* requestId */
//   uint256[] memory randomWords
// ) internal override {
//   // Assuming only one random word was requested.
//   s_randomRange = (randomWords[0] % 50) + 1;
// }

//     uint[] public winningNumbers;
// //     bytes32 internal keyHash; // identifies which Chainlink oracle to use
// //     uint internal fee;        // fee to get random number
// //     uint public randomResult;


// // function getRandomNumber() public returns (bytes32 requestId) {
// //     require(LINK.balanceOf(address(this)) >= fee, "Not enough LINK in contract");
// //     return requestRandomness(keyHash, fee);
// // }

// // function fulfillRandomness(bytes32 requestId, uint randomness) internal override {
// //     randomResult = randomness;
// //     payWinner();
// // }

// // Import the Chainlink VRFV2 contract
// import "@chainlink/contracts/src/v0.8/VRFV2.sol";

// // Declare your contract and inherit from the Chainlink VRFV2 contract
// contract RandomNumberGeneratorV2 is VRFV2 {
//     // Define some variables
//     bytes32 internal keyHash; // The key hash used for the randomness request
//     uint256 internal fee; // The fee required for the randomness request
//     uint256 public randomResult; // The random number generated by Chainlink VRFV2

//     // Define a constructor that takes the VRF coordinator address, the LINK token address, the key hash, and the fee as parameters
//     constructor(address _vrfCoordinator, address _link, bytes32 _keyHash, uint256 _fee) 
//         VRFV2(_vrfCoordinator, _link) // Initialize the VRFV2 contract with the given parameters
//     {
//         keyHash = _keyHash; // Set the key hash
//         fee = _fee; // Set the fee
//     }



//      VRFConsumerBase(
//             0xb3dCcb4Cf7a26f6cf6B120Cf5A73875B7BBc655B, // VRF coordinator
//             0x01BE23585060835E02B77ef475b0Cc51aA1e0709  // LINK token address
//         ) {
//             keyHash = 0x2ed0feb3e7fd2022120aa84fab1945545a9f2ffc9076fd6156fa96eaff4c1311;
//             fee = 0.1 * 10 ** 18;    // 0.1 LINK

//         }



//            event RequestSent(uint256 requestId, uint32 numWords);
//     event RequestFulfilled(
//         uint256 requestId,
//         uint256[] randomWords,
//         uint256 payment
//     );

//     struct RequestStatus {
//         uint256 paid; // amount paid in link
//         bool fulfilled; // whether the request has been successfully fulfilled
//         uint256[] randomWords;
//     }
//     mapping(uint256 => RequestStatus)
//         public s_requests; /* requestId --> requestStatus */


