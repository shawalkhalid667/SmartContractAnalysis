// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Importing OpenZeppelin's ERC20 and Ownable contracts
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// LunchMoney token contract
contract LunchMoney is ERC20, Ownable {
    constructor() ERC20("LunchMoney", "LM") Ownable(msg.sender) {
        // Mint initial supply
        _mint(msg.sender, 1000000 * 10 ** decimals());
    }

    // Constructor function to initialize the ERC20 token with initial supply and details
    constructor() ERC20("Lunch Money", "LMY") {
        // Setting the initial supply of LunchMoney tokens to 250,000,000
        _mint(msg.sender, 250000000 * (10 ** uint256(decimals())));
    }

    // Function to burn LunchMoney tokens, reducing the total supply
    function burn(uint256 _value) public onlyOwner {
        // Reducing the balance of the burner's account
        _burn(msg.sender, _value);

        // Emitting the Burn event
        emit Burn(msg.sender, _value);
    }

    // Overriding the transfer function to include onlyOwner modifier for additional security
    function transfer(address recipient, uint256 amount) public override onlyOwner returns (bool) {
        return super.transfer(recipient, amount);
    }

    // Overriding the transferFrom function to include onlyOwner modifier for additional security
    function transferFrom(address sender, address recipient, uint256 amount) public override onlyOwner returns (bool) {
        return super.transferFrom(sender, recipient, amount);
    }
}
