
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Importing OpenZeppelin's PausableToken Contract
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Pausable.sol";
// Importing OpenZeppelin's Ownable Contract
import "@openzeppelin/contracts/access/Ownable.sol";

// CodexCoin is a Pausable ERC20 token
contract CodexCoin is ERC20Pausable, Ownable {
    /**
     * @dev Constructor that gives msg.sender all of the existing tokens.
     */
    constructor(
        uint256 initialSupply,
        string memory tokenName,
        string memory tokenSymbol
    ) ERC20(tokenName, tokenSymbol) {
        _mint(msg.sender, initialSupply);
    }

    /**
     * @dev Function to reclaim all ERC20Basic compatible tokens
     * @param token ERC20Basic The address of the token contract
     */
    function reclaimToken(IERC20 token) external onlyOwner {
        uint256 balance = token.balanceOf(address(this));
        token.transfer(owner(), balance);
    }
}
