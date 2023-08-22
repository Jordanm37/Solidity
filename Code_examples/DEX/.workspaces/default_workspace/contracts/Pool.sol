// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";

contract Pool {
    address public immutable token0;
    address public immutable token1;
    address public immutable ltrAddress;
    uint256 public kLast;
    uint256 public reserve0;
    uint256 public reserve1;
    uint256 public price0;
    uint256 public price1;

    event liquidityProvided(address _liquidityProvider, uint256 _shares);

    constructor(address _token0, address _token1, address _ltrAddress) {
        token0 = _token0;
        token1 = _token1;
        ltrAddress = _ltrAddress;
    }

    function update() private {
        reserve0 = IERC20(token0).balanceOf(address(this));
        reserve1 = IERC20(token1).balanceOf(address(this));
        price0 = reserve1 / reserve0;
        price1 = reserve0 / reserve1;
    }



    function provideLiquidity(uint256 _amount0, uint256 _amount1) external {
        require(IERC20(token0).allowance(msg.sender, address(this)) >= _amount0, "Contract not approved");
        require(IERC20(token1).allowance(msg.sender, address(this)) >= _amount1, "Contract not approved");
        IERC20(token0).transferFrom(msg.sender, address(this), _amount0);
        IERC20(token1).transferFrom(msg.sender, address(this), _amount1);
        kLast = IERC20(token0).balanceOf(address(this)) * IERC20(token1).balanceOf(address(this));
        uint256 shares = Math.sqrt(kLast);
        IERC20(ltrAddress).transfer(msg.sender, shares);
        update();
        emit liquidityProvided(msg.sender, shares);
    }

    function get0(uint256 _amount1) private {
        require(IERC20(token1).allowance(msg.sender, address(this)) >= _amount1, "Contract not approved");
        IERC20(token1).transferFrom(msg.sender, address(this), _amount1);
        uint256 amountOut = reserve0 - (kLast / (reserve1 + _amount1));
        if (reserve0 <= amountOut) {
            revert();
        } else{
            IERC20(token0).transfer(msg.sender, amountOut);
        }

        update();
    }

    function get1(uint256 _amount0) private {
        require(IERC20(token0).allowance(msg.sender, address(this)) >= _amount0, "Contract not approved");
        IERC20(token0).transferFrom(msg.sender, address(this), _amount0);
        uint256 amountOut = reserve1 - (kLast / (reserve0 + _amount0)); 
        if (reserve1 <= amountOut) {
            revert();
        } else{
            IERC20(token1).transfer(msg.sender, amountOut);
        }
        update();
    }

    function swap(uint256 _token0, uint256 _token1) public {
        if (_token0 > 0 && _token1 == 0) {
            get1(_token0);
        } else if (_token1 > 0 && _token0 == 0) {
            get0(_token1);
        } else {
            revert();
        }
    }
}