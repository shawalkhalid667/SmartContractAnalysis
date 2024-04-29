// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Dex2 {
    address public admin;
    enum MarketStatus { Active, Suspended, Closed }
    MarketStatus public marketStatus;

    uint256 public makerFeeRateE4;
    uint256 public takerFeeRateE4;
    uint256 public withdrawFeeRateE4;

    struct TokenInfo {
        address tokenAddress;
        string symbol;
        uint256 decimals;
    }

    struct TraderInfo {
        address withdrawalAddress;
        uint256 feeRebatePercent;
    }

    struct TokenAccount {
        uint256 balance;
        uint256 pendingWithdraw;
    }

    struct Order {
        address trader;
        address tokenFrom;
        address tokenTo;
        uint256 amountFrom;
        uint256 amountTo;
        uint256 price;
        uint256 timestamp;
        bool isBuy;
        bool isFilled;
    }

    struct Deposit {
        address trader;
        address token;
        uint256 amount;
        uint256 timestamp;
        bool confirmed;
    }

    mapping(address => TokenInfo) public tokens;
    mapping(address => TraderInfo) public traders;
    mapping(address => mapping(address => TokenAccount)) public accounts;
    mapping(bytes32 => Order) public orders;
    mapping(bytes32 => Deposit) public deposits;

    event DepositEvent(address indexed trader, address indexed token, uint256 amount, uint256 timestamp);
    event WithdrawEvent(address indexed trader, address indexed token, uint256 amount, uint256 timestamp);
    event MatchOrdersEvent(bytes32 indexed order1Hash, bytes32 indexed order2Hash, uint256 matchedAmount, uint256 timestamp);
    event HardCancelOrderEvent(bytes32 indexed orderHash, uint256 timestamp);
    event SetFeeRatesEvent(uint256 makerFeeRateE4, uint256 takerFeeRateE4, uint256 withdrawFeeRateE4, uint256 timestamp);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can call this function");
        _;
    }

    modifier marketActive() {
        require(marketStatus == MarketStatus.Active, "Market is not active");
        _;
    }

    constructor() {
        admin = msg.sender;
        marketStatus = MarketStatus.Active;
        makerFeeRateE4 = 10; // 0.1%
        takerFeeRateE4 = 20; // 0.2%
        withdrawFeeRateE4 = 30; // 0.3%
    }

    function setFeeRates(uint256 _makerFeeRateE4, uint256 _takerFeeRateE4, uint256 _withdrawFeeRateE4) external onlyAdmin {
        makerFeeRateE4 = _makerFeeRateE4;
        takerFeeRateE4 = _takerFeeRateE4;
        withdrawFeeRateE4 = _withdrawFeeRateE4;
        emit SetFeeRatesEvent(_makerFeeRateE4, _takerFeeRateE4, _withdrawFeeRateE4, block.timestamp);
    }

    function depositEther() external payable marketActive {
        accounts[msg.sender][address(0)].balance += msg.value;
        emit DepositEvent(msg.sender, address(0), msg.value, block.timestamp);
    }

    function withdrawEther(uint256 amount) external marketActive {
        require(accounts[msg.sender][address(0)].balance >= amount, "Insufficient balance");
        accounts[msg.sender][address(0)].balance -= amount;
        payable(msg.sender).transfer(amount);
        emit WithdrawEvent(msg.sender, address(0), amount, block.timestamp);
    }

    function depositToken(address token, uint256 amount) external marketActive {
        require(tokens[token].tokenAddress != address(0), "Token not supported");
        require(amount > 0, "Amount must be greater than 0");
        require(ERC20(token).transferFrom(msg.sender, address(this), amount), "Token transfer failed");
        accounts[msg.sender][token].balance += amount;
        emit DepositEvent(msg.sender, token, amount, block.timestamp);
    }

    function withdrawToken(address token, uint256 amount) external marketActive {
        require(tokens[token].tokenAddress != address(0), "Token not supported");
        require(accounts[msg.sender][token].balance >= amount, "Insufficient balance");
        require(ERC20(token).transfer(msg.sender, amount), "Token transfer failed");
        accounts[msg.sender][token].balance -= amount;
        emit WithdrawEvent(msg.sender, token, amount, block.timestamp);
    }

    // Other functions for order matching, fee calculation, etc. would go here

    // Utility functions to get token details
    function getTokenInfo(address token) external view returns (address, string memory, uint256) {
        return (tokens[token].tokenAddress, tokens[token].symbol, tokens[token].decimals);
    }
}

// ERC20 interface for interacting with ERC20 tokens
interface ERC20 {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
}
