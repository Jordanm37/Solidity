// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { FlashLoanSimpleReceiverBase } from './FlashLoanSimpleReceiverBase.sol';
import { IPoolAddressesProvider } from '../interfaces/IPoolAddressesProvider.sol';
import { IPool } from '../interfaces/IPool.sol';
import { IERC20 } from '../interfaces/IERC20.sol';

contract V3FlashLoan is FlashLoanSimpleReceiverBase {
    constructor(IPoolAddressesProvider _provider) FlashLoanSimpleReceiverBase(_provider) {}

    function executeOperation(
        address asset,
        uint256 amount,
        uint256 premium,
        address initiator,
        bytes calldata params
    ) external override returns (bool) {
    //   any actions that need to be performed by the loan goes here

    uint256 totalOwed = amount + premium;
    
    // Approve the pool to deduct the amount owed from the contract

    IERC20(asset).approve(address(POOL), totalOwed);

    return true;
  }

  function getFlashLoan(
        address asset,
        uint256 amount
    ) public {
        address receiverAddress = address(this);

        bytes memory params = "";
        uint16 referralCode = 0;

        POOL.flashLoanSimple(
            receiverAddress,
            asset,
            amount,
            params,
            referralCode
        );
    }
}
