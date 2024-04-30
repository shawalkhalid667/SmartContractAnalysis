// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract LMSRMarketMaker {
    using SafeMath for uint256;

    // Address of the owner
    address public owner;

    // Address of the Market contract
    address public marketContract;

    // Market parameters
    uint256 public alpha;
    uint256 public liquidityParameter;
    uint256 public feeRate;

    // Mapping to track net outcome tokens sold
    mapping(uint256 => uint256) public netOutcomeTokensSold;

    // Events
    event OutcomeTokensBought(address indexed buyer, uint256 indexed outcome, uint256 indexed tokensBought, uint256 cost);
    event OutcomeTokensSold(address indexed seller, uint256 indexed outcome, uint256 indexed tokensSold, uint256 profit);

    // Modifiers
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    constructor(uint256 _alpha, uint256 _liquidityParameter, uint256 _feeRate) {
        owner = msg.sender;
        alpha = _alpha;
        liquidityParameter = _liquidityParameter;
        feeRate = _feeRate;
    }

    // Function to set Market contract address
    function setMarketContract(address _marketContract) external onlyOwner {
        marketContract = _marketContract;
    }

    // Function to buy outcome tokens
    function buyOutcomeTokens(uint256 _outcome, uint256 _tokensToBuy) external payable {
        require(marketContract != address(0), "Market contract address not set");
        uint256 cost = calcCost(_outcome, _tokensToBuy);
        require(msg.value >= cost, "Insufficient funds");

        netOutcomeTokensSold[_outcome] = netOutcomeTokensSold[_outcome].add(_tokensToBuy);

        emit OutcomeTokensBought(msg.sender, _outcome, _tokensToBuy, cost);
    }

    // Function to sell outcome tokens
    function sellOutcomeTokens(uint256 _outcome, uint256 _tokensToSell) external {
        require(marketContract != address(0), "Market contract address not set");
        uint256 profit = calcProfit(_outcome, _tokensToSell);

        netOutcomeTokensSold[_outcome] = netOutcomeTokensSold[_outcome].sub(_tokensToSell);

        payable(msg.sender).transfer(profit);

        emit OutcomeTokensSold(msg.sender, _outcome, _tokensToSell, profit);
    }

    // View function to calculate net cost of executing a trade
    function calcNetCost(uint256 _outcome, uint256 _tokensToBuy) public view returns (uint256) {
        uint256 cost = calcCost(_outcome, _tokensToBuy);
        return cost;
    }

    // View function to calculate cost to buy outcome tokens
    function calcCost(uint256 _outcome, uint256 _tokensToBuy) public view returns (uint256) {
        require(marketContract != address(0), "Market contract address not set");

        uint256 currentSupply = Market(marketContract).totalSupply();
        uint256 outcomeSupply = Market(marketContract).balances(_outcome);
        uint256 liquidity = liquidityParameter.mul(currentSupply);

        uint256 expOutcome = _tokensToBuy.mul(liquidity).div(outcomeSupply);
        uint256 sumExp = sumExpOffset(expOutcome);
        uint256 marginalPrice = sumExp.add(liquidity).sub(sumExpOffset(liquidity));

        return marginalPrice;
    }

    // View function to calculate profit from selling outcome tokens
    function calcProfit(uint256 _outcome, uint256 _tokensToSell) public view returns (uint256) {
        require(marketContract != address(0), "Market contract address not set");

        uint256 currentSupply = Market(marketContract).totalSupply();
        uint256 outcomeSupply = Market(marketContract).balances(_outcome);
        uint256 liquidity = liquidityParameter.mul(currentSupply);

        uint256 expOutcome = _tokensToSell.mul(liquidity).div(outcomeSupply);
        uint256 sumExp = sumExpOffset(expOutcome);
        uint256 marginalPrice = sumExp.add(liquidity).sub(sumExpOffset(liquidity));

        uint256 profit = _tokensToSell.mul(marginalPrice).div(alpha);
        uint256 fee = profit.mul(feeRate).div(10000); // feeRate is in basis points
        return profit.sub(fee);
    }

    // View function to calculate marginal price of an outcome token
    function calcMarginalPrice(uint256 _outcome) public view returns (uint256) {
        require(marketContract != address(0), "Market contract address not set");

        uint256 currentSupply = Market(marketContract).totalSupply();
        uint256 outcomeSupply = Market(marketContract).balances(_outcome);
        uint256 liquidity = liquidityParameter.mul(currentSupply);

        uint256 expOutcome = liquidity.div(outcomeSupply);
        uint256 sumExp = sumExpOffset(expOutcome);
        uint256 marginalPrice = sumExp.add(liquidity).sub(sumExpOffset(liquidity));

        return marginalPrice;
    }

    // Internal function to calculate the sum of exponential terms with an offset
    function sumExpOffset(uint256 _exp) internal view returns (uint256) {
        uint256 offset = 10**18;
        return offset.mul(alpha).mul((2**_exp).sub(1)).div(2**_exp);
    }

    // Function to retrieve the net outcome tokens sold by the market for each outcome
    function getNetOutcomeTokensSold(uint256 _outcome) external view returns (uint256) {
        return netOutcomeTokensSold[_outcome];
    }

    // Fallback function to receive Ether
    receive() external payable {}
}

// SafeMath library to prevent overflows and underflows
library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        return c;
    }
}

// Interface for Market contract
interface Market {
    function totalSupply() external view returns (uint256);
    function balances(uint256 _account) external view returns (uint256);
}
