// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract LunchMoney is ERC20, Ownable {
    uint256 private constant INITIAL_SUPPLY = 250_000_000 * (10 ** 18);

    event TokensBurned(address indexed burner, uint256 amount);

    constructor() ERC20("Lunch Money", "LMY") Ownable(msg.sender) {
        _mint(msg.sender, INITIAL_SUPPLY);
    }

    function burn(uint256 amount) external {
        require(amount > 0, "Amount must be greater than zero");
        require(balanceOf(msg.sender) >= amount, "Insufficient balance to burn");
        
        _burn(msg.sender, amount);
        emit TokensBurned(msg.sender, amount);
    }

    function mint(address account, uint256 amount) external onlyOwner {
        require(account != address(0), "Mint to the zero address");
        require(amount > 0, "Mint amount must be greater than zero");
        
        _mint(account, amount);
    }

    
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        require(recipient != address(0), "Transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        
        return super.transfer(recipient, amount);
    }
    
    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        require(sender != address(0), "Transfer from the zero address");
        require(recipient != address(0), "Transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        
        return super.transferFrom(sender, recipient, amount);
    }
}
