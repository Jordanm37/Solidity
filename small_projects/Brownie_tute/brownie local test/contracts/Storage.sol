// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

/**
 * @title Storage
 * @dev Store & retrieve value in a variable
 * @custom:dev-run-script ./scripts/deploy_with_ethers.ts
 */
contract Storage {

    uint256 number;
    event StoredWithCall(address _from);
    event StoredWithDelegateCall(address _user);

    /**
     * @dev Store value in variable
     * @param num value to store
     */
    function storeCall(uint256 num) public {
        number = num;
        emit StoredWithCall(msg.sender);
    }

     function storeDelegateCall(uint256 num2) public {
        number = num2;
        emit StoredWithDelegateCall(msg.sender);
    }

    /**
     * @dev Return value 
     * @return value of 'number'
     */
    function retrieve() public view returns (uint256){
        return number;
    }
}