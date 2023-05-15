// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract Ballot {

    address public chairperson;

    struct Voter {
        uint weight; 
        bool voted;  
        uint vote;  
    }

    struct Candidate {
        bytes32 name;   
        uint voteCount; 
    }                                               

    mapping(address => Voter) public voters;// stores a voter struct for each possible address.
    Candidate[] public candidates;//Store candidates
    
    constructor(bytes32[] memory candidateNames) {// Create a new ballot to choose candidate

        chairperson = msg.sender;
        voters[chairperson].weight = 1;
        for (uint i = 0; i < candidateNames.length; i++) {
            candidates.push(Candidate({name: candidateNames[i], voteCount: 0}));
        }
    }

    function giveRightToVote(address voter) external {
        require(msg.sender == chairperson,"Only chairperson can give right to vote.");
        require(!voters[voter].voted,"The voter already voted.");
        require(voters[voter].weight == 0);
        voters[voter].weight = 1;
    }

    /// Give your vote to candidate `candidates[candidate].name`.
    function vote(uint candidate) external {
        Voter storage sender = voters[msg.sender];
        require(sender.weight != 0, "Has no right to vote");
        require(!sender.voted, "Already voted.");
        sender.voted = true;
        sender.vote = candidate;
        candidates[candidate].voteCount += sender.weight;
    }

    function winningcandidate() public view returns (uint winningcandidate_){
        uint winningVoteCount = 0;
        for (uint p = 0; p < candidates.length; p++) {
            if (candidates[p].voteCount > winningVoteCount) {
                winningVoteCount = candidates[p].voteCount;
                winningcandidate_ = p;
            }
        }
    }

    function winnerName() external view returns (bytes32 winnerName_){
        winnerName_ = candidates[winningcandidate()].name;
    }
}


// Declare the problem want to solve and frame high level. Scenario for voting system. 
// Transperancy. Important functions. Write. 

// Feedback:
// Start adding comments using solidity standard
// Use events for emitting address of winner instead of function that stores winner address
// Use modifiers instead of require statments 