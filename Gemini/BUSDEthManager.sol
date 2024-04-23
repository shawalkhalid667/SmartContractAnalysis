pragma solidity ^0.8.0;

// SafeMath library for safe arithmetic operations
library SafeMath {
  function add(uint a, uint b) public pure returns (uint c) {
    c = a + b;
    require(c >= a, "SafeMath: addition overflow");
    return c;
  }
  function sub(uint a, uint b) public pure returns (uint c) {
    require(b <= a, "SafeMath: subtraction overflow");
    c = a - b;
    return c;
  }
  function mul(uint a, uint b) public pure returns (uint c) {
    c = a * b;
    require(a == 0 || c / a == b, "SafeMath: multiplication overflow");
    return c;
  }
  function div(uint a, uint b) public pure returns (uint c) {
    require(b > 0, "SafeMath: division by zero");
    c = a / b;
    return c;
  }
  function mod(uint a, uint b) public pure returns (uint c) {
    require(b > 0, "SafeMath: modulo by zero");
    c = a % b;
    return c;
  }
}

// Interface for BUSD token interaction
interface IBUSD {
  function balanceOf(address account) external view returns (uint);
  function transferFrom(address from, address to, uint value) external returns (bool);
  function transfer(address to, uint value) external returns (bool);
  function increaseSupply(uint amount) external;
  function decreaseSupply(uint amount) external;
}

// BUSDEthManager contract for cross-chain BUSD locking/unlocking
contract BUSDEthManager {
  using SafeMath for uint;

  // Events for logging lock and unlock actions
  event Locked(address indexed recipient, uint amount, bytes32 receiptId);
  event Unlocked(address indexed recipient, uint amount, bytes32 receiptId);

  // Mapping to track used transaction hashes (receipt IDs)
  mapping(bytes32 => bool) public usedEvents_;

  // Address of the BUSD token contract
  address public busdToken;

  // Address of the authorized wallet for lock/unlock operations
  address public wallet;

  // Restrict functions only to the wallet address
  modifier onlyWallet() {
    require(msg.sender == wallet, "Unauthorized: Only wallet can perform this action");
    _;
  }

  // Constructor to set initial states
  constructor(address _busdToken, address _wallet) public {
    busdToken = _busdToken;
    wallet = _wallet;
  }

  // Lock BUSD tokens sent by the caller. Requires valid recipient address and sufficient balance.
  function lockToken(address recipient, uint amount) public {
    require(recipient != address(0), "Invalid recipient address");
    require(IBUSD(busdToken).balanceOf(msg.sender) >= amount, "Insufficient BUSD balance");
    IBUSD(busdToken).transferFrom(msg.sender, address(this), amount);
    emit Locked(recipient, amount, keccak256(abi.encodePacked(msg.sender, recipient, amount)));
  }

  // Lock BUSD tokens on behalf of a user (by wallet). Requires valid recipient address.
  function lockTokenFor(address recipient, uint amount) public onlyWallet {
    require(recipient != address(0), "Invalid recipient address");
    lockToken(recipient, amount);
  }

  // Unlock BUSD tokens based on a unique receipt ID. Prevents double-spending.
  function unlockToken(bytes32 receiptId) public {
    require(!usedEvents_[receiptId], "Receipt ID already used");
    (address recipient, uint amount) = abi.decode(keccak256(receiptId), (address, uint));
    require(recipient != address(0), "Invalid recipient address in receipt ID");
    require(IBUSD(busdToken).balanceOf(address(this)) >= amount, "Insufficient locked BUSD balance");
    IBUSD(busdToken).transfer(recipient, amount);
    usedEvents_[receiptId] = true;
    emit Unlocked(recipient, amount, receiptId);
  }
}
