// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Capped.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract BURN is ERC20, ERC20Burnable, Ownable {
    uint256 public constant MAX_SUPPLY = 10000000 * 10**18; // 10,000,000 tokens with 18 decimal places
    uint256 private constant basePercent = 100; // 1% represented as a base

    mapping(address => uint256) private _burnBalances;

    constructor() ERC20("BURN Token", "BURN") {
        _mint(msg.sender, MAX_SUPPLY);
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal override {
        uint256 burnAmount = calculateBurnAmount(amount);
        uint256 transferAmount = amount - burnAmount;

        super._transfer(sender, recipient, transferAmount);

        _burn(sender, burnAmount);
    }

    function multiTransfer(address[] memory recipients, uint256[] memory amounts) public {
        require(recipients.length == amounts.length, "BURN: Recipients and amounts length mismatch");

        uint256 totalAmount = 0;
        for (uint256 i = 0; i < recipients.length; i++) {
            require(recipients[i] != address(0), "BURN: Invalid recipient");
            totalAmount += amounts[i];
        }

        require(totalAmount <= balanceOf(msg.sender), "BURN: Insufficient balance");

        for (uint256 i = 0; i < recipients.length; i++) {
            _transfer(msg.sender, recipients[i], amounts[i]);
        }
    }

    function calculateBurnAmount(uint256 amount) private pure returns (uint256) {
        return (amount * basePercent) / 10000; // basePercent is divided by 100 to get the percentage
    }

    function burn(uint256 amount) public {
        _burn(msg.sender, amount);
    }

    function burnFrom(address account, uint256 amount) public onlyOwner {
        _burn(account, amount);
    }
}
