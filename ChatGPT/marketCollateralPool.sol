// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

// SafeERC20 library
library SafeERC20 {
    function safeTransfer(address token, address to, uint256 value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'SafeERC20: TRANSFER_FAILED');
    }
}

// ERC20 interface
interface ERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
}

// MathLib library
library MathLib {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "MathLib: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "MathLib: subtraction overflow");
        uint256 c = a - b;
        return c;
    }
}

contract MarketCollateralPool {
    using SafeERC20 for ERC20;
    using MathLib for uint256;

    // Events
    event TokensMinted(address indexed marketContract, address indexed user, uint256 amount);
    event TokensRedeemed(address indexed marketContract, address indexed user, uint256 amount);
    event FeesWithdrawn(address indexed owner, address indexed token, uint256 amount);

    // Struct to represent market contract details
    struct MarketContract {
        uint256 collateralBalance;
        uint256 feeBalance;
    }

    // State variables
    address public owner;
    address public mktTokenAddress;
    address public marketRegistryAddress;
    mapping(address => MarketContract) public marketContracts;

    // Modifiers
    modifier onlyOwner() {
        require(msg.sender == owner, "MarketCollateralPool: caller is not the owner");
        _;
    }

    modifier onlyMarketContract() {
        require(msg.sender == marketRegistryAddress, "MarketCollateralPool: caller is not a whitelisted market contract");
        _;
    }

    constructor(address _mktTokenAddress, address _marketRegistryAddress) {
        owner = msg.sender;
        mktTokenAddress = _mktTokenAddress;
        marketRegistryAddress = _marketRegistryAddress;
    }

    // Function to mint position tokens
    function mintTokens(address marketContract, address user, uint256 amount) external onlyMarketContract {
        require(marketContract != address(0), "MarketCollateralPool: invalid market contract address");
        require(user != address(0), "MarketCollateralPool: invalid user address");
        require(amount > 0, "MarketCollateralPool: amount must be greater than zero");

        MarketContract storage contractInfo = marketContracts[marketContract];
        contractInfo.collateralBalance = contractInfo.collateralBalance.add(amount);

        emit TokensMinted(marketContract, user, amount);
    }

    // Function to redeem position tokens
    function redeemTokens(address marketContract, address user, uint256 amount) external onlyMarketContract {
        require(marketContract != address(0), "MarketCollateralPool: invalid market contract address");
        require(user != address(0), "MarketCollateralPool: invalid user address");
        require(amount > 0, "MarketCollateralPool: amount must be greater than zero");

        MarketContract storage contractInfo = marketContracts[marketContract];
        require(contractInfo.collateralBalance >= amount, "MarketCollateralPool: insufficient collateral balance");

        contractInfo.collateralBalance = contractInfo.collateralBalance.sub(amount);

        emit TokensRedeemed(marketContract, user, amount);
    }

    // Function to settle positions after market contract settlement
    function settlePosition(address marketContract, address user, uint256 collateralChange) external onlyMarketContract {
        require(marketContract != address(0), "MarketCollateralPool: invalid market contract address");
        require(user != address(0), "MarketCollateralPool: invalid user address");

        MarketContract storage contractInfo = marketContracts[marketContract];
        contractInfo.collateralBalance = contractInfo.collateralBalance.add(collateralChange);
    }

    // Function to withdraw collected fees
    // Function to withdraw collected fees
function withdrawFees(address token) external onlyOwner {
    require(token != address(0), "MarketCollateralPool: invalid token address");

    uint256 feeAmount = marketContracts[msg.sender].feeBalance;
    require(feeAmount > 0, "MarketCollateralPool: no fees to withdraw");

    marketContracts[msg.sender].feeBalance = 0;
    ERC20(token).transfer(owner, feeAmount);

    emit FeesWithdrawn(owner, token, feeAmount);
}

    // Function to update MKT token address
    function updateMktTokenAddress(address _mktTokenAddress) external onlyOwner {
        require(_mktTokenAddress != address(0), "MarketCollateralPool: invalid MKT token address");
        mktTokenAddress = _mktTokenAddress;
    }

    // Function to update market contract registry address
    function updateMarketRegistryAddress(address _marketRegistryAddress) external onlyOwner {
        require(_marketRegistryAddress != address(0), "MarketCollateralPool: invalid market registry address");
        marketRegistryAddress = _marketRegistryAddress;
    }
}
