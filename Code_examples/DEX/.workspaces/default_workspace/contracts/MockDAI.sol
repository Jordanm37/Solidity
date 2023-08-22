// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

contract MockDAI is ERC20, ERC20Burnable {
    constructor() ERC20("Mock DAI", "DAI") {
        _mint(msg.sender, 1000000 * 10 ** decimals());
    }
}
