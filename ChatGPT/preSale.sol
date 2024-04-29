// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract PreSale is Ownable {
    uint256 constant INCREASE_RATE = 1; // Constant rate for increasing egg price.
    uint256 constant START_TIME = 1734787200; // April 30, 2024, at 12:00 PM UTC
    uint256 constant END_TIME = 1737475200;   // May 31, 2024, at 12:00 PM UTC
    
    uint256 public eggsSold;
    mapping(address => uint256) public eggs;
    bool private paused;

    event EggsPurchased(address indexed purchaser, uint256 amount);
    event EggsRedeemed(address indexed redeemer, uint256 amount);

    constructor() Ownable(msg.sender) {
        paused = false;
    }

    function purchaseEgg() external payable {
        require(block.timestamp >= START_TIME && block.timestamp <= END_TIME, "Presale is not active");
        require(!paused, "Contract is paused");

        uint256 price = eggPrice();
        require(msg.value >= price, "Insufficient funds");

        uint256 amount = 1;
        eggs[msg.sender] += amount;
        eggsSold += amount;

        emit EggsPurchased(msg.sender, amount);
    }

    function bulkPurchaseEgg() external payable {
        require(block.timestamp >= START_TIME && block.timestamp <= END_TIME, "Presale is not active");
        require(!paused, "Contract is paused");

        uint256 price = eggPrice();
        require(msg.value >= price * 5, "Insufficient funds");

        uint256 amount = 5;
        eggs[msg.sender] += amount;
        eggsSold += amount;

        emit EggsPurchased(msg.sender, amount);
    }

    function redeemEgg(uint256 amount) external {
        require(eggs[msg.sender] >= amount, "Insufficient eggs");

        eggs[msg.sender] -= amount;
        eggsSold -= amount;

        emit EggsRedeemed(msg.sender, amount);
    }

    function eggPrice() public view returns (uint256) {
        return INCREASE_RATE * eggsSold + 1; // Simple linear price increase
    }

    function withdrawal() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }

    function pause() external onlyOwner {
        paused = true;
    }

    function resume() external onlyOwner {
        paused = false;
    }

    function isPaused() external view returns (bool) {
        return paused;
    }
}
