// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IERC20.sol";

contract Transfer {

    function transfer(address _tokenAddress, address _from, address _to, uint256 _amount) public {
        IERC20(_tokenAddress).transferFrom(_from, _to, _amount);
    }
}