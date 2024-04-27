
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

// RefundVault Contract
contract RefundVault is Ownable {
    using SafeMath for uint256;

    enum State { Active, Refunding, Closed }

    State public state;
    mapping (address => uint256) public deposited;
    address payable public wallet;

    event Closed();
    event RefundsEnabled();
    event Refunded(address indexed beneficiary, uint256 weiAmount);

    constructor(address payable _wallet) {
        wallet = _wallet;
        state = State.Active;
    }

    function deposit(address investor) public payable onlyOwner {
        require(state == State.Active);
        deposited[investor] = deposited[investor].add(msg.value);
    }

    function close() public onlyOwner {
        require(state == State.Active);
        state = State.Closed;
        emit Closed();
        wallet.transfer(address(this).balance);
    }

    function enableRefunds() public onlyOwner {
        require(state == State.Active);
        state = State.Refunding;
        emit RefundsEnabled();
    }

    function refund(address payable investor) public onlyOwner {
        require(state == State.Refunding);
        uint256 depositedValue = deposited[investor];
        deposited[investor] = 0;
        investor.transfer(depositedValue);
        emit Refunded(investor, depositedValue);
    }
}

// LandSale Contract
contract LandSale is Ownable {
    using SafeMath for uint256;

    uint256 public goal;
    uint256 public openingTime;
    uint256 public closingTime;
    bool public isFinalized = false;

    uint256 public villagePrice;
    uint256 public townPrice;
    uint256 public cityPrice;

    uint256 public villagesSold;
    uint256 public townsSold;
    uint256 public citiesSold;

    bool public isPaused = false;

    RefundVault public vault;

    event LandPurchased(address indexed purchaser, uint256 amount);
    event Finalized();
    event Paused();
    event Resumed();

    constructor(
        uint256 _goal,
        uint256 _openingTime,
        uint256 _closingTime,
        address payable wallet
    ) {
        require(_openingTime >= block.timestamp);
        require(_closingTime >= _openingTime);
        require(_goal > 0);

        vault = new RefundVault(wallet);
        goal = _goal;
        openingTime = _openingTime;
        closingTime = _closingTime;

        // Initialize prices
        villagePrice = 1 ether;
        townPrice = 5 ether;
        cityPrice = 10 ether;
    }

    modifier onlyWhileOpen {
        require(block.timestamp >= openingTime && block.timestamp <= closingTime);
        _;
    }

    function purchaseVillage() public payable onlyWhileOpen {
        require(msg.value == villagePrice, "Ether sent is not correct");
        villagesSold = villagesSold.add(1);
        vault.deposit(msg.sender);
        emit LandPurchased(msg.sender, villagePrice);
    }

    function purchaseTown() public payable onlyWhileOpen {
        require(msg.value == townPrice, "Ether sent is not correct");
        townsSold = townsSold.add(1);
        vault.deposit(msg.sender);
        emit LandPurchased(msg.sender, townPrice);
    }

    function purchaseCity() public payable onlyWhileOpen {
        require(msg.value == cityPrice, "Ether sent is not correct");
        citiesSold = citiesSold.add(1);
        vault.deposit(msg.sender);
        emit LandPurchased(msg.sender, cityPrice);
    }

    function finalize() public onlyOwner {
        require(!isFinalized);
        require(hasClosed());

        if (goalReached()) {
            vault.close();
        } else {
            vault.enableRefunds();
        }

        isFinalized = true;

        emit Finalized();
    }

    function claimRefund() public {
        require(isFinalized);
        require(!goalReached());

        vault.refund(payable(msg.sender));
    }

    function goalReached() public view returns (bool) {
        return address(this).balance >= goal;
    }

    function hasClosed() public view returns (bool) {
        return block.timestamp > closingTime;
    }

    function pause() public onlyOwner {
        isPaused = true;
        emit Paused();
    }

    function resume() public onlyOwner {
        isPaused = false;
        emit Resumed();
    }
}
