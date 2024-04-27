// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Ownable {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Ownable: caller is not the owner");
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        owner = newOwner;
    }
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }
}

contract RefundVault is Ownable {
    mapping(address => uint256) public deposited;
    bool public refundsEnabled;

    function deposit(address investor) public payable {
        deposited[investor] += msg.value;
    }

    function refund(address payable investor) public onlyOwner {
        uint256 depositedValue = deposited[investor];
        require(depositedValue > 0, "No deposited funds");
        deposited[investor] = 0;
        investor.transfer(depositedValue);
    }

    function balance() public view returns (uint256) {
        return address(this).balance;
    }

    function enableRefunds() external onlyOwner {
        refundsEnabled = true;
    }
}

contract LandSale is Ownable {
    using SafeMath for uint256;

    // Events
    event LandPurchased(address indexed buyer, uint256 amount, string landType);
    event CreditCardPurchaseRecorded(address indexed buyer, uint256 amount, string landType);
    event CrowdsaleFinalized(bool goalReached);

    // Land types and prices
    uint256 public constant VILLAGE_PRICE = 1 ether;
    uint256 public constant TOWN_PRICE = 3 ether;
    uint256 public constant CITY_PRICE = 10 ether;

    // Crowdsale parameters
    uint256 public constant OPENING_TIME = 1651382400; // Example: April 1, 2022
    uint256 public constant CLOSING_TIME = 1654060800; // Example: June 1, 2022
    uint256 public constant GOAL_AMOUNT = 100 ether;

    // Refund vault
    RefundVault public vault;

    // Land counts
    mapping(string => uint256) public landCounts;

    // Crowdsale state
    bool public isPaused = false;
    bool public hasClosed = false;

    // Modifier to check if crowdsale is open
    modifier onlyWhileOpen() {
        require(block.timestamp >= OPENING_TIME && block.timestamp <= CLOSING_TIME, "Crowdsale is not open");
        _;
    }

    // Constructor
    constructor() {
        vault = new RefundVault();
    }

    // Purchase functions
    function purchaseVillage(uint256 amount) external payable onlyWhileOpen {
        require(!isPaused, "Land purchases are paused");
        require(msg.value >= VILLAGE_PRICE.mul(amount), "Insufficient payment");

        // Update land counts
        landCounts["village"] += amount;

        // Emit event
        emit LandPurchased(msg.sender, amount, "village");
    }

    function purchaseTown(uint256 amount) external payable onlyWhileOpen {
        require(!isPaused, "Land purchases are paused");
        require(msg.value >= TOWN_PRICE.mul(amount), "Insufficient payment");

        // Update land counts
        landCounts["town"] += amount;

        // Emit event
        emit LandPurchased(msg.sender, amount, "town");
    }

    function purchaseCity(uint256 amount) external payable onlyWhileOpen {
        require(!isPaused, "Land purchases are paused");
        require(msg.value >= CITY_PRICE.mul(amount), "Insufficient payment");

        // Update land counts
        landCounts["city"] += amount;

        // Emit event
        emit LandPurchased(msg.sender, amount, "city");
    }

    function purchaseLandWithCC(address buyer, uint256 amount, string memory landType) external onlyOwner {
        require(bytes(landType).length > 0, "Invalid land type");
        require(amount > 0, "Amount must be greater than zero");

        // Record credit card purchase
        emit CreditCardPurchaseRecorded(buyer, amount, landType);
    }

    // Pricing functions
    function villagePrice() public view returns (uint256) {
        return VILLAGE_PRICE;
    }

    function townPrice() public view returns (uint256) {
        return TOWN_PRICE;
    }

    function cityPrice() public view returns (uint256) {
        return CITY_PRICE;
    }

    // Admin functions
    function pause() external onlyOwner {
        isPaused = true;
    }

    function resume() external onlyOwner {
        isPaused = false;
    }

    // Refund and finalization functions
    function claimRefund() external {
        require(hasClosed && !goalReached(), "Refunds not available");
        require(vault.refundsEnabled(), "Refunds not enabled");
        vault.refund(payable(msg.sender));
    }

    function goalReached() public view returns (bool) {
        return vault.balance() >= GOAL_AMOUNT;
    }

    function finalize() external onlyOwner {
        require(!hasClosed, "Crowdsale already finalized");
        hasClosed = true;

        if (goalReached()) {
            // Transfer funds to wallet
            vault.close();
            emit CrowdsaleFinalized(true);
        } else {
            // Enable refunds
            vault.enableRefunds();
            emit CrowdsaleFinalized(false);
        }
    }
}
