
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "@openzeppelin/contracts/access/AccessControl.sol";

contract MyContract is AccessControl {
    // Define a new role identifier for the admin role
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    constructor(address admin) {
        // Grant the admin role to a specified address
        _setupRole(ADMIN_ROLE, admin);
    }

contract CrowdsaleConfig is ERC20, Ownable {

    // Token decimals and minimum token unit
    uint8 public constant TOKEN_DECIMALS = 18;
    uint256 public constant MIN_TOKEN_UNIT = 1 * (10 ** uint256(TOKEN_DECIMALS));

    // Token supply cap and sale cap
    uint256 public constant TOTAL_SUPPLY_CAP = 1000000000 * (10 ** uint256(TOKEN_DECIMALS)); // 1 billion tokens
    uint256 public constant SALE_CAP = 500000000 * (10 ** uint256(TOKEN_DECIMALS)); // 500 million tokens for sale

    // Purchaser caps and pricing
    uint256 public constant MIN_PURCHASE_CAP = 100 * (10 ** uint256(TOKEN_DECIMALS)); // Minimum 100 tokens per purchase
    uint256 public constant MAX_PURCHASE_CAP = 10000 * (10 ** uint256(TOKEN_DECIMALS)); // Maximum 10,000 tokens per purchase
    uint256 public constant TOKEN_PRICE_IN_USD = 1; // 1 USD per token

    // Token allocations
    uint256 public constant FOUNDATION_POOL_ALLOCATION = 200000000 * (10 ** uint256(TOKEN_DECIMALS)); // 200 million tokens
    uint256 public constant COMMUNITY_POOL_ALLOCATION = 200000000 * (10 ** uint256(TOKEN_DECIMALS)); // 200 million tokens
    uint256 public constant FOUNDERS_ALLOCATION = 100000000 * (10 ** uint256(TOKEN_DECIMALS)); // 100 million tokens
    uint256 public constant LEGAL_EXPENSES_ALLOCATION = 10000000 * (10 ** uint256(TOKEN_DECIMALS)); // 10 million tokens

    // Vesting period in seconds
    uint256 public constant VESTING_PERIOD = 31536000; // 1 year

    // Wallet addresses
    address public foundationPool;
    address public communityPool;
    address public foundersPool;
    address public legalExpenses;

    // Events
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event Registration(address indexed user, uint256 amount);
    event Finalization(address indexed user, uint256 amount);
    event Withdrawal(address indexed user, uint256 amount);
    event Cancellation(address indexed user, uint256 amount);
    event LimitUpdate(address indexed user, uint256 amount);

    constructor(address _foundationPool, address _communityPool, address _foundersPool, address _legalExpenses) ERC20("TokenName", "TKN") {
        foundationPool = _foundationPool;
        communityPool = _communityPool;
        foundersPool = _foundersPool;
        legalExpenses = _legalExpenses;

        _mint(foundationPool, FOUNDATION_POOL_ALLOCATION);
        _mint(communityPool, COMMUNITY_POOL_ALLOCATION);
        _mint(foundersPool, FOUNDERS_ALLOCATION);
        _mint(legalExpenses, LEGAL_EXPENSES_ALLOCATION);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "New owner is the zero address");
        emit OwnershipTransferred(_msgSender(), newOwner);
        transferOwnership(newOwner);
    }

    function grantAdmin(address newAdmin) public virtual onlyOwner {
        require(newAdmin != address(0), "New admin is the zero address");
        _setupRole(DEFAULT_ADMIN_ROLE, newAdmin);
    }

    function reviewAdminPermission(address admin) public view returns (bool) {
        return hasRole(DEFAULT_ADMIN_ROLE, admin);
    }
}
