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
import "@chainlink/contracts/src/v0.8/VRFV2WrapperConsumerBase.sol";

contract Lottery is VRFV2WrapperConsumerBase, ReentrancyGuard, Ownable {
    // Constants
    uint256 public constant FEE = 0.01 ether; // The fee to enter the lottery
    uint256 constant NUM_ENTRIES = 6;

    // State variables
    uint256 public maxNumber;
    uint256 public submissionDeadline;
    uint256 public prize;
    uint256[] private winningNumbers;
    mapping(address => bytes32) private submissions;
    bool public hasClaimed;
    enum LotteryStatus {
        OPEN,
        CLOSED
    }
    LotteryStatus status;

    // chainlink VRF variables
    struct RequestStatus {
        uint256 paid; // amount paid in link
        bool fulfilled; // whether the request has been successfully fulfilled
        uint256[] randomWords;
    }
    mapping(uint256 => RequestStatus) public s_requests; /* requestId --> requestStatus */

    // past requests Id.
    uint256[] public requestIds;
    uint256 public lastRequestId;
    uint32 callbackGasLimit = 400000;
    uint16 requestConfirmations = 3;
    uint32 numWords = 6;
    // Address LINK - hardcoded for Sepolia
    address linkAddress = 0x779877A7B0D9E8603169DdbD7836e478b4624789;
    // address WRAPPER - hardcoded for Sepolia
    address wrapperAddress = 0xab18414CD93297B0d12ac29E63Ca20f515b3DB46;

    // Events
    event Submitted(address indexed player); // Emitted when a player submits their numbers
    event Closed(uint256[] winningNumbers); // Emitted when the lottery is closed and the winning numbers are computed
    event Claimed(address indexed winner, uint256 amount); // Emitted when a winner claims their prize
    event LotteryState(LotteryStatus _status);
    event RequestSent(uint256 requestId, uint32 numWords);
    event RequestFulfilled(
        uint256 requestId,
        uint256[] randomWords,
        uint256 payment
    );

    constructor(uint256 _T, uint256 _N)
        VRFV2WrapperConsumerBase(linkAddress, wrapperAddress)
    {
        require(_T > 0, "_T should be greater than zero.");
        require(_N > 1, "_N should be between 1 and 100.");
        submissionDeadline = block.number + _T;
        maxNumber = _N;
        status = LotteryStatus.OPEN;
    }

    /**
     * @notice Submits a combination of numbers for the lottery and pays the fee.
     * @dev This function can only be called before the submission deadline and with a valid combination of numbers.
     * Must satisfy the following conditions:
     * - The block number is less than T.
     * - The numbers array has a length of 6.
     * - Each number in the array is between 1 and N.
     * Updates the contract state and emits events as follows:
     * - Stores the numbers array in the submissions mapping with the sender's address as the key.
     * - Increases the prize by the value of the message.
     * - Emits the Submitted event with the sender's address and the numbers array.
     * @param numbers An array of six numbers between 1 and N.
     */
    function submit(uint256[] memory numbers) public payable {
        require(
            block.number < submissionDeadline,
            "Submissions are no longer accepted."
        );
        require(msg.value == FEE, "Each submission must include 0.01 ether.");
        require(
            numbers.length == NUM_ENTRIES,
            "Each submission must contain 6 numbers."
        );
        // Check if the 6 numbers submitted are distinct
        for (uint256 i = 0; i < NUM_ENTRIES; i++) {
            require(
                numbers[i] >= 1 && numbers[i] <= maxNumber,
                "Numbers must be between 1 and N."
            );
            for (uint256 j = i + 1; j < NUM_ENTRIES; j++) {
                if (numbers[i] == numbers[j]) {
                    revert("All submitted numbers must be distinct.");
                }
            }
        }
        numbers = sort(numbers);
        bytes32 hash = keccak256(abi.encodePacked(numbers));
        submissions[msg.sender] = hash;
        prize += msg.value;
        emit Submitted(msg.sender);
    }


    /**
     * @notice Computes the winning numbers for the current game.
     * @dev This function can only be called by the owner after the submission deadline.
     * Fetches the random numbers from the request status and updates the winningNumbers array.
     */
    function computeWinningNumbers() external onlyOwner {
        require(
            block.number >= submissionDeadline,
            "Winning numbers cannot be computed yet."
        );
        require(
            winningNumbers.length == 0,
            "Winning numbers have already been computed."
        );
        (, , uint256[] memory winningArr) = getRequestStatus(lastRequestId);
        for (uint256 i = 0; i < winningArr.length; i++) {
            winningNumbers.push((winningArr[i] % maxNumber) + 1);
        }
        winningNumbers = sort(winningNumbers);
    }

    /**
     * @notice Returns the array of winning numbers for the current game.
     * @dev This function is public and can be used by anyone to fetch the winning numbers.
     * @return An array of uint256 values representing the winning numbers.
     */
    function getWinningNumbers() public view returns (uint256[] memory) {
        return winningNumbers;
    }

    /**
     * @notice Claims the prize for the sender if they have submitted a winning combination.
     * @dev This function can only be called after the submission deadline and after the winning numbers have been computed.
     * Must satisfy the following conditions:
     * - The sender has submitted a winning combination.
     * - The prize has not been claimed yet.
     * Updates the contract state and emits events as follows:
     * - Transfers the prize to the sender.
     * - Sets the hasClaimed flag to true.
     * - Sets the status to CLOSED.
     * - Emits the Claimed and LotteryState events.
     */
    function claimPrize() external nonReentrant {
        require(
            block.number >= submissionDeadline,
            "Prize cannot be claimed yet."
        );
        require(
            winningNumbers.length == NUM_ENTRIES,
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

    /**
     * @notice Compares the hash of a bytes32 and a uint256 array.
     * @dev Returns true if the arrays are equal, false otherwise.
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
     * @notice Sorts the given array of uint256 values in ascending order using quicksort algorithm.
     * @dev This function is internal and should be used to sort arrays within the contract.
     * @param arr The array of uint256 values to be sorted.
     * @param left The leftmost index of the array.
     * @param right The rightmost index of the array.
     */
    function quickSort(
        uint256[] memory arr,
        int256 left,
        int256 right
    ) internal pure {
        int256 i = left;
        int256 j = right;
        if (i == j) return;
        uint256 pivot = arr[uint256(left + (right - left) / 2)];
        while (i <= j) {
            while (arr[uint256(i)] < pivot) i++;
            while (pivot < arr[uint256(j)]) j--;
            if (i <= j) {
                (arr[uint256(i)], arr[uint256(j)]) = (
                    arr[uint256(j)],
                    arr[uint256(i)]
                );
                i++;
                j--;
            }
        }
        if (left < j) quickSort(arr, left, j);
        if (i < right) quickSort(arr, i, right);
    }

    /**
     * @notice Sorts the given array of uint256 values in ascending order.
     * @param data The array of uint256 values to be sorted.
     * @return sortedArray The sorted array.
     */
    function sort(uint256[] memory data)
        internal
        pure
        returns (uint256[] memory)
    {
        quickSort(data, int256(0), int256(data.length - 1));
        return data;
    }

    /**
     * @notice Requests random words from the Chainlink VRF.
     * @dev Only callable by the contract owner.
     * @return requestId The ID of the randomness request.
     */
    function requestRandomWords()
        external
        onlyOwner
        returns (uint256 requestId)
    {
        requestId = requestRandomness(
            callbackGasLimit,
            requestConfirmations,
            numWords
        );
        s_requests[requestId] = RequestStatus({
            paid: VRF_V2_WRAPPER.calculateRequestPrice(callbackGasLimit),
            randomWords: new uint256[](0),
            fulfilled: false
        });
        requestIds.push(requestId);
        lastRequestId = requestId;
        emit RequestSent(requestId, numWords);
        return requestId;
    }

    /**
     * @notice Fulfills the random words request from Chainlink VRF.
     * @dev This function is internal and should be called by the VRF system only.
     * @param _requestId The ID of the randomness request.
     * @param _randomWords An array containing the random words received from the VRF.
     */
    function fulfillRandomWords(
        uint256 _requestId,
        uint256[] memory _randomWords
    ) internal override {
        require(s_requests[_requestId].paid > 0, "request not found");
        s_requests[_requestId].fulfilled = true;
        s_requests[_requestId].randomWords = _randomWords;
        emit RequestFulfilled(
            _requestId,
            _randomWords,
            s_requests[_requestId].paid
        );
    }

    /**
     * @notice Retrieves the request status of a given Chainlink VRF request ID.
     * @param _requestId The ID of the randomness request.
     * @return paid The amount paid for the request in LINK tokens.
     * @return fulfilled Whether the request has been successfully fulfilled or not.
     * @return randomWords The array containing the random words received from the VRF.
     */
    function getRequestStatus(uint256 _requestId)
        public
        view
        returns (
            uint256 paid,
            bool fulfilled,
            uint256[] memory randomWords
        )
    {
        require(s_requests[_requestId].paid > 0, "request not found");
        RequestStatus memory request = s_requests[_requestId];
        return (request.paid, request.fulfilled, request.randomWords);
    }
}

// /**
//  * @dev Computes the winning numbers for the lottery based on the block hash of the submission deadline.
//  * @notice This function can only be called by the owner after the submission deadline and before the prize is claimed.
//  * @notice The winning numbers have not been computed yet.
//  * @notice Pushes six pseudorandom numbers between 1 and N to the winningNumbers array.
//  */
// function computeWinningNumbers() public onlyOwner {
//     require(block.number >= T, "Winning numbers cannot be computed yet.");
//     require(
//         winningNumbers.length == 0,
//         "Winning numbers have already been computed."
//     );
//     // Generate the winning numbers pseudorandomly from the block hash
//     bytes32 blockHash = blockhash(block.timestamp);
//     // require(blockHash != bytes32(0), "Block hash is not available yet.");
//     for (uint256 i = 0; i < NUM_ENTRIES; i++) {
//         uint256 randomNumber = (uint256(
//             keccak256(abi.encodePacked(blockHash, block.prevrandao, i))
//         ) % N) + 1;
//         winningNumbers.push(randomNumber);
//     }
//     sort(winningNumbers);
// }

// function sort(uint256[] memory arr) internal pure {
//     for (uint256 i = 1; i < arr.length; i++) {
//         uint256 key = arr[i];
//         uint256 j = i;
//         while (j > 0 && arr[j - 1] > key) {
//             arr[j] = arr[j - 1];
//             j--;
//         }
//         arr[j] = key;
//     }
// }
