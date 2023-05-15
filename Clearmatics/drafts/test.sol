// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.11;

// The contract should allow anyone to submit 0.01 ether along with a list of 6 distinct numbers, each with a value between 1 and N, where N is a predefined maximum number.
// Submissions can only be made before a predefined time T, measured in blocks.
// Once time T is reached, no more submissions can be made.
// The 6 winning numbers will be computed based on some "randomness" or pseudo-randomness taken from the chain.
// Once the winning numbers have been determined, anyone whose submission matches all 6 numbers can claim the balance of all submissions.
// If there are no submissions that match all 6 winning numbers, the funds remain in the contract and are noticeively lost.
// If there are multiple submissions that match all 6 winning numbers, the first person to claim the prize wins, and later claims are rejected.

/**
 * @title Lottery
 * @dev A simple lottery contract that allows players to submit combinations of numbers and win a prize if they match the winning numbers.
 * @notice The owner can close the lottery after the submission deadline and compute the winning numbers based on the block hash.
 * @notice The winner can claim their prize after the winning numbers have been computed.
 */

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract Lottery is ReentrancyGuard {
    // Constants
    uint256 public constant FEE = 0.01 ether; // The fee to enter the lottery

    // State variables
    address public owner;
    uint256 public T;
    uint256 public N;
    uint256 public prize;
    uint256[] private winningNumbers;
    mapping(address => uint256[]) private submissions;
    bool public hasClaimed;
    enum LotteryStatus {
        OPEN,
        CLOSED
    }
    LotteryStatus status;

    // Create a mapping to count the occurrences of each number in the first array
    mapping(uint256 => uint256) counts;

    // Events
    event Submitted(address player, uint256[] numbers); // Emitted when a player submits their numbers
    event Closed(uint256[] winningNumbers); // Emitted when the lottery is closed and the winning numbers are computed
    event Claimed(address winner, uint256 amount); // Emitted when a winner claims their prize
    event LotteryState(LotteryStatus _status);

    constructor(uint256 _T, uint256 _N) {
        owner = msg.sender;
        T = block.number + _T;
        N = _N;
        prize = 0;
        status = LotteryStatus.OPEN;
    }

    // The contract should allow anyone to submit 0.01 ether along with a list of 6 distinct numbers, each with a value between 1 and N, where N is a predefined maximum number.
    // Submissions can only be made before a predefined time T, measured in blocks.
/**
 * @dev Submits a combination of numbers for the lottery and pays the fee.
 * @notice This function can only be called before the submission deadline and with a valid combination of numbers.
 * @param numbers An array of six numbers between 1 and N.
 * @notice The block number is less than T.
 * @notice The numbers array has a length of 6.
 * @notice Each number in the array is between 1 and N.
 * @notice Stores the numbers array in the submissions mapping with the sender's address as the key.
 * @notice Increases the prize by the value of the message.
 * @notice Emits the Submitted event with the sender's address and the numbers array.
 */
    function submit(uint256[] memory numbers) public payable {
        require(block.number < T, "Submissions are no longer accepted.");
        // require(
        //     msg.value == FEE,
        //     "Each submission must include 0.01 ether."
        // );
        require(numbers.length == 6, "Each submission must contain 6 numbers.");
        for (uint256 i = 0; i < 6; i++) {
            require(numbers[i] >= 1 && numbers[i] <= N,
                "Numbers must be between 1 and N."
            );
        }
        submissions[msg.sender] = numbers;
        prize += msg.value;
        emit Submitted(msg.sender, numbers);
    }

    // However, time in Solidity is not very reliable, as block timestamps are set by miners
    // and can be manipulated. Therefore, it is better to use block numbers instead of timestamps to measure time intervals1. Block numbers are more predictable and less prone to attacks.
    // Alternatively, you can use a third-party service that triggers your contract when the desired time has passed. One such service is Ethereum Alarm Clock, which allows you to schedule transactions for future execution2.

    // Once time T is reached, no more submissions can be made.

    // The 6 winning numbers will be computed based on some "randomness" or pseudo-randomness taken from the chain.
//Assume you can submit mutiple times but any new will override the previous
/**
 * @dev Computes the winning numbers for the lottery based on the block hash of the submission deadline.
 * @notice This function can only be called by the owner after the submission deadline and before the prize is claimed.
 * @notice The winning numbers have not been computed yet.
 * @notice Pushes six pseudorandom numbers between 1 and N to the winningNumbers array.
 */
    function computeWinningNumbers() public onlyowner {
        require(block.number >= T, "Winning numbers cannot be computed yet.");
        require(winningNumbers.length == 0,
            "Winning numbers have already been computed."
        );
        // Generate the winning numbers pseudorandomly from the block hash
        bytes32 blockHash = blockhash(T);
        // require(blockHash != bytes32(0), "Block hash is not available yet.");
        for (uint256 i = 0; i < 6; i++) {
            uint256 randomNumber = (uint256(keccak256(abi.encodePacked(blockHash, i))) % N) + 1;
            winningNumbers.push(randomNumber);
        }
    }



    //ensure that the block hash is not zero. When a block is first created,
    //its hash is not immediately available. It is only available after a certain number
    //of blocks have been mined. Therefore, we need to ensure that the block hash is not zero before attempting to use it to generate random numbers.

    // chainlink vrf is a better implementation

    // Once the winning numbers have been determined, anyone whose submission matches all 6 numbers can claim the balance of all submissions.
    function getWinningNumbers() public view returns (uint256[] memory) {
        return winningNumbers;
    }

 

//  Compares two arrays of numbers and returns true if they contain the same elements, regardless of order.

/**
 * @dev Compares two arrays of numbers and returns true if they contain the same elements, regardless of order.
 * @param arr1 The first array to compare.
 * @param arr2 The second array to compare.
 * @return result A boolean value indicating whether the two arrays contain the same elements.
 * @notice This function modifies the input arrays by sorting them in-place.
 */
    function compareArrays(uint256[] memory arr1, uint256[] memory arr2) pure internal returns (bool result){
   
        require(arr1.length == arr2.length,"Arrays must be of the same length.");

        sort(arr1);
        sort(arr2);

        // Hash the arrays
        bytes32 hash1 = keccak256(abi.encodePacked(arr1));
        bytes32 hash2 = keccak256(abi.encodePacked(arr2));

        // Compare the hashes
        return hash1 == hash2; // The arrays are equal if and only if the hashes are equal

    }

    //Insertion sort


 /**
 * @dev Sorts the given array of uint256 values in ascending order using insertion sort algorithm.
 *
 * @param arr The array of uint256 values to be sorted.
 */   
    function sort(uint256[] memory arr) pure internal {
        for (uint256 i = 1; i < arr.length; i++) {
            uint256 key = arr[i];
            uint256 j = uint256(i) - 1;
            while (uint256(j) >= 0 && arr[uint256(j)] > key) {
                arr[uint256(j + 1)] = arr[uint256(j)];
                j--;
            }
            arr[uint256(j + 1)] = key;
        }
    }



// insertion sort is not the best way to sort values. 
// standard algorithm would be merge sort which has O(n log n) worst time complexity where as 
// insertion sort average time complexity is O(n ^ 2). Another option would be to use Quick Sort. It can be useful 
// if need in-place sorting with O(1) space complexity, though its worst time complexity can be O(n ^ 2).

// High fee calculations that would be better to do off chain. Can use chainlink functions (oracles) via api call to perform calculation and then return a boolean
// Alternative would be a nested for loop by combining seps ut that is essentially as complicated
// uses a simple sorting algorithm, which is cheaper. According to one source1, sorting an array of 10 elements costs about 0.0005 ETH, 
// while using a mapping costs about 0.001 ETH. However, the sorting algorithm may not be efficient for very large arrays, 



    // If there are no submissions that match all 6 winning numbers, the funds remain in the contract and are noticeively lost.
    // If there are multiple submissions that match all 6 winning numbers, the first person to claim the prize wins, and later claims are rejected.

/**
 * @dev Claims the prize for the sender if they have submitted a winning combination.
 * @notice This function can only be called after the submission deadline and after the winning numbers have been computed.
 * @notice The sender has submitted a winning combination.
 * @notice The prize has not been claimed yet.
 * @notice Transfers the prize to the sender.
 * @notice Sets the hasClaimed flag to true.
 * @notice Sets the status to CLOSED.
 * @notice Emits the Claimed and LotteryState events.
 */
    function claimPrize() external nonReentrant {
        require(block.number >= T, "Prize cannot be claimed yet.");
        require(winningNumbers.length == 6,
            "Winning numbers have not been computed yet."
        );
        require(!hasClaimed, "The prize has already been claimed.");
        require(compareArrays(submissions[msg.sender], winningNumbers),
            "You did not submit a winning combination."
        );
        payable(msg.sender).transfer(prize);
        hasClaimed = true; //after to prevent reentrancy attack
        status = LotteryStatus.CLOSED;
        emit Claimed(msg.sender, prize);
        emit LotteryState(status);
    }


    //Modifiers
    modifier onlyowner() {
        require(msg.sender == owner);
        _;
    }

    modifier onlyNotOwner {
    require(msg.sender != owner);
    _;
}

}

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

// function getRandomNumber() public returns (bytes32 requestId) {
//     require(LINK.balanceOf(address(this)) >= fee, "Not enough LINK in contract");
//     return requestRandomness(keyHash, fee);
// }

// function fulfillRandomness(bytes32 requestId, uint randomness) internal override {
//     randomResult = randomness;
//     payWinner();
// }







/**
 * @dev Compares two arrays of numbers and returns true if they contain the same elements, regardless of order.
 * @param arr1 The first array of numbers.
 * @param arr2 The second array of numbers.
 * @return result True if the arrays contain the same elements, false otherwise.
 * @notice The arrays have the same length.
 * @notice Uses a mapping to store the counts of each number in the first array, and decrements the counts for each number in the second array.
 */
    // function compareArrays(uint256[] memory arr1, uint256[] memory arr2)
    //     internal
    //     returns (bool result)
    // {
    //     require(arr1.length == arr2.length,"Arrays must be of the same length.");

    //     // Reset the mapping to zero
    //     for (uint256 i = 0; i < arr1.length; i++) {
    //         counts[arr1[i]] = 0;
    //     }
    //     for (uint256 i = 0; i < arr1.length; i++) {
    //         counts[arr1[i]]++;
    //     }

    //     // Decrement the count for each occurrence of a number in the second array
    //     for (uint256 i = 0; i < arr2.length; i++) {
    //         if (counts[arr2[i]] == 0) {
    //             return false; // This number is not in the first array
    //         }
    //         counts[arr2[i]]--;
    //     }

    //     // Check that all counts have been decremented to zero
    //     for (uint i = 0; i < arr1.length; i++) {
    //         if (counts[arr1[i]] != 0) {
    //             return false; // This number occurs more times in the first array than in the second array
    //         }
    //     }
    //     return true;
    // }
