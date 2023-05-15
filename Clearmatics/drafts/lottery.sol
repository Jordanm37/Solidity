// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.11;

// The contract should allow anyone to submit 0.01 ether along with a list of 6 distinct numbers, each with a value between 1 and N, where N is a predefined maximum number.
// Submissions can only be made before a predefined time T, measured in blocks.
// Once time T is reached, no more submissions can be made.
// The 6 winning numbers will be computed based on some "randomness" or pseudo-randomness taken from the chain.
// Once the winning numbers have been determined, anyone whose submission matches all 6 numbers can claim the balance of all submissions.
// If there are no submissions that match all 6 winning numbers, the funds remain in the contract and are effectively lost.
// If there are multiple submissions that match all 6 winning numbers, the first person to claim the prize wins, and later claims are rejected.

// import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";

// contract Lottery is VRFConsumerBase {
//     address public owner;
//     uint public T;
//     uint public N;
//     uint public prize;
//     uint[] public winningNumbers;
//     mapping(address => uint[]) public submissions;
//     mapping(address => bool) public hasClaimed;

//     bytes32 internal keyHash; // identifies which Chainlink oracle to use
//     uint internal fee;        // fee to get random number
//     uint public randomResult;

contract Lottery {
    address public owner;
    uint256 public T;
    uint256 public N;
    uint256 public prize;
    uint256[] public winningNumbers;
    mapping(address => uint256[]) public submissions;
    mapping(address => bool) public hasClaimed;

    constructor(uint256 _T, uint256 _N) {
        owner = msg.sender;
        T = block.number + _T;
        N = _N;
        prize = 0;
    }

    // function getRandomNumber() public returns (bytes32 requestId) {
    //     require(LINK.balanceOf(address(this)) >= fee, "Not enough LINK in contract");
    //     return requestRandomness(keyHash, fee);
    // }

    // function fulfillRandomness(bytes32 requestId, uint randomness) internal override {
    //     randomResult = randomness;
    //     payWinner();
    // }

    // The contract should allow anyone to submit 0.01 ether along with a list of 6 distinct numbers, each with a value between 1 and N, where N is a predefined maximum number.
    // Submissions can only be made before a predefined time T, measured in blocks.
    function submit(uint256[] memory numbers) public payable {
        require(block.number < T, "Submissions are no longer accepted.");
        require(
            msg.value == 0.01 ether,
            "Each submission must include 0.01 ether."
        );
        require(numbers.length == 6, "Each submission must contain 6 numbers.");
        for (uint256 i = 0; i < 6; i++) {
            require(
                numbers[i] >= 1 && numbers[i] <= N,
                "Numbers must be between 1 and N."
            );
        }
        submissions[msg.sender] = numbers;
        prize += msg.value;
    }

    // However, time in Solidity is not very reliable, as block timestamps are set by miners
    // and can be manipulated. Therefore, it is better to use block numbers instead of timestamps to measure time intervals1. Block numbers are more predictable and less prone to attacks.
    // Alternatively, you can use a third-party service that triggers your contract when the desired time has passed. One such service is Ethereum Alarm Clock, which allows you to schedule transactions for future execution2.

    // Once time T is reached, no more submissions can be made.


    // The 6 winning numbers will be computed based on some "randomness" or pseudo-randomness taken from the chain.
    function computeWinningNumbers() public {
        require(block.number >= T, "Winning numbers cannot be computed yet.");
        require(winningNumbers.length == 0, "Winning numbers have already been computed.");
        // Generate the winning numbers pseudorandomly from the block hash
        bytes32 blockHash = blockhash(T);
        for (uint i = 0; i < 6; i++) {
            uint randomNumber = uint(keccak256(abi.encodePacked(blockHash, i))) % N + 1;
            winningNumbers.push(randomNumber);
        }
    }

// chainlink vrf is a better implementation 
    function getWinningNumbers() public view returns (uint[] memory) {
        return winningNumbers;
    }




    // Once the winning numbers have been determined, anyone whose submission matches all 6 numbers can claim the balance of all submissions.


    // If there are no submissions that match all 6 winning numbers, the funds remain in the contract and are effectively lost.
    // If there are multiple submissions that match all 6 winning numbers, the first person to claim the prize wins, and later claims are rejected.

    //   function pickWinner() public onlyowner {
    //         getRandomNumber();
    //     }

    //Modifiers
    modifier onlyowner() {
        require(msg.sender == owner);
        _;
    }
}


    // modifier onlyNotOwner {
    //     require(msg.sender != owner);
    //     _;
    // }

    // modifier onlyAfterStart {
    //     require(block.number < start_time, "not started");
    //     _;
    // }

    // modifier onlyBeforeEnd {
    //     require(block.number > end_time, "not finished");
    //     _;
    // }