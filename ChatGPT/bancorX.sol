pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract BancorX {
    using SafeERC20 for IERC20;

    address public upgrader;
    address public owner;

    mapping(address => uint256) public lockedBalances;
    mapping(address => uint256) public releaseLimits;
    mapping(address => uint256) public reportsCount;

    uint256 public requiredReports;
    bool public xTransfersEnabled;
    bool public reportingEnabled;

    event TokenLocked(address indexed user, uint256 amount);
    event TokenReleased(address indexed user, uint256 amount);
    event XTransferInitiated(address indexed user, uint256 amount, address targetBlockchain, bytes32 transactionHash);
    event ReportSubmitted(address indexed reporter, address indexed user, address targetBlockchain, bytes32 transactionHash);
    event TokenTransferCompleted(address indexed user, uint256 amount, address targetAccount);

    modifier onlyOwner() {
        require(msg.sender == owner, "BancorX: Only owner can call this function");
        _;
    }

    modifier onlyUpgrader() {
        require(msg.sender == upgrader, "BancorX: Only upgrader contract can call this function");
        _;
    }

    modifier xTransfersAllowed() {
        require(xTransfersEnabled, "BancorX: Cross-chain transfers are not enabled");
        _;
    }

    modifier reportingAllowed() {
        require(reportingEnabled, "BancorX: Reporting is not enabled");
        _;
    }

    constructor() {
        owner = msg.sender;
        upgrader = address(0); // Set to a specific upgrader address later
        requiredReports = 3; // Example value, can be adjusted
        xTransfersEnabled = true; // Example, can be adjusted
        reportingEnabled = true; // Example, can be adjusted
    }

    function lockTokens(address token, uint256 amount) external {
        IERC20(token).safeTransferFrom(msg.sender, address(this), amount);
        lockedBalances[msg.sender] += amount;
        emit TokenLocked(msg.sender, amount);
    }

    function releaseTokens(address token, uint256 amount) external {
        require(lockedBalances[msg.sender] >= amount, "BancorX: Insufficient locked balance");
        require(amount <= releaseLimits[msg.sender], "BancorX: Amount exceeds release limit");
        lockedBalances[msg.sender] -= amount;
        IERC20(token).safeTransfer(msg.sender, amount);
        emit TokenReleased(msg.sender, amount);
    }

    function initiateXTransfer(address token, uint256 amount, address targetBlockchain, bytes32 transactionHash) external xTransfersAllowed {
        require(lockedBalances[msg.sender] >= amount, "BancorX: Insufficient locked balance");
        lockedBalances[msg.sender] -= amount;
        emit XTransferInitiated(msg.sender, amount, targetBlockchain, transactionHash);
    }

    function submitReport(address user, address targetBlockchain, bytes32 transactionHash) external reportingAllowed {
        reportsCount[user]++;
        emit ReportSubmitted(msg.sender, user, targetBlockchain, transactionHash);
        if (reportsCount[user] >= requiredReports) {
            emit TokenTransferCompleted(user, lockedBalances[user], msg.sender);
            delete lockedBalances[user];
            delete reportsCount[user];
        }
    }

    function configureSettings(uint256 _requiredReports, bool _xTransfersEnabled, bool _reportingEnabled) external onlyOwner {
        requiredReports = _requiredReports;
        xTransfersEnabled = _xTransfersEnabled;
        reportingEnabled = _reportingEnabled;
    }

    function setReleaseLimit(address user, uint256 limit) external onlyOwner {
        releaseLimits[user] = limit;
    }

    function setUpgrader(address _upgrader) external onlyOwner {
        upgrader = _upgrader;
    }

    function upgrade(address newVersion) external onlyUpgrader {
        selfdestruct(payable(newVersion));
    }
}
