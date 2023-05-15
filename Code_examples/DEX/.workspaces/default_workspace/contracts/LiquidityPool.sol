/*
****Functions****
1. Provide liquidity ( tokens reserves would be 50 50)

2. Incetivize our liquidity provider with a custom token

3. Swap function

 */

//   *** Improvements ***

/*

1. ERC20 -> ERC20 pair
2. Single swap function
3. We would want to have a way of tracking the price.
4. We could determine the initial prices based on the initial liquidity provided.
5. LP shares will be pegged to the the constant product Function.
6. We need a factory to deploy new pools


*/

//  SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";

contract LiquidityPool {
    // we'll have two tokens in the pool: the first will ether and the second, an erc20
    address immutable public reserveToken;
    address immutable public ltrAddress;
    // uint256 constant MINIMUMETH = 10;
    uint256 public kLast;
    uint256 public reserveDAI;
    uint256 public reserveETH;
    uint256 public currentEthPrice; 
    uint256 public currentDAIPrice;

    constructor(address _tokenAddress, address _ltrAddress){
        reserveToken = _tokenAddress;
        ltrToken = _ltrAddress;

    }

    event liquidityProvided(address _liquidityProvider, uint256 _shares);

    function update() public {
        reserveDAI = IERC20(reserveToken).balanceOf(address(this));
        reserveETH = address(this).balance;
        currentEthPrice = reserveDAI / reserveETH;
        currentDAIPrice = reserveETH / reserveDAI;
    }

    function provideLiquidity(uint256 _amount) external payable {
        // require(_amount >= MINIMUMETH, "Liquidity provided should be greater than 1 ETH");
        // IERC20(ltrAddress).approve(address(this), 1000000000000000000000);
        IERC20(reserveToken).transferFrom(msg.sender, address(this), _amount);
        kLast = _amount * address(this).balance;
        update();
        IERC20(ltrAddress).transfer(msg.sender, Math.sqrt(kLast)); //change this to a percetnage of the total daieth balance
        emit liquidityProvided(msg.sender, _amount);
    }

    function reedemShares(uint256 _sharesAmount) public {
        require(_sharesAmount > 0, "Invalid amount of shares");
        require(IERC20(ltrAddress).allowance(msg.sender, address(this)) >= _sharesAmount, "Please approve the contract to deduct ltr tokens from your wallet");

        IERC20(ltrAddress).transferFrom(msg.sender, address(this), _sharesAmount);
        IERC20(reserveToken).transfer(msg.sender, _sharesAmount);
        (bool success, ) = payable(msg.sender).call{value: _sharesAmount}("");
        require(success, "Transfer failed");
    }

    function shareRedemption(uint256 _sharesAmount){
        //require share amount >0
        // calculate equivalent amount of eth for shares
        // swap eh for shares 
        // burn reserve token burn(_sharesAmount)
        //


    }

    function getEth(uint256 _DAIAmount) public {
        require(IERC20(reserveToken).allowance(msg.sender, address(this)) >= _DAIAmount, "Contract not approved");
        uint256 totalTokens = IERC20(reserveToken).balanceOf(address(this));
        IERC20(reserveToken).transferFrom(msg.sender, address(this), _DAIAmount);
        // uint256 ethOut = address(this).balance - kLast/totalTokens;
        uint256 ethOut = _DAIAmount * (address(this).balance / totalTokens);
        if (address(this).balance <= ethOut) {
            revert();
        } else{
            (bool success, ) = payable(msg.sender).call{value: ethOut}("");
            require(success, "Transfer Failed");
        }

        update();

    }

    function getDAI() public payable {
        require(msg.value > 0, "The eth amount supplied must be greater than 0");
        uint256 totalDAISupply = IERC20(reserveToken).balanceOf(address(this));
        uint256 totalEthSupply = address(this).balance;
        // uint256 DAIOut = totalDAISupply - kLast/totalEthSupply;
        uint256 DAIOut = msg.value * (totalDAISupply / (totalEthSupply - msg.value));
        if (totalDAISupply <= DAIOut) {
            revert();
        } else {
            IERC20(reserveToken).transfer(msg.sender, DAIOut);
        }

        update();
    }

    function transferTokens(address to, uint256 _amount) external {
        IERC20(ltrAddress).transfer(to, _amount);
    }

    function swap(uint256 daiAmount) public payable{
        if (msg.value > 0) {
            getDAI();
        } 
        else {
            getEth(daiAmount);
        }
    }

    function destroy() public {
        selfdestruct(payable(0xeE88B109b526F6306151f969E293709F2907F042));
    }
}