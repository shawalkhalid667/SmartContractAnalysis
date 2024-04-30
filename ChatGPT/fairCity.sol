// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract Timelock {
    using SafeMath for uint256;

    // Constants
    uint256 public constant GRACE_PERIOD = 14 days;
    uint256 public constant MINIMUM_DELAY = 1 hours;
    uint256 public constant MAXIMUM_DELAY = 30 days;

    // Events
    event NewAdmin(address indexed newAdmin);
    event NewPendingAdmin(address indexed newPendingAdmin);
    event NewDelay(uint256 indexed newDelay);
    event CancelTransaction(bytes32 indexed txHash, address indexed target, uint256 value, bytes data, uint256 eta);
    event ExecuteTransaction(bytes32 indexed txHash, address indexed target, uint256 value, bytes data, uint256 eta);
    event QueueTransaction(bytes32 indexed txHash, address indexed target, uint256 value, bytes data, uint256 eta);

    // State variables
    mapping(bytes32 => bool) public queuedTransactions;
    address public admin;
    address public pendingAdmin;
    uint256 public delay;

    // Modifiers
    modifier onlyAdmin() {
        require(msg.sender == admin, "Timelock: sender must be admin");
        _;
    }

    // Constructor
    constructor(address admin_, uint256 delay_) {
        require(delay_ >= MINIMUM_DELAY, "Timelock: delay must exceed minimum delay");
        require(delay_ <= MAXIMUM_DELAY, "Timelock: delay must not exceed maximum delay");
        admin = admin_;
        delay = delay_;
    }

    // Functions
    function setDelay(uint256 delay_) external onlyAdmin {
        require(delay_ >= MINIMUM_DELAY, "Timelock: delay must exceed minimum delay");
        require(delay_ <= MAXIMUM_DELAY, "Timelock: delay must not exceed maximum delay");
        delay = delay_;
        emit NewDelay(delay);
    }

    function acceptAdmin() external {
        require(msg.sender == pendingAdmin, "Timelock: sender must be pending admin");
        admin = msg.sender;
        pendingAdmin = address(0);
        emit NewAdmin(admin);
    }

    function setPendingAdmin(address pendingAdmin_) external onlyAdmin {
        pendingAdmin = pendingAdmin_;
        emit NewPendingAdmin(pendingAdmin);
    }

    function queueTransaction(address target, uint256 value, bytes memory data, uint256 eta) external onlyAdmin returns (bytes32) {
        require(eta >= _getBlockTimestamp().add(delay), "Timelock: eta must be after delay");
        bytes32 txHash = keccak256(abi.encode(target, value, data, eta));
        queuedTransactions[txHash] = true;
        emit QueueTransaction(txHash, target, value, data, eta);
        return txHash;
    }

    function cancelTransaction(address target, uint256 value, bytes memory data, uint256 eta) external onlyAdmin {
        bytes32 txHash = keccak256(abi.encode(target, value, data, eta));
        require(queuedTransactions[txHash], "Timelock: transaction is not queued");
        delete queuedTransactions[txHash];
        emit CancelTransaction(txHash, target, value, data, eta);
    }

    function executeTransaction(address target, uint256 value, bytes memory data, uint256 eta) external onlyAdmin payable {
        bytes32 txHash = keccak256(abi.encode(target, value, data, eta));
        require(queuedTransactions[txHash], "Timelock: transaction is not queued");
        require(_getBlockTimestamp() >= eta, "Timelock: transaction is not yet ready");
        require(_getBlockTimestamp() <= eta.add(GRACE_PERIOD), "Timelock: transaction is expired");
        delete queuedTransactions[txHash];
        (bool success, ) = target.call{value: value}(data);
        require(success, "Timelock: transaction execution failed");
        emit ExecuteTransaction(txHash, target, value, data, eta);
    }

    function _getBlockTimestamp() internal view virtual returns (uint256) {
        return block.timestamp;
    }
}
