
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

// The TokenFRT contract is a standard token contract with overflow protection.
// It also has additional features like token locking and unlocking.
contract TokenFRT is ERC20 {
    using SafeMath for uint256;

    address public owner;
    address public minter;

    // An UnlockedToken structure is used to manage tokens that are unlocked and can be withdrawn.
    struct UnlockedToken {
        uint256 amount;
        uint256 unlockDate;
    }

    // Mappings are used to manage token balances.
    mapping (address => UnlockedToken) private unlockedTokens;
    mapping (address => uint256) private lockedTokenBalances;

    // The contract initialization process includes setting the owner and defining token parameters like symbol, name, and decimals.
    constructor(string memory name, string memory symbol, uint8 decimals, address _owner, address _minter) ERC20(name, symbol) {
        _setupDecimals(decimals);
        owner = _owner;
        minter = _minter;
    }

    // Functions like updateMinter and updateOwner are used for setting the minter and owner addresses.
    function updateMinter(address _minter) public {
        require(msg.sender == owner, "Only owner can update the minter");
        minter = _minter;
    }

    function updateOwner(address _owner) public {
        require(msg.sender == owner, "Only owner can update the owner");
        owner = _owner;
    }

    // The mintTokens function is used for minting new tokens.
    function mintTokens(address _to, uint256 _amount) public {
        require(msg.sender == minter, "Only minter can mint tokens");
        _mint(_to, _amount);
    }

    // The lockTokens function is used for locking tokens.
    function lockTokens(uint256 _amount) public {
        _burn(msg.sender, _amount);
        lockedTokenBalances[msg.sender] = lockedTokenBalances[msg.sender].add(_amount);
    }

    // The unlockTokens function is used for unlocking tokens.
    function unlockTokens(uint256 _amount) public {
        require(lockedTokenBalances[msg.sender] >= _amount, "Not enough locked tokens");
        lockedTokenBalances[msg.sender] = lockedTokenBalances[msg.sender].sub(_amount);
        unlockedTokens[msg.sender] = UnlockedToken(_amount, block.timestamp + 1 days);
    }

    // The withdrawUnlockedTokens function is used for withdrawing unlocked tokens after a specific time period.
    function withdrawUnlockedTokens() public {
        require(block.timestamp > unlockedTokens[msg.sender].unlockDate, "Tokens are not yet unlocked");
        uint256 amount = unlockedTokens[msg.sender].amount;
        unlockedTokens[msg.sender].amount = 0;
        _mint(msg.sender, amount);
    }

    // Basic mathematical functions are defined for safe arithmetic calculations.
    function min(uint256 a, uint256 b) public pure returns (uint256) {
        return a < b ? a : b;
    }

    function safeToAdd(uint256 a, uint256 b) public pure returns (bool) {
        return a + b >= a;
    }

    function safeToSub(uint256 a, uint256 b) public pure returns (bool) {
        return a >= b;
    }

    function add(uint256 a, uint256 b) public pure returns (uint256) {
        require(safeToAdd(a, b), "Addition overflow");
        return a + b;
    }

    function sub(uint256 a, uint256 b) public pure returns (uint256) {
        require(safeToSub(a, b), "Subtraction underflow");
        return a - b;
    }

    // Security checks are used to ensure safe arithmetic operations.
    // These checks are important in preventing vulnerabilities in token transactions.
}
