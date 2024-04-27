
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Importing OpenZeppelin's contract libraries for ERC20, Burnable ERC20 and Ownable contracts.
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// Multicoin contract that inherits from the ERC20, ERC20Burnable and Ownable contracts.
contract Multicoin is ERC20, ERC20Burnable, Ownable {
    // Initial supply: 2,000,000,000 tokens
    uint256 private constant INITIAL_SUPPLY = 2 * 10**9 * 10**18;

    // Constructor
    constructor(address owner) ERC20("Multicoin", "MTCN") Ownable(owner) {
        // Transfer ownership to the provided address
        transferOwnership(owner);

        // Mint the initial supply
        _mint(owner, INITIAL_SUPPLY);

        // Emitting a transfer event for the initial token allocation
        emit Transfer(address(0), owner, INITIAL_SUPPLY);
    }

    // Burn function that allows only the owner to burn a specified amount of tokens
    function burn(uint256 amount) public override onlyOwner {
        super.burn(amount);
    }
}
