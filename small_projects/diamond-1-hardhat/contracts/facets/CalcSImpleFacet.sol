// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SimpleCalculator {
    uint256 public result;

    function add(uint256 _a, uint256 _b) public {
        result = _a + _b;
    }

    function subtract(uint256 _a, uint256 _b) public {
        require(_a >= _b, "The result would be negative");
        result = _a - _b;
    }

    function multiply(uint256 _a, uint256 _b) public {
        result = _a * _b;
    }

    function divide(uint256 _a, uint256 _b) public {
        require(_b != 0, "Division by zero is not allowed");
        result = _a / _b;
    }
}