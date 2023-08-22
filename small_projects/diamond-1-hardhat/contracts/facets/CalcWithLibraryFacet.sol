// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library CalculatorLib {
    bytes32 constant CALCULATOR_STORAGE_POSITION = keccak256("calculator.storage");

    struct CalculatorState {
        uint256 result;
    }

    function calculatorStorage() internal pure returns (CalculatorState storage cs) {
        bytes32 position = CALCULATOR_STORAGE_POSITION;
        assembly {
            cs.slot := position
        }
    }

    function setResult(uint256 _result) internal {
        CalculatorState storage calculatorState = calculatorStorage();
        calculatorState.result = _result;
    }

    function getResult() internal view returns (uint256) {
        CalculatorState storage calculatorState = calculatorStorage();
        return calculatorState.result;
    }

    function add(uint256 _a, uint256 _b) internal {
        setResult(_a + _b);
    }

    function subtract(uint256 _a, uint256 _b) internal {
        require(_a >= _b, "The result would be negative");
        setResult(_a - _b);
    }

}

contract CalculatorFacet {
    function add(uint256 _a, uint256 _b) external {
        CalculatorLib.add(_a, _b);
    }

    function subtract(uint256 _a, uint256 _b) external {
        CalculatorLib.subtract(_a, _b);
    }

    function getResult() external view returns (uint256) {
        return CalculatorLib.getResult();
    }
}
