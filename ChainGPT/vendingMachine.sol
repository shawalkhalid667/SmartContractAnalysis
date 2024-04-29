
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract VendingMachine is AccessControl, ERC20 {
    using SafeMath for uint256;
    
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant WHITELISTED_ROLE = keccak256("WHITELISTED_ROLE");

    struct Product {
        uint256 id;
        uint256 cost;
        string name;
        bool available;
    }

    struct Vendor {
        string name;
        bool permission;
    }

    mapping(address => uint256) private _allowances;
    mapping(uint256 => Product) private _products;
    mapping(address => Vendor) private _vendors;

    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);
    event UpdateVendor(address indexed vendor, string name, bool permission);
    event AddProduct(uint256 id, string name, uint256 cost, bool available);

    constructor() ERC20("VendingMachineToken", "VMT") {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(ADMIN_ROLE, msg.sender);
    }

    function deposit(uint256 amount) external {
        _mint(msg.sender, amount);
        emit Deposit(msg.sender, amount);
    }

    function withdraw(uint256 amount) external {
        require(balanceOf(msg.sender) >= amount, "Insufficient balance");
        _burn(msg.sender, amount);
        emit Withdraw(msg.sender, amount);
    }

    function adminMint(address to, uint256 amount) external onlyRole(ADMIN_ROLE) {
        _mint(to, amount);
    }

    function sweep(address to) external onlyRole(DEFAULT_ADMIN_ROLE) {
        payable(to).transfer(address(this).balance);
    }

    function addAdmin(address admin) external onlyRole(DEFAULT_ADMIN_ROLE) {
        grantRole(ADMIN_ROLE, admin);
    }

    function removeAdmin(address admin) external onlyRole(DEFAULT_ADMIN_ROLE) {
        revokeRole(ADMIN_ROLE, admin);
    }

    function addWhitelisted(address account) external onlyRole(ADMIN_ROLE) {
        grantRole(WHITELISTED_ROLE, account);
    }

    function removeWhitelisted(address account) external onlyRole(ADMIN_ROLE) {
        revokeRole(WHITELISTED_ROLE, account);
    }

    function addVendor(address vendor, string calldata name, bool permission) external onlyRole(ADMIN_ROLE) {
        _vendors[vendor] = Vendor(name, permission);
        emit UpdateVendor(vendor, name, permission);
    }

    function addProduct(uint256 id, string calldata name, uint256 cost, bool available) external onlyRole(ADMIN_ROLE) {
        _products[id] = Product(id, cost, name, available);
        emit AddProduct(id, name, cost, available);
    }

    function _addAllowance(address account, uint256 amount) internal {
        _allowances[account] = _allowances[account].add(amount);
    }

    function _withdraw(address account, uint256 amount) internal {
        require(balanceOf(account) >= amount, "Insufficient balance");
        _burn(account, amount);
    }

    function _addWhitelisted(address account) internal onlyRole(ADMIN_ROLE) {
        grantRole(WHITELISTED_ROLE, account);
    }

    function _removeWhitelisted(address account) internal onlyRole(ADMIN_ROLE) {
        revokeRole(WHITELISTED_ROLE, account);
    }
}
