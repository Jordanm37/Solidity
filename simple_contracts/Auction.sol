// SPDX-License-Identifiier

pragma solidity ^0.8.0;

    /// @title A title that should describe the contract/interface
    /// @author The name of the author
    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details

//make auction for nft that accepts bids and mints and transfer nft to higest bidder then close the contract


interface IERC721 {
    function transferFrom(
        address _from,
        address _to,
        uint _nftId
    ) external;
}


contract Auction {

    IERC721 public immutable nft;
    uint public immutable nftId;
    address payable private owner;
    uint256 public minimumPrice;
    mapping(address => uint256) register;
    address[] public bidders;
    mapping(address => uint256) public fundsByBidder;
    bool public auctionStatus;
    uint public auction_duration;
    address payable public highestBidder;
    uint public highestBid;
    uint public end_time;
    uint public start_time;


    // time  immutable/ constants

    // enum State{Default, Running, Finalized}
    // State public auctionState;
    // in constructor auctionState = State.Running;
    constructor(uint _minimumPrice, uint _auction_duration, uint _nftId, address _nft) {
        owner  = payable(msg.sender);
        highestBid = _minimumPrice;
        auctionStatus = false;
        auction_duration = _auction_duration;

        nft = IERC721(_nft);
        nftId = _nftId;
    }

    modifier onlyOwner {
        require(msg.sender == owner, "Only the contract owner can call this function");
        _;
    }

    modifier onlyNotOwner {
        require(msg.sender != owner);
        _;
    }

    modifier onlyAfterStart {
        require(block.number < start_time, "not started");
        _;
    }

    modifier onlyBeforeEnd {
        require(block.number > end_time, "not finished");
        _;
    }

    // Events being emitted on registration
    event Registered(address indexed bidder); //indexed events and 
    event Start();
    event Bid(address indexed sender, uint amount);
    event End(address winner, uint amount);
    event highestBidIncreased(address bidder, uint amount);
    
    
    function registerBidders(address _registers) public payable {
        // On registration, the user should be added to the register mapping and  the users array
        
        bidders.push(_registers);
        register[_registers] = bidders.length -1;

    }

    function start_Auction() public onlyOwner{
        
        nft.transferFrom(msg.sender, address(this), nftId);
        auctionStatus =true;
        start_time = block.timestamp; 
        end_time = block.timestamp + auction_duration; //add time ie hours and minutes and remove number of variables stored 

    }

    function bid() public payable onlyAfterStart{
        if(msg.value > highestBid) {
            
            highestBidder = payable(msg.sender);
            highestBid = msg.value;
            fundsByBidder[msg.sender] = highestBid;
            emit highestBidIncreased(msg.sender, msg.value);
        }
        else {
            revert("sorry, the bid is not high enough!");
        }
     }


    //automate close of the auction and trasnfer of item  
    function closeAuction() public onlyOwner onlyAfterStart payable{
        address withdrawalAccount;
        uint withdrawalAmount;

        auctionStatus = false;
        nft.transferFrom(address(this), highestBidder, nftId);
        owner.transfer(highestBid);
        emit End(highestBidder, highestBid);

        if(msg.sender != highestBidder){
            withdrawalAccount = msg.sender;
            withdrawalAmount = fundsByBidder[withdrawalAccount];
            payable(msg.sender).transfer(highestBid);
        }
        //auctionState = State.Finalized;

    }
    


    function destroy() external onlyOwner{
        selfdestruct(payable(owner)); 
        
        
        // also sends out money
    }

    // function place_bid() public payable onlynotOwner returns(bool) {
}

//use aporval to save gas for transfer of nft from owner to highest bidder
// what should contract do?
//register bidders
//collect bids from registered bidders that are greater than the higest bid or minimum bidd and accept funds from new highest bidder
//close auction after expiration
//transfer nft to highest bidder and trasnfers funds to owner
//return all other deposited funds to other registered bidders