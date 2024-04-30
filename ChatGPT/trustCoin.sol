// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Import the Ownable contract from OpenZeppelin
import "@openzeppelin/contracts/access/Ownable.sol";

// Define the Trustcoin contract inheriting from Ownable
contract Trustcoin is Ownable {
    // Token details
    string public constant name = "Trustcoin";
    string public constant symbol = "TRST";
    uint8 public constant decimals = 6;
    string public constant version = "TRST1.0";
    uint256 public constant totalSupply = 100000000 * (10 ** uint256(decimals));

    // Track balances
    mapping(address => uint256) private _balances;

    // Track allowances
    mapping(address => mapping(address => uint256)) private _allowances;

    // Events
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event MigrationInfoSet(address indexed setter, string info);

    // Constructor
    constructor() Ownable(msg.sender) {
        _balances[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);
    }

    // External functions

    // Transfer tokens
    function transfer(address to, uint256 value) external returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }

    // Approve spending
    function approve(address spender, uint256 value) external returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    // Transfer tokens from
    function transferFrom(address from, address to, uint256 value) external returns (bool) {
        _transfer(from, to, value);
        _approve(from, msg.sender, _allowances[from][msg.sender] - value);
        return true;
    }

    // Check balance
    function balanceOf(address account) external view returns (uint256) {
        return _balances[account];
    }

    // Check allowance
    function allowance(address owner, address spender) external view returns (uint256) {
        return _allowances[owner][spender];
    }

    // Internal functions

    // Transfer tokens internally
    function _transfer(address from, address to, uint256 value) internal {
        require(from != address(0), "Transfer from the zero address");
        require(to != address(0), "Transfer to the zero address");
        require(_balances[from] >= value, "Insufficient balance");
        
        _balances[from] -= value;
        _balances[to] += value;
        emit Transfer(from, to, value);
    }

    // Approve spending internally
    function _approve(address owner, address spender, uint256 value) internal {
        require(owner != address(0), "Approve from the zero address");
        require(spender != address(0), "Approve to the zero address");

        _allowances[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    // Set migration information
    function setMigrationInfo(string calldata info) external onlyFromMigrationInfoSetter {
        emit MigrationInfoSet(msg.sender, info);
    }

    // Modifiers

    // Modifier to restrict functions to be called only by the migration info setter
    modifier onlyFromMigrationInfoSetter() {
        require(msg.sender == migrationInfoSetter, "Caller is not the migration info setter");
        _;
    }

    // Storage for migration info setter address
    address public migrationInfoSetter;

    // Set migration info setter address
    function setMigrationInfoSetter(address _migrationInfoSetter) external onlyOwner {
        require(_migrationInfoSetter != address(0), "Migration info setter cannot be the zero address");
        migrationInfoSetter = _migrationInfoSetter;
    }
}
