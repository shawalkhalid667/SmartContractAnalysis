
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract BancorX is Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;
    using Counters for Counters.Counter;

    // Struct to hold transaction details
    struct Transaction {
        address from;
        uint256 amount;
        bytes32 targetBlockchain;
        address targetAddress;
        uint256 numOfReports;
    }

    // Events
    event TokenLocked(address indexed from, uint256 amount, bytes32 targetBlockchain, address targetAddress);
    event TokenReleased(address indexed to, uint256 amount);
    event TransactionReported(bytes32 indexed transactionId);
    event TransferCompleted(bytes32 indexed transactionId);

    // Variables
    IERC20 public token;
    uint256 public lockLimit;
    uint256 public releaseLimit;
    uint256 public minimumReports;
    bool public xTransfersEnabled;
    bool public reportingEnabled;

    // Mappings
    mapping(bytes32 => Transaction) public transactions;
    mapping(address => bool) public reporters;
    Counters.Counter private _transactionIds;

    // Modifiers
    modifier reporterOnly() {
        require(reporters[msg.sender], "BancorX: You do not have reporting permission");
        _;
    }

    // Constructor
    constructor(IERC20 _token) {
        token = _token;
        lockLimit = 1000 * 10**18;
        releaseLimit = 1000 * 10**18;
        minimumReports = 3;
        xTransfersEnabled = true;
        reportingEnabled = true;
    }

    // Functions
    function lockTokens(uint256 _amount, bytes32 _targetBlockchain, address _targetAddress) external {
        require(xTransfersEnabled, "BancorX: xTransfers are disabled");
        require(_amount <= lockLimit, "BancorX: Amount exceeds lock limit");

        token.safeTransferFrom(msg.sender, address(this), _amount);

        bytes32 transactionId = keccak256(abi.encodePacked(_transactionIds.current()));
        _transactionIds.increment();

        transactions[transactionId] = Transaction(msg.sender, _amount, _targetBlockchain, _targetAddress, 0);

        emit TokenLocked(msg.sender, _amount, _targetBlockchain, _targetAddress);
    }

    function reportTransaction(bytes32 _transactionId) external reporterOnly {
        require(reportingEnabled, "BancorX: Reporting is disabled");
        Transaction storage transaction = transactions[_transactionId];
        transaction.numOfReports++;

        emit TransactionReported(_transactionId);

        if (transaction.numOfReports >= minimumReports) {
            require(transaction.amount <= releaseLimit, "BancorX: Amount exceeds release limit");

            token.safeTransfer(transaction.from, transaction.amount);

            emit TokenReleased(transaction.from, transaction.amount);
            emit TransferCompleted(_transactionId);

            delete transactions[_transactionId];
        }
    }

    function setLockLimit(uint256 _lockLimit) external onlyOwner {
        lockLimit = _lockLimit;
    }

    function setReleaseLimit(uint256 _releaseLimit) external onlyOwner {
        releaseLimit = _releaseLimit;
    }

    function setMinimumReports(uint256 _minimumReports) external onlyOwner {
        minimumReports = _minimumReports;
    }

    function enableXTransfers() external onlyOwner {
        xTransfersEnabled = true;
    }

    function disableXTransfers() external onlyOwner {
        xTransfersEnabled = false;
    }

    function enableReporting() external onlyOwner {
        reportingEnabled = true;
    }

    function disableReporting() external onlyOwner {
        reportingEnabled = false;
    }

    function addReporter(address _reporter) external onlyOwner {
        reporters[_reporter] = true;
    }

    function removeReporter(address _reporter) external onlyOwner {
        reporters[_reporter] = false;
    }
}
