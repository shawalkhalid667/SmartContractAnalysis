// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

contract MultiCoin is ERC20, Ownable, ERC20Burnable {
    // Constants
    string public constant NAME = "Multicoin";
    string public constant SYMBOL = "MTCN";
    uint8 public constant DECIMALS = 18;
    uint256 public constant INITIAL_SUPPLY = 2_000_000_000 * (10 ** uint256(DECIMALS));

    // Constructor
    constructor(address _initialOwner) ERC20(NAME, SYMBOL) Ownable(_initialOwner) {
        _mint(_initialOwner, INITIAL_SUPPLY);
    }

    // Burn function
    function burn(uint256 amount) public onlyOwner override {
        _burn(msg.sender, amount);
    }

    // Transfer Ownership
    function transferOwnership(address newOwner) public override onlyOwner {
        super.transferOwnership(newOwner);
    }
}
