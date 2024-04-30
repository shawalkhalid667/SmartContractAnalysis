
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract TimeLock {
    using SafeMath for uint;

    // Constants for the minimum and maximum delay
    uint public constant MINIMUM_DELAY = 2 days;
    uint public constant MAXIMUM_DELAY = 30 days;

    // Grace period for the transaction execution
    uint public constant GRACE_PERIOD = 14 days;

    // Variables for managing admin roles and pending admins
    address public admin;
    address public pendingAdmin;

    // Variable for managing delay
    uint public delay;

    // Struct to manage time-locked transactions
    struct Transaction {
        bool executed;
        address target;
        uint value;
        string signature;
        bytes data;
        uint eta;
    }

    // Array of transactions
    Transaction[] public transactions;

    // Events
    event NewAdmin(address indexed newAdmin);
    event NewPendingAdmin(address indexed newPendingAdmin);
    event NewDelay(uint indexed newDelay);
    event CancelTransaction(uint indexed txIndex);
    event ExecuteTransaction(uint indexed txIndex);
    event QueueTransaction(uint indexed txIndex);

    // Modifiers
    modifier onlyAdmin() {
        require(msg.sender == admin, "TimeLock::onlyAdmin: caller is not the admin");
        _;
    }

    constructor(address _admin, uint _delay) {
        require(_delay >= MINIMUM_DELAY, "TimeLock::setDelay: Delay must exceed minimum delay.");
        require(_delay <= MAXIMUM_DELAY, "TimeLock::setDelay: Delay must not exceed maximum delay.");

        admin = _admin;
        delay = _delay;
    }

    function setDelay(uint _delay) public onlyAdmin {
        require(_delay >= MINIMUM_DELAY, "TimeLock::setDelay: Delay must exceed minimum delay.");
        require(_delay <= MAXIMUM_DELAY, "TimeLock::setDelay: Delay must not exceed maximum delay.");
        delay = _delay;

        emit NewDelay(delay);
    }

    function acceptAdmin() public {
        require(msg.sender == pendingAdmin, "TimeLock::acceptAdmin: Call must come from pendingAdmin.");
        admin = msg.sender;
        pendingAdmin = address(0);

        emit NewAdmin(admin);
    }

    function setPendingAdmin(address _pendingAdmin) public onlyAdmin {
        pendingAdmin = _pendingAdmin;

        emit NewPendingAdmin(pendingAdmin);
    }

    function queueTransaction(address target, uint value, string memory signature, bytes memory data, uint eta) public onlyAdmin {
        require(eta >= getBlockTimestamp().add(delay), "TimeLock::queueTransaction: Estimated execution time must satisfy delay.");

        transactions.push(Transaction({
            executed: false,
            target: target,
            value: value,
            signature: signature,
            data: data,
            eta: eta
        }));

        emit QueueTransaction(transactions.length - 1);
    }

    function cancelTransaction(uint txIndex) public onlyAdmin {
        Transaction storage txn = transactions[txIndex];
        txn.executed = true;

        emit CancelTransaction(txIndex);
    }

    function executeTransaction(uint txIndex) public payable onlyAdmin {
        require(transactions.length > txIndex, "TimeLock::executeTransaction: Transaction index out of range.");
        Transaction storage txn = transactions[txIndex];
        require(getBlockTimestamp() >= txn.eta, "TimeLock::executeTransaction: Transaction hasn't surpassed lock time.");
        require(getBlockTimestamp() <= txn.eta.add(GRACE_PERIOD), "TimeLock::executeTransaction: Transaction is stale.");
        require(txn.executed == false, "TimeLock::executeTransaction: Transaction has already been executed.");

        txn.executed = true;

        (bool success,) = txn.target.call{value: txn.value}(abi.encodeWithSignature(txn.signature, txn.data));
        require(success, "TimeLock::executeTransaction: Transaction execution reverted.");

        emit ExecuteTransaction(txIndex);
    }

    function getBlockTimestamp() internal view returns (uint) {
        // solium-disable-next-line security/no-block-members
        return block.timestamp;
    }
}
