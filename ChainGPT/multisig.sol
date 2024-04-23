pragma solidity ^0.8.0;

contract MultiSigWallet { address[] public owners; mapping(address => bool) public isOwner; uint public numConfirmationsRequired;

struct Transaction {
    address to;
    uint value;
    bytes data;
    bool executed;
    mapping(address => bool) approvals;
    uint approvalsCount;
}

Transaction[] public transactions;

event Deposit(address indexed sender, uint amount, uint balance);
event SubmitTransaction(address indexed owner, uint indexed txIndex, address to, uint value, bytes data);
event ConfirmTransaction(address indexed owner, uint indexed txIndex);
event RevokeConfirmation(address indexed owner, uint indexed txIndex);
event ExecuteTransaction(address indexed owner, uint indexed txIndex);

modifier onlyOwner() {
    require(isOwner[msg.sender], "Not an owner");
    _;
}

constructor(address[] memory _owners, uint _numConfirmationsRequired) public {
    require(_owners.length > 0, "Owners required");
    require(_numConfirmationsRequired > 0 && _numConfirmationsRequired <= _owners.length, "Invalid number of confirmations");

    for (uint i = 0; i < _owners.length; i++) {
        address owner = _owners[i];
        require(owner != address(0), "Invalid owner");
        require(!isOwner[owner], "Owner not unique");

        isOwner[owner] = true;
        owners.push(owner);
    }

    numConfirmationsRequired = _numConfirmationsRequired;
}

function deposit() public payable {
    emit Deposit(msg.sender, msg.value, address(this).balance);
}

function submitTransaction(address to, uint value, bytes memory data) public onlyOwner {
    uint txIndex = transactions.length;

    transactions.push(Transaction({
        to: to,
        value: value,
        data: data,
        executed: false,
        approvalsCount: 0
    }));

    emit SubmitTransaction(msg.sender, txIndex, to, value, data);
}

function confirmTransaction(uint txIndex) public onlyOwner {
    Transaction storage transaction = transactions[txIndex];

    require(transaction.executed == false, "Transaction already executed");
    require(transaction.approvals[msg.sender] == false, "Transaction already confirmed");

    transaction.approvals[msg.sender] = true;
    transaction.approvalsCount++;

    emit ConfirmTransaction(msg.sender, txIndex);

    if (transaction.approvalsCount == numConfirmationsRequired) {
        executeTransaction(txIndex);
    }
}

function revokeConfirmation(uint txIndex) public onlyOwner {
    Transaction storage transaction = transactions[txIndex];

    require(transaction.executed == false, "Transaction already executed");
    require(transaction.approvals[msg.sender] == true, "Transaction not yet confirmed");

    transaction.approvals[msg.sender] = false;
    transaction.approvalsCount--;

    emit RevokeConfirmation(msg.sender, txIndex);
}

function executeTransaction(uint txIndex) public onlyOwner {
    Transaction storage transaction = transactions[txIndex];

    require(transaction.executed == false, "Transaction already executed");
    require(transaction.approvalsCount >= numConfirmationsRequired, "Not enough confirmations");

    transaction.executed = true;

    (bool success, ) = transaction.to.call.value(transaction.value)(transaction.data);
    require(success, "Transaction execution failed");

    emit ExecuteTransaction(msg.sender, txIndex);
}

function getOwners() public view returns (address[] memory) {
    return owners;
}

function getTransactionCount() public view returns (uint) {
    return transactions.length;
}

function getTransaction(uint txIndex) public view returns (address to, uint value, bytes memory data, bool executed, uint approvalsCount) {
    Transaction storage transaction = transactions[txIndex];
    return (transaction.to, transaction.value, transaction.data, transaction.executed, transaction.approvalsCount);
}
}
