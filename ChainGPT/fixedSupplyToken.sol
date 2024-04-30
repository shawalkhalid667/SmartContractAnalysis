
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract FixedSupplyToken is ERC20, Ownable {
    constructor() ERC20("Example Fixed Supply Token", "FIXED") {
        _mint(msg.sender, 21000000 * (10 ** uint256(decimals())));
    }

    // Function to mint tokens
    // Only the contract owner can call this function
    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    // Overriding the transfer function to include the custom logic
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    // Overriding the transferFrom function to include the custom logic
    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), allowance(sender, _msgSender()) - amount);
        return true;
    }

    // Overriding the approve function to include the custom logic
    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
}
