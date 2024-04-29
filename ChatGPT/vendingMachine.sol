// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }
}

library Roles {
    struct Role {
        mapping(address => bool) bearer;
    }

    function add(Role storage role, address account) internal {
        role.bearer[account] = true;
    }

    function remove(Role storage role, address account) internal {
        role.bearer[account] = false;
    }

    function has(Role storage role, address account) internal view returns (bool) {
        return role.bearer[account];
    }
}

contract VendingMachine {
    using SafeMath for uint256;
    using Roles for Roles.Role;

    // Roles
    address private superAdmin;
    Roles.Role private admins;
    Roles.Role private whitelisted;

    // Events
    event CurrencyDeposited(address indexed depositor, uint256 amount);
    event TokensWithdrawn(address indexed withdrawer, uint256 amount);
    event VendorAdded(uint256 indexed vendorId, string name, address indexed vendorAddress);
    event ProductAdded(uint256 indexed productId, uint256 vendorId, string name, uint256 cost, bool availability);
    event TokensMinted(address indexed receiver, uint256 amount);

    // Structs
    struct Vendor {
        string name;
        address vendorAddress;
        bool exists;
    }

    struct Product {
        uint256 id;
        string name;
        uint256 cost;
        bool available;
    }

    // Mappings
    mapping(uint256 => Vendor) public vendors;
    mapping(uint256 => Product) public products;
    mapping(address => uint256) public allowances;

    // Modifiers
    modifier onlyAdmin() {
        require(admins.has(msg.sender) || msg.sender == superAdmin, "Caller is not an admin");
        _;
    }

    modifier onlyWhitelisted() {
        require(whitelisted.has(msg.sender), "Caller is not whitelisted");
        _;
    }

    // Constructor
    constructor() {
        superAdmin = msg.sender;
        admins.add(msg.sender);
    }

    // Deposit function
    function deposit() external payable {
        uint256 amount = msg.value;
        allowances[msg.sender] = allowances[msg.sender].add(amount);
        emit CurrencyDeposited(msg.sender, amount);
    }

    // Withdraw function
    function withdraw(uint256 amount) external {
        require(allowances[msg.sender] >= amount, "Insufficient allowance");
        allowances[msg.sender] = allowances[msg.sender].sub(amount);
        payable(msg.sender).transfer(amount);
        emit TokensWithdrawn(msg.sender, amount);
    }

    // Mint tokens function
    function adminMint(address receiver, uint256 amount) external onlyAdmin {
        emit TokensMinted(receiver, amount);
    }

    // Sweep function
    function sweep(address payable receiver, uint256 amount) external {
        require(msg.sender == superAdmin, "Caller is not the super admin");
        require(address(this).balance >= amount, "Insufficient balance");
        receiver.transfer(amount);
    }

    // Role management functions
    function addAdmin(address account) external onlyAdmin {
        admins.add(account);
    }

    function removeAdmin(address account) external onlyAdmin {
        admins.remove(account);
    }

    function addWhitelisted(address account) external onlyAdmin {
        whitelisted.add(account);
    }

    function removeWhitelisted(address account) external onlyAdmin {
        whitelisted.remove(account);
    }

    // Vendor and Product management functions
    function addVendor(uint256 vendorId, string memory name, address vendorAddress) external onlyAdmin {
        require(!vendors[vendorId].exists, "Vendor ID already exists");
        vendors[vendorId] = Vendor(name, vendorAddress, true);
        emit VendorAdded(vendorId, name, vendorAddress);
    }

    function addProduct(uint256 productId, uint256 vendorId, string memory name, uint256 cost, bool availability) external onlyAdmin {
        require(vendors[vendorId].exists, "Vendor ID does not exist");
        products[productId] = Product(productId, name, cost, availability);
        emit ProductAdded(productId, vendorId, name, cost, availability);
    }
}
