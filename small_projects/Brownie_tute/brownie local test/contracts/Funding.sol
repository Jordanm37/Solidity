// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";


contract Funding {

    address public owner;
    uint256 constant minimumAmount = 50; //entry fee is 50 USD 
    AggregatorV3Interface internal priceFeed;
    mapping (address => uint256) public funders;

    constructor(address _priceFeedAddress) {
        priceFeed = AggregatorV3Interface(_priceFeedAddress);
        owner = msg.sender;
    }

  

    function getPrice() public view returns(uint256) {
       (, int256 answer, , ,) = priceFeed.latestRoundData();
       return uint256(answer);
    }

    function convert(uint256 _amount) public view returns (uint256) {

        /*

        50usd 
       1ETH =  157230000000/10e8; usd
       ? == 50usd

       50 / 1572.3

       (10 ** 18) WEI = 1500usd
       ? === 50

      ( 50 * (10 ** 18) 10 ** 8 ) / 1500usd 
        
        */

        uint256 ethPrice = getPrice();
        uint256 entryFeeInWei = (_amount * 10 ** 26) / ethPrice;

        return entryFeeInWei;

    }

      function donate(uint256 usdAmount) public payable {
        require (usdAmount >= minimumAmount, "You must donate at least $50");
        funders[msg.sender] = msg.value;
    }

     modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not owner");
        _;
    }

  function withdraw() external payable onlyOwner {
    (bool success, ) = payable(owner).call{value: address(this).balance}("");
    require(success, "Withdrawal failed failed");
  }

}
