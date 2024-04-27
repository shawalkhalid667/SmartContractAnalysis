pragma solidity ^0.8.0;

contract CrowdsaleConfig {
    // Token Decimals and Minimum Token Unit
    uint8 public constant TOKEN_DECIMALS = 18;
    uint256 public constant MIN_TOKEN_UNIT = 10 ** uint256(TOKEN_DECIMALS);

    // Token Supply Cap and Sale Cap
    uint256 public constant TOTAL_SUPPLY_CAP = 1000000 * MIN_TOKEN_UNIT;
    uint256 public constant SALE_CAP = 700000 * MIN_TOKEN_UNIT;

    // Purchaser Caps and Pricing
    uint256 public constant MIN_TOKEN_CAP_PER_PURCHASER = 1000 * MIN_TOKEN_UNIT;
    uint256 public constant MAX_TOKEN_CAP_PHASE_1 = 50000 * MIN_TOKEN_UNIT;
    uint256 public constant MAX_TOKEN_CAP_PHASE_2 = 20000 * MIN_TOKEN_UNIT;
    uint256 public constant MAX_TOKEN_CAP_PHASE_3 = 10000 * MIN_TOKEN_UNIT;

    uint256 public constant TOKEN_PRICE_PHASE_1 = 100; // 1 USD in cents
    uint256 public constant TOKEN_PRICE_PHASE_2 = 120; // 1.2 USD in cents
    uint256 public constant TOKEN_PRICE_PHASE_3 = 150; // 1.5 USD in cents

    // Token Allocations and Founders' Distribution
    uint256 public constant FOUNDATION_POOL_ALLOCATION = 200000 * MIN_TOKEN_UNIT;
    uint256 public constant COMMUNITY_POOL_ALLOCATION = 100000 * MIN_TOKEN_UNIT;
    uint256 public constant FOUNDERS_ALLOCATION = 150000 * MIN_TOKEN_UNIT;
    uint256 public constant LEGAL_EXPENSES_ALLOCATION = 50000 * MIN_TOKEN_UNIT;

    uint256 public constant VESTING_DURATION_FOUNDERS = 365 days;
    uint256 public constant VESTING_DURATION_LEGAL_EXPENSES = 180 days;

    uint256 public constant VESTING_CLIFF_FOUNDERS = 180 days;

    // Contract Wallet Addresses and Allocations
    address public crowdsaleWallet;
    address public foundationPoolWallet;
    address public communityPoolWallet;
    address public foundersPoolWallet;
    address public legalExpensesWallet;

    // Event Logging and Address Verification
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    address public owner;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the contract owner can call this function");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Invalid new owner address");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    // Additional functions for managing wallet addresses and other configurations can be added here
}
