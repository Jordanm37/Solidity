// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./1_Storage.sol";

contract Machine {
    uint256 public calculateResult;
    address public user;
    Storage public s;


    event AddedValuesByDelegateCall(uint256 a, uint256 b, bool success);
    event AddedValuesByCall(uint256 a, uint256 b, bool success);

    constructor(Storage addr) {
        s = addr;
        calculateResult = 0;
    }

    function saveValue(uint256 x) public returns (bool) {
        s.setValue(x);
        return true;
    }

    function getValue() public view returns(uint256){
        return s.val();
    }

    function addValuesWithCall(address calculator, uint256 a, uint256 b) public returns(uint256){
        (bool success, bytes memory result) = calculator.call(abi.encodeWithSignature("add(uint256,uint256)", a, b));  //To select  funciton that need to call
        emit AddedValuesByCall(a, b, success);
        return abi.decode(result, (uint256));
    }

    function addValuesWithDelegateCall(address calculator, uint256 a, uint256 b) public returns(uint256) {
        (bool success, bytes memory result) = calculator.delegatecall(abi.encodeWithSignature("add(uint256,uint256)", a, b));
        emit AddedValuesByDelegateCall(a, b, success);
        return abi.decode(result, (uint256));
    }
}


// storage slot 1 -> variable s of type storage
// storage slot 2 -> variable calculateResult of type uint
