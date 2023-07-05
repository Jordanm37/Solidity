// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


contract TokenPool {
    IERC20 public dexToken;
    address[] public providers;

    constructor(address _dexTokenAddress) {
        dexToken = IERC20(_dexTokenAddress);
    }

    function provideLiquidity(uint256 _amount1, uint256 _amount2, address _token1, address _token2) public payable {
        require(_amount1 == _amount2, "tokens provided must be of equal value");
        uint256 totalValueSent = 0;
        IERC20(_token1).transferFrom(msg.sender, address(this), _amount1);
        IERC20(_token2).transferFrom(msg.sender, address(this), _amount2);
        totalValueSent = _amount1 + _amount2;
        dexToken.transfer(msg.sender, totalValueSent);
    }


    function swapTokens(uint256 _amount, address _token1, address _token2) public {
        require(_amount > 0, "Amount must be greater than 0");
        IERC20(_token1).transferFrom(msg.sender, address(this), _amount);
        IERC20(_token2).transfer(msg.sender, _amount);
        
    }

    function redeemShare(uint256 _amount, address _dai, address _gst) public {
        require(_amount > 0, "Amount must be greater than 0");
        dexToken.transferFrom(msg.sender, address(this), _amount);
        IERC20(_dai).transfer(msg.sender, _amount/2);
        IERC20(_gst).transfer(msg.sender, _amount/2);
    }
}