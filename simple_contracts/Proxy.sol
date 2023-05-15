 SPDX-License-Identifier

pragma solidity ^0.8.0;



contract Target {

    function setSender() public view returns (address){
        return msg.sender;
    }

    function setValue() public view returns (uint){
        return msg.value;
    }

    function setVar(uint256 _var) public payable {
        myVar= _var;
    }

    fallback(bytes calldata input) external [payable] returns (bytes memory output){
        return input;
    }
     
}
        

(bool success, bytes memory data) = _to.call{vaulue: 1 ether , gasPrice:}("getSender")
// call vs delgate call
// 


contract Test {             
    function test() public {             
        Target t = new Target();                        
        address sender = t.setSender();                        
        uint value = t.setValue();                        
        assert(sender == msg.sender);                        
        assert(value == msg.value);                        
    }                        
}                        
    