// Specify version of Solidity to use
pragma solidity ^0.8.0;


import "@openzeppelin/contracts/access/Ownable.sol";

// Contract definition
contract Lottery is{
    // Set the amount of time until submissions are no longer accepted (measured in blocks)
    uint constant public submissionDeadline = 10;
    
    // Define the range of numbers that can be selected
    uint constant public N = 50;
    
    // Define the amount required to submit an entry
    uint constant public entryFee = 0.01 ether;
    
    // Store the submitted entries
    struct Entry {
        address payable sender;
        uint[6] numbers;
    }
    Entry[] public entries;
    
    // Store the winning numbers
    uint[6] public winningNumbers;
    
    // Store the time the contract was deployed
    uint public startTime;
    
    // Define the constructor function
    constructor() {
        startTime = block.number;
    }
    
    // Function to submit an entry
    function submitEntry(uint[6] memory numbers) public payable {
        require(block.number < startTime + submissionDeadline, "Submissions are no longer accepted.");
        require(msg.value >= entryFee, "Not enough ether sent.");
        require(numbers.length == 6, "Invalid number of entries.");
        for (uint i = 0; i < 6; i++) {
            require(numbers[i] >= 1 && numbers[i] <= N, "Invalid number range.");
        }
        require(checkDuplicates(numbers) == false, "Numbers must be unique.");
        
        entries.push(Entry(msg.sender, numbers));
    }
    
    // Function to check if an array has duplicates
    function checkDuplicates(uint[6] memory arr) internal pure returns(bool) {
        for (uint i = 0; i < arr.length; i++) {
            for (uint j = i + 1; j < arr.length; j++) {
                if (arr[i] == arr[j]) {
                    return true;
                }
            }
        }
        return false;
    }
    
    // Function to generate the winning numbers
    function generateWinningNumbers() public {
        require(block.number >= startTime + submissionDeadline, "Winning numbers cannot be generated yet.");
        require(winningNumbers[0] == 0, "Winning numbers have already been generated.");
        
        bytes32 hash = blockhash(block.number - 1);
        for (uint i = 0; i < 6; i++) {
            winningNumbers[i] = uint(keccak256(abi.encodePacked(hash, i))) % N + 1;
        }
    }
    
    // Function to claim the prize
    function claimPrize() public {
        require(block.number >= startTime + submissionDeadline, "Winning numbers have not been generated yet.");
        require(winningNumbers[0] != 0, "Winning numbers have not been generated yet.");
        
        for (uint i = 0; i < entries.length; i++) {
            if (compareNumbers(entries[i].numbers, winningNumbers)) {
                entries[i].sender.transfer(address(this).balance);
            }
        }
    }
    
    // Function to compare two arrays of numbers
    function compareNumbers(uint[6] memory arr1, uint[6] memory arr2) internal pure returns(bool) {
        for (uint i = 0; i < 6; i++) {
            if (arr1[i] != arr2[i]) {
                return false;
            }
        }
        return true;
    }
}


function compareArrays(uint[] memory arr1, uint[] memory arr2) internal pure returns(bool) {
    require(arr1.length == arr2.length, "Arrays must be of the same length.");

    // Create a mapping to count the occurrences of each number in the first array
    mapping(uint => uint) counts;
    for (uint i = 0; i < arr1.length; i++) {
        counts[arr1[i]]++;
    }

    // Decrement the count for each occurrence of a number in the second array
    for (uint i = 0; i < arr2.length; i++) {
        if (counts[arr2[i]] == 0) {
            return false; // This number is not in the first array
        }
        counts[arr2[i]]--;
    }

    return true;
}












pragma solidity ^0.8.0;

contract Lottery {
    uint public T;
    uint public N;
    uint public prize;
    uint[] public winningNumbers;
    mapping(address => uint[]) public submissions;
    mapping(address => bool) public hasClaimed;

    constructor(uint _T, uint _N) {
        T = block.number + _T;
        N = _N;
        prize = 0;
    }

    function submit(uint[] memory numbers) payable public {
        require(block.number < T, "Submissions are no longer accepted.");
        require(msg.value == 0.01 ether, "Each submission must include 0.01 ether.");
        require(numbers.length == 6, "Each submission must contain 6 numbers.");
        for (uint i = 0; i < 6; i++) {
            require(numbers[i] >= 1 && numbers[i] <= N, "Numbers must be between 1 and N.");
        }
        submissions[msg.sender] = numbers;
        prize += msg.value;
    }

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

    function claimPrize() public {
        require(block.number >= T, "Prize cannot be claimed yet.");
        require(winningNumbers.length == 6, "Winning numbers have not been computed yet.");
        require(compareArrays(submissions[msg.sender], winningNumbers), "You did not submit a winning combination.");
        require(!hasClaimed[msg.sender], "You have already claimed the prize.");
        hasClaimed[msg.sender] = true;
        payable(msg.sender).transfer(prize);
    }

    function compareArrays(uint[] memory arr1, uint[] memory arr2) internal pure returns(bool) {
        require(arr1.length == arr2.length, "Arrays must be of the same length.");

        // Create a mapping to count the occurrences of each number in the first array
        mapping(uint => uint) counts;
        for (uint i = 0; i < arr1.length; i++) {
            counts[arr1[i]]++;
        }

        // Decrement the count for each occurrence of a number in the second array
        for (uint i = 0; i < arr2.length; i++) {
            if (counts[arr2[i]] == 0) {
                return false; // This number is not in the first array
            }
            counts[arr2[i]]--;
        }

        return true;
    }
}




contract Lottery {
    // Constants
    uint256 public constant N = 10; // The range of numbers to choose from
    uint256 public constant T = 100; // The number of blocks after which submissions are closed
    uint256 public constant FEE = 0.01 ether; // The fee to enter the lottery
    
    // State variables
    address[] public players; // The array of players who submitted their numbers
    mapping(address => uint256[N]) public submissions; // The mapping of players to their submitted numbers
    bool public closed; // A flag to indicate if the lottery is closed
    uint256[N] public winningNumbers; // The array of winning numbers
    
    // Events
    event Submitted(address player, uint256[N] numbers); // Emitted when a player submits their numbers
    event Closed(uint256[N] winningNumbers); // Emitted when the lottery is closed and the winning numbers are computed
    event Claimed(address winner, uint256 amount); // Emitted when a winner claims their prize
    
    constructor() {
        closed = false;
        for (uint i = 0; i < N; i++) {
            winningNumbers[i] = 0;
        }
    }
    
    function submit(uint256[N] memory numbers) external payable {
        require(!closed, "The lottery is closed");
        require(msg.value == FEE, "Incorrect fee");
        require(isValid(numbers), "Invalid numbers");
        
        players.push(msg.sender);
        submissions[msg.sender] = numbers;
        
        emit Submitted(msg.sender, numbers);
        
        if (block.number >= T) {
            close();
        }
        
    }
    
    function close() internal {
        require(!closed, "The lottery is already closed");
        
        closed = true;
        
        computeWinningNumbers();
        
        emit Closed(winningNumbers);
        
    }
    
     function claim() external {
         require(closed, "The lottery is not closed yet");
         require(matches(submissions[msg.sender], winningNumbers), "You did not win");
         
         uint256 amount = address(this).balance / getNumberOfWinners();
         
         payable(msg.sender).transfer(amount);
         
         emit Claimed(msg.sender, amount);
     }


    uint[] public winners; // array of winner indices
    mapping(uint => bool) public claimed; // mapping of claimed status

    modifier onlyWinners() {
        require(isWinner(msg.sender)); // only winners can call
        _;
    }

    function claimPrize() public onlyWinners {
        uint index = getIndex(msg.sender); // get winner index
        require(!claimed[index]); // prize has not been claimed yet

        uint amount = prize / winners.length; // calculate prize amount per winner
        payable(msg.sender).transfer(amount); // send prize to winner
        claimed[index] = true; // set claimed as true
    }

    function isWinner(address player) private view returns (bool) {
        for (uint i = 0; i < winners.length; i++) {
            if (players[winners[i]] == player) { 
// check if player address matches any of the winner addresses 
                return true;
            }
        }
        return false;
    }

    function getIndex(address player) private view returns (uint) {
        for (uint i = 0; i < winners.length; i++) {
            if (players[winners[i]] == player) { 
// get the index of the player in the players array 
                return winners[i];
            }
        }
        revert("Player not found");
    }

}


    function claimPrize() public isWinner {
        prizeClaimed = true;
        winners[1] = msg.sender;
        payable(msg.sender).transfer(prize);
    }



    uint[] public winningNumbers;
    mapping(address => uint[]) public submissions;
    mapping(uint => address) public winners;
    bool public prizeClaimed;

    modifier isWinner() {
        require(block.number >= T, "Prize cannot be claimed yet.");
        require(winningNumbers.length == 6, "Winning numbers have not been computed yet.");
        require(compareArrays(submissions[msg.sender], winningNumbers), "You did not submit a winning combination.");
        require(!prizeClaimed, "The prize has already been claimed.");
        _;
    }



TEST

from brownie import Lottery

def test_compare_arrays():
    lottery = Lottery.deploy(100, 10, {"from": accounts[0]})
    arr1 = [1, 2, 3, 4, 5, 6]
    arr2 = [6, 5, 4, 3, 2, 1]
    arr3 = [1, 2, 3]
    arr4 = [1, 2]

    result1 = lottery.compareArrays(arr1,arr2)
    result2 = lottery.compareArrays(arr1,arr3)
    result3 = lottery.compareArrays(arr3,arr4)

    assert result1 == True
    assert result2 == False
    assert result3 == False
	
	
	
	brownie test tests/test_lottery.py