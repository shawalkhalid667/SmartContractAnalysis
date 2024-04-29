
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Importing OpenZeppelin's Ownable Contract to manage contract's ownership
import "@openzeppelin/contracts/access/Ownable.sol";
// Importing OpenZeppelin's SafeMath Library to perform mathematical operations safely
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract PreSale is Ownable {
    using SafeMath for uint256;

    uint256 public constant INCREASE_RATE = 1; // Increase rate for egg price
    uint256 public constant START_TIME = 1622527200; // Start time of the pre-sale
    uint256 public constant END_TIME = 1622630800; // End time of the pre-sale
    uint256 public eggsSold; // Total number of eggs sold
    mapping(address => uint256) public eggs; // Mapping to track the number of eggs owned by each address
    bool private _paused; // State variable to track the pause status of the contract

    event EggsPurchased(address indexed buyer, uint256 amount);
    event EggsRedeemed(address indexed buyer, uint256 amount);

    constructor() {
        _paused = false; // Contract is active (not paused) by default
    }

    function purchaseEgg() public {
        require(now >= START_TIME, "PreSale: Pre-sale has not started yet");
        require(now <= END_TIME, "PreSale: Pre-sale has ended");
        require(!_paused, "PreSale: Contract is currently paused");

        eggs[msg.sender] = eggs[msg.sender].add(1);
        eggsSold = eggsSold.add(1);
        emit EggsPurchased(msg.sender, 1);
    }

    function bulkPurchaseEgg() public {
        require(now >= START_TIME, "PreSale: Pre-sale has not started yet");
        require(now <= END_TIME, "PreSale: Pre-sale has ended");
        require(!_paused, "PreSale: Contract is currently paused");

        eggs[msg.sender] = eggs[msg.sender].add(5);
        eggsSold = eggsSold.add(5);
        emit EggsPurchased(msg.sender, 5);
    }

    function redeemEgg() public onlyOwner {
        require(eggs[msg.sender] > 0, "PreSale: No eggs to redeem");
        eggs[msg.sender] = 0;
        emit EggsRedeemed(msg.sender, eggs[msg.sender]);
    }

    function eggPrice() public view returns (uint256) {
        return eggsSold.mul(INCREASE_RATE);
    }

    function withdrawal() public onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }

    function pause() public onlyOwner {
        _paused = true;
    }

    function resume() public onlyOwner {
        _paused = false;
    }

    function isPaused() public view returns (bool) {
        return _paused;
    }
}
