pragma solidity ^0.8.0;

contract MultiSigWallet {
  // Events for transparency
  event Deposit(address indexed sender, uint value, uint newBalance);
  event TransactionSubmitted(uint indexed transactionId, address to, uint value, bytes data);
  event TransactionConfirmed(uint indexed transactionId, address owner);
  event TransactionExecuted(uint indexed transactionId, bool success);
  event ConfirmationRevoked(uint indexed transactionId, address owner);

  // Wallet owner information
  address[] public owners;
  mapping(address => bool) public isOwner;
  uint public requiredConfirmations;

  // Transaction details
  struct Transaction {
    address payable to;
    uint value;
    bytes data;
    bool executed;
    mapping(address => bool) confirmed;
  }
  Transaction[] public transactions;

  // Modifier to restrict functions to owners
  modifier onlyOwner() {
    require(isOwner[msg.sender], "Only owners can perform this action");
    _;
  }

  // Contract constructor - takes owners and required confirmations as arguments
  constructor(address[] memory _owners, uint _requiredConfirmations) public {
    require(_owners.length > 0 && _owners.length <= 250, "Invalid number of owners (1-250)");
    require(_requiredConfirmations > 0 && _requiredConfirmations <= _owners.length, "Invalid number of confirmations");

    for (uint i = 0; i < _owners.length; i++) {
      require(_owners[i] != address(0), "Owner address cannot be zero");
      require(!isOwner[_owners[i]], "Duplicate owner address");
      owners.push(_owners[i]);
      isOwner[_owners[i]] = true;
    }
    requiredConfirmations = _requiredConfirmations;
  }

  // Deposit function - accepts funds from any address
  function deposit() public payable {
    emit Deposit(msg.sender, msg.value, address(this).balance);
  }

  // Submit transaction function - only owners can submit
  function submitTransaction(address payable _to, uint _value, bytes memory _data) public onlyOwner {
    transactions.push(Transaction({to: _to, value: _value, data: _data, executed: false}));
    emit TransactionSubmitted(transactions.length - 1, _to, _value, _data);
  }

  // Confirm transaction function - only owners can confirm existing transactions
  function confirmTransaction(uint _transactionId) public onlyOwner {
    Transaction storage transaction = transactions[_transactionId];
    require(!transaction.executed, "Transaction already executed");
    require(!transaction.confirmed[msg.sender], "Already confirmed");
    transaction.confirmed[msg.sender] = true;
    emit TransactionConfirmed(_transactionId, msg.sender);
  }

  // Execute transaction function - anyone can trigger execution after enough confirmations
  function executeTransaction(uint _transactionId) public {
    Transaction storage transaction = transactions[_transactionId];
    require(!transaction.executed, "Transaction already executed");
    if (isConfirmed(transaction)) {
      transaction.executed = true;
      (bool success, ) = transaction.to.call.value(transaction.value)(transaction.data);
      if (success) {
        emit TransactionExecuted(_transactionId, true);
      } else {
        // Handle execution failure (e.g., revert transaction)
        emit TransactionExecuted(_transactionId, false);
      }
    }
  }

  // Revoke confirmation function - only owners can revoke for pending transactions
  function revokeConfirmation(uint _transactionId) public onlyOwner {
    Transaction storage transaction = transactions[_transactionId];
    require(!transaction.executed, "Transaction already executed");
    require(transaction.confirmed[msg.sender], "Confirmation not found");
    transaction.confirmed[msg.sender] = false;
    emit ConfirmationRevoked(_transactionId, msg.sender);
  }

  // Check if a transaction has enough confirmations
  function isConfirmed(Transaction storage transaction) private view returns (bool) {
    uint confirmedCount = 0;
    for (uint i = 0; i < owners.length; i++) {
      if (transaction.confirmed[owners[i]]) {
        confirmedCount++;
      }
    }
    return confirmedCount >= requiredConfirmations;
  }

  // Getters for owner list, transaction count, and transaction details
  function getOwners() public view returns (address[] memory) {
