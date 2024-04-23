// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MultiSigWallet {
    // Struct to represent a transaction
    struct Transaction {
        address payable to;
        uint256 value;
        bytes data;
        bool executed;
        mapping(address => bool) confirmations;
    }

    // Events
    event Deposit(address indexed sender, uint256 value, uint256 balance);
    event Submission(uint256 indexed txIndex, address indexed to, uint256 value, bytes data);
    event Confirmation(address indexed owner, uint256 indexed txIndex);
    event Execution(uint256 indexed txIndex);
    event Revocation(address indexed owner, uint256 indexed txIndex);

    // State variables
    address[] public owners;
    uint256 public requiredConfirmations;
    mapping(uint256 => Transaction) public transactions;

    // Modifiers
    modifier onlyOwner() {
        require(isOwner(msg.sender), "Not an owner");
        _;
    }

    modifier transactionExists(uint256 _txIndex) {
        require(_txIndex < transactions.length, "Transaction does not exist");
        _;
    }

    modifier notExecuted(uint256 _txIndex) {
        require(!transactions[_txIndex].executed, "Transaction already executed");
        _;
    }

    modifier notConfirmed(uint256 _txIndex) {
        require(!transactions[_txIndex].confirmations[msg.sender], "Transaction already confirmed");
        _;
    }

    // Constructor
    constructor(address[] memory _owners, uint256 _requiredConfirmations) public {
        require(_owners.length > 0, "Owners required");
        require(_requiredConfirmations > 0 && _requiredConfirmations <= _owners.length, "Invalid number of required confirmations");
        for (uint256 i = 0; i < _owners.length; i++) {
            require(_owners[i] != address(0), "Invalid owner address");
            require(!isOwner(_owners[i]), "Duplicate owner");
            owners.push(_owners[i]);
        }
        requiredConfirmations = _requiredConfirmations;
    }

    // Fallback function to receive ether
    function() external payable {
        emit Deposit(msg.sender, msg.value, address(this).balance);
    }

    // Deposit function
    function deposit() public payable {
        emit Deposit(msg.sender, msg.value, address(this).balance);
    }

    // Submit transaction
    function submitTransaction(address payable _to, uint256 _value, bytes memory _data) public onlyOwner {
        uint256 txIndex = transactions.length;
        transactions.push(Transaction({
            to: _to,
            value: _value,
            data: _data,
            executed: false
        }));
        emit Submission(txIndex, _to, _value, _data);
    }

    // Confirm transaction
    function confirmTransaction(uint256 _txIndex) public onlyOwner transactionExists(_txIndex) notExecuted(_txIndex) notConfirmed(_txIndex) {
        transactions[_txIndex].confirmations[msg.sender] = true;
        emit Confirmation(msg.sender, _txIndex);
        if (isConfirmed(_txIndex)) {
            executeTransaction(_txIndex);
        }
    }

    // Revoke confirmation
    function revokeConfirmation(uint256 _txIndex) public onlyOwner transactionExists(_txIndex) notExecuted(_txIndex) {
        require(transactions[_txIndex].confirmations[msg.sender], "Transaction not confirmed");
        transactions[_txIndex].confirmations[msg.sender] = false;
        emit Revocation(msg.sender, _txIndex);
    }

    // Execute transaction
    function executeTransaction(uint256 _txIndex) public onlyOwner transactionExists(_txIndex) notExecuted(_txIndex) {
        require(isConfirmed(_txIndex), "Transaction not yet confirmed");
        Transaction storage transaction = transactions[_txIndex];
        transaction.executed = true;
        (bool success, ) = transaction.to.call.value(transaction.value)(transaction.data);
        if (success) {
            emit Execution(_txIndex);
        } else {
            transaction.executed = false;
            revert("Transaction execution failed");
        }
    }

    // Get owners
    function getOwners() public view returns (address[] memory) {
        return owners;
    }

    // Get transaction count
    function getTransactionCount() public view returns (uint256) {
        return transactions.length;
    }

    // Get transaction details
    function getTransaction(uint256 _txIndex) public view returns (address, uint256, bytes memory, bool) {
        Transaction storage transaction = transactions[_txIndex];
        return (transaction.to, transaction.value, transaction.data, transaction.executed);
    }

    // Check if address is an owner
    function isOwner(address _address) public view returns (bool) {
        for (uint256 i = 0; i < owners.length; i++) {
            if (owners[i] == _address) {
                return true;
            }
        }
        return false;
    }

    // Check if transaction is confirmed
    function isConfirmed(uint256 _txIndex) public view returns (bool) {
        uint256 count = 0;
        for (uint256 i = 0; i < owners.length; i++) {
            if (transactions[_txIndex].confirmations[owners[i]]) {
                count += 1;
            }
            if (count == requiredConfirmations) {
                return true;
            }
        }
        return false;
    }
}
