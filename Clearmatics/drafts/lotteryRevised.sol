// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.11;

/**
 * @title Lottery
 * @dev A simple lottery contract that allows players to submit combinations of numbers and win a prize if they match the winning numbers.
 * @notice The owner can close the lottery after the submission deadline and compute the winning numbers based on the block hash.
 * @notice The winner can claim their prize after the winning numbers have been computed.
 */
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract Lottery is ReentrancyGuard, Ownable {
    // Constants
    uint256 public constant FEE = 0.01 ether; // The fee to enter the lottery
    uint256 constant numEntries = 6;
    // State variables
    uint256 public T;
    uint256 public N;
    uint256 public prize;
    uint256[] private winningNumbers;
    mapping(address => bytes32) private submissions;
    bool public hasClaimed;
    enum LotteryStatus {
        OPEN,
        CLOSED
    }
    LotteryStatus status;

    // Events
    event Submitted(address player); // Emitted when a player submits their numbers
    event Closed(uint256[] winningNumbers); // Emitted when the lottery is closed and the winning numbers are computed
    event Claimed(address winner, uint256 amount); // Emitted when a winner claims their prize
    event LotteryState(LotteryStatus _status);

    constructor(uint256 _T, uint256 _N) {
        T = block.number + _T;
        N = _N;
        status = LotteryStatus.OPEN;
    }

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
        require(msg.value == FEE, "Each submission must include 0.01 ether.");
        require(numbers.length ==numEntries, "Each submission must contain 6 numbers.");
        for (uint256 i = 0; i <numEntries; i++) {
            require(
                numbers[i] >= 1 && numbers[i] <= N,
                "Numbers must be between 1 and N."
            );
        }
        sort(numbers);
        bytes32 hash = keccak256(abi.encodePacked(numbers));
        submissions[msg.sender] = hash;
        prize += msg.value;
        emit Submitted(msg.sender);
    }

    /**
     * @dev Computes the winning numbers for the lottery based on the block hash of the submission deadline.
     * @notice This function can only be called by the owner after the submission deadline and before the prize is claimed.
     * @notice The winning numbers have not been computed yet.
     * @notice Pushes six pseudorandom numbers between 1 and N to the winningNumbers array.
     */
    function computeWinningNumbers() public onlyOwner {
        require(block.number >= T, "Winning numbers cannot be computed yet.");
        require(
            winningNumbers.length == 0,
            "Winning numbers have already been computed."
        );
        // Generate the winning numbers pseudorandomly from the block hash
        bytes32 blockHash = blockhash(block.timestamp);
        // require(blockHash != bytes32(0), "Block hash is not available yet.");
        for (uint256 i = 0; i <numEntries; i++) {
            uint256 randomNumber = (uint256(
                keccak256(abi.encodePacked(blockHash, block.prevrandao, i))
            ) % N) + 1;
            winningNumbers.push(randomNumber);
        }
        sort(winningNumbers);
    }

    /**
     * @dev Returns the array of winning numbers for the current game.
     *
     * @return An array of uint256 values representing the winning numbers.
     */
    function getWinningNumbers() public view returns (uint256[] memory) {
        return winningNumbers;
    }

    /**
     * @dev Compares the hash of a bytes32 and a uint256 array.
     * @param hash1 The hash of the first array.
     * @param arr2 The second array.
     * @return result True if the arrays are equal, false otherwise.
     */
    function compareArrays(bytes32 hash1, uint256[] memory arr2)
        internal
        pure
        returns (bool result)
    {
        bytes32 hash2 = keccak256(abi.encodePacked(arr2));
        return hash1 == hash2; // The arrays are equal if and only if the hashes are equal
    }

    /**
     * @dev Sorts the given array of uint256 values in ascending order using insertion sort algorithm.
     *
     * @param arr The array of uint256 values to be sorted.
     */
    function sort(uint256[] memory arr) internal pure {
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
        require(
            winningNumbers.length ==numEntries,
            "Winning numbers have not been computed yet."
        );
        require(!hasClaimed, "The prize has already been claimed.");
        bytes32 submittedNumbersHash = submissions[msg.sender];
        require(
            compareArrays(submittedNumbersHash, winningNumbers),
            "You did not submit a winning combination."
        );
        // payable(msg.sender).transfer(prize);
        (bool success, ) = payable(msg.sender).call{value: prize}("");
        require(success, "Transfer of funds to the winner ended in failure");
        hasClaimed = true; //after to prevent reentrancy attack
        status = LotteryStatus.CLOSED;
        emit Claimed(msg.sender, prize);
        emit LotteryState(status);
    }
}
