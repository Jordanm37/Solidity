// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

library StorageSlot {
    
    struct AddressSlot {
        address value;
    }

     struct AdminSlot {
        address value;
    }

    struct IntSlot {
        uint256 value;
    }

    function getAddressSlot(bytes32 slot) internal pure returns (AddressSlot storage r) {
        assembly {
            r.slot := slot
        }
    }

   function getAdminSlot(bytes32 slot) internal pure returns (AdminSlot storage r) {
        assembly {
            r.slot := slot
        }
    } 

    function getIntSlot(bytes32 slot) internal pure returns (IntSlot storage r) {
        assembly {
            r.slot := slot
        }
    } 

}


contract Proxy {

    bytes32 internal constant _IMPLEMENTATION_SLOT = bytes32(uint256(keccak256("eip1967.proxy.implementation")) - 1);

    bytes32 internal constant _ADMIN_SLOT = bytes32(uint256(keccak256("eip1967.proxy.admin")) - 1);

    bytes32 internal constant _INT_SLOT = bytes32(uint256(keccak256("eip1967.proxy.number")) - 1);



    constructor() {
        assert (_ADMIN_SLOT == bytes32(uint256(keccak256("eip1967.proxy.admin")) - 1));
        _setAdmin(msg.sender);
    }


    modifier ifAdmin() {
        if(msg.sender == _getAdmin()) {
            _;
        } else {
            _fallback();
        }
    }

    function _setAdmin(address _add) private {
        require( _add != address(0), "admin = zero address");
        StorageSlot.getAdminSlot(_ADMIN_SLOT).value = _add;
    }

    function _getAdmin() private view returns (address) {
       return StorageSlot.getAdminSlot(_ADMIN_SLOT).value;
    }

    function changeAdmin(address _admin) external ifAdmin {
        _setAdmin(_admin);
    }

    function admin() external ifAdmin returns (address) {
        return _getAdmin();
    }

    function _delegate(address implementationAddress) internal virtual {
        assembly {
            calldatacopy(0, 0, calldatasize())
            let result := delegatecall(gas(), implementationAddress, 0, calldatasize(), 0, 0)

            returndatacopy(0, 0, returndatasize())

            switch result
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }

    function _setImplementation(address _impl) private {
        StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value = _impl;
    }

    function _getImplementation() private view returns (address) {
       return StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value;
    }

    function implementation() external ifAdmin returns (address) {
        return _getImplementation();
    }

    function _upgrade(address _target) external ifAdmin {
        _setImplementation(_target);
    }

    function _setNumber(uint256 _num) external {
        StorageSlot.getIntSlot(_INT_SLOT).value = _num;
    }

    function _getNumber() private view returns (uint256) {
       return StorageSlot.getIntSlot(_INT_SLOT).value;
    }

    function getStoredNumber() external ifAdmin returns(uint256) {
        return _getNumber();
    }

    
    function _fallback() internal virtual {
        _delegate(_getImplementation());
    }

    fallback() external payable virtual {
        _fallback();
    }

    receive() external payable virtual {
        _fallback();
    }
}

contract ProxyAdmin {
    address owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not Owner");
        _;
    }

    function changeAdmin(address payable proxy, address admin) external onlyOwner {
        Proxy(proxy).changeAdmin(admin);
    }
    function upgradeTo(address payable proxy, address upgrade) external onlyOwner {
        Proxy(proxy)._upgrade(upgrade);
    }

    function getProxyAdmin(address proxy) external view returns(address) {
        (bool success, bytes memory result) = proxy.staticcall(abi.encodeCall(Proxy.admin, ()));
        require(success, "Call Failed");
        return abi.decode(result, (address));
    }

    function getProxyImplementation(address proxy) external view returns(address) {
        (bool success, bytes memory result) = proxy.staticcall(abi.encodeCall(Proxy.implementation, ()));
        require(success, "Call Failed");
        return abi.decode(result, (address));
    }
}


