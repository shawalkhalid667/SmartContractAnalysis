
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

enum MarketStatus {Active, Suspended, Closed}

struct TokenInfo {
    IERC20 token;
    uint256 decimals;
    bool active;
}

struct TraderInfo {
    address withdrawalAddress;
    uint256 feeRebatePercent;
}

struct TokenAccount {
    uint256 balance;
    uint256 pendingWithdrawAmount;
}

struct Order {
    address trader;
    IERC20 pair;
    bool action; // true: buy, false: sell
    uint256 price;
    uint256 amount;
}

struct Deposit {
    address trader;
    IERC20 token;
    uint256 amount;
}


contract Dex2 is Ownable {
    using SafeMath for uint256;
    

    address public admin;
    MarketStatus public marketStatus;
    uint256 public makerFeeRateE4;
    uint256 public takerFeeRateE4;
    uint256 public withdrawFeeRateE4;

    mapping(address => TraderInfo) public traders;
    mapping(bytes32 => TokenInfo) public tokens;
    mapping(address => mapping(address => TokenAccount)) public accounts;
    mapping(uint256 => Order) public orders;
    mapping(uint256 => Deposit) public deposits;

    event DepositEvent(uint256 indexed depositId, address indexed trader, address indexed token, uint256 amount);
    event WithdrawEvent(address indexed trader, address indexed token, uint256 amount);
    event MatchOrdersEvent(uint256 indexed buyOrderId, uint256 indexed sellOrderId, uint256 amount);
    event HardCancelOrderEvent(uint256 indexed orderId);
    event SetFeeRatesEvent(uint256 makerFeeRateE4, uint256 takerFeeRateE4, uint256 withdrawFeeRateE4);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can call this function.");
        _;
    }

    modifier checkMarketStatus(MarketStatus _status) {
        require(marketStatus == _status, "Invalid market status.");
        _;
    }

    constructor(address _admin) {
        admin = _admin;
        marketStatus = MarketStatus.Active;
    }

    function setTokenInfo(bytes32 _code, IERC20 _token, uint256 _decimals, bool _active) external onlyAdmin {
        tokens[_code] = TokenInfo(_token, _decimals, _active);
    }

    function setTraderInfo(address _trader, address _withdrawalAddress, uint256 _feeRebatePercent) external onlyAdmin {
        traders[_trader] = TraderInfo(_withdrawalAddress, _feeRebatePercent);
    }

    function depositEther() external payable checkMarketStatus(MarketStatus.Active) {
        // Implementation here
    }

    function depositERC20(IERC20 _token, uint256 _amount) external checkMarketStatus(MarketStatus.Active) {
        // Implementation here
    }

    function withdrawEther(uint256 _amount) external {
        // Implementation here
    }

    function withdrawERC20(IERC20 _token, uint256 _amount) external {
        // Implementation here
    }

    function placeOrder(IERC20 _pair, bool _action, uint256 _price, uint256 _amount) external checkMarketStatus(MarketStatus.Active) {
        // Implementation here
    }

    function cancelOrder(uint256 _orderId) external {
        // Implementation here
    }

    function matchOrders(uint256 _buyOrderId, uint256 _sellOrderId) external onlyAdmin {
        // Implementation here
    }

    function setFeeRates(uint256 _makerFeeRateE4, uint256 _takerFeeRateE4, uint256 _withdrawFeeRateE4) external onlyAdmin {
        makerFeeRateE4 = _makerFeeRateE4;
        takerFeeRateE4 = _takerFeeRateE4;
        withdrawFeeRateE4 = _withdrawFeeRateE4;
        emit SetFeeRatesEvent(makerFeeRateE4, takerFeeRateE4, withdrawFeeRateE4);
    }

    function setMarketStatus(MarketStatus _status) external onlyAdmin {
        marketStatus = _status;
    }
}
