// SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@chainlink/contracts/src/v0.8/VRFV2WrapperConsumerBase.sol";

contract Lottery is VRFV2WrapperConsumerBase, Ownable {
    // For sepolia testnet
    // address constant VRF_COORDINATOR = 0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625;
    // address constant LINK =	0x779877A7B0D9E8603169DdbD7836e478b4624789;
    uint256 public constant FEE = 0.1 * 10**18;
    uint256 public requestId;
    bytes32 constant KEY_HASH = 0x79d3d8832d904592c0bf9818b621522c988bb8b0c05cdc3b15aea1b6e8db0c15;
    uint32 constant callbackGasLimit = 500000;
    uint16 constant requestConfirmations = 3;
    uint32 constant numWords = 6;
    uint256[] private winningNumbers;
    uint constant public N = 100;

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
        require(requestId == _requestId, "Wrong request ID.");
        winningNumbers = new uint256[](6); // Clears the array before adding new numbers
        for (uint256 i = 0; i < 6; i++) {
            uint256 randomNumber = (_randomWords[i] % N) + 1;
            winningNumbers.push(randomNumber);
        }
    }

    function getWinningNumbers() public view returns (uint256[] memory) {
        return winningNumbers;
    }


}

