// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract Storage {

    uint256 public val;

    constructor(uint _val) {
        val = _val;
    }
    function setValue(uint256 num) public {
        val = num;
    }
}
