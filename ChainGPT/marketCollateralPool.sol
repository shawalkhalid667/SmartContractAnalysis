
// SPDX-License-Identifier: Apache-2.0

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract MarketCollateralPool {
    using SafeMath for uint256;
    using SafeERC20 for ERC20;

    // Mapping to track the collateral pool balance for each market contract.
    mapping(address => uint256) public collateralPoolBalance;

    // Mapping to track the fees collected by token address.
    mapping(address => uint256) public feesCollected;

    // ERC20 contract for MKT tokens.
    ERC20 public mktToken;

    // Market contract registry address.
    address public marketContractRegistry;

    // Events for minting and redeeming tokens.
    event MintPositionTokens(address indexed user, uint256 amount);
    event RedeemPositionTokens(address indexed user, uint256 amount);

    // Modifier to restrict certain functions to whitelisted market contract addresses.
    modifier onlyWhitelistedMarketContract() {
        require(
            marketContractRegistry == msg.sender,
            "Only whitelisted market contracts can call this function."
        );
        _;
    }

    // Constructor to set the initial MKT token and market contract registry addresses.
    constructor(address _mktToken, address _marketContractRegistry) {
        mktToken = ERC20(_mktToken);
        marketContractRegistry = _marketContractRegistry;
    }

    // Function to mint position tokens.
    function mintPositionTokens(uint256 _amount) external {
        mktToken.safeTransferFrom(msg.sender, address(this), _amount);
        collateralPoolBalance[msg.sender] = collateralPoolBalance[msg.sender].add(_amount);
        emit MintPositionTokens(msg.sender, _amount);
    }

    // Function to redeem position tokens.
    function redeemPositionTokens(uint256 _amount) external {
        require(
            collateralPoolBalance[msg.sender] >= _amount,
            "Insufficient balance to redeem tokens."
        );
        collateralPoolBalance[msg.sender] = collateralPoolBalance[msg.sender].sub(_amount);
        mktToken.safeTransfer(msg.sender, _amount);
        emit RedeemPositionTokens(msg.sender, _amount);
    }

    // Function to withdraw collected fees.
    function withdrawFees() external {
        uint256 fees = feesCollected[msg.sender];
        require(fees > 0, "No fees to withdraw.");
        feesCollected[msg.sender] = 0;
        mktToken.safeTransfer(msg.sender, fees);
    }

    // Function to update the MKT token address.
    function updateMktTokenAddress(address _newMktToken) external {
        mktToken = ERC20(_newMktToken);
    }

    // Function to update the market contract registry address.
    function updateMarketContractRegistry(address _newMarketContractRegistry) external {
        marketContractRegistry = _newMarketContractRegistry;
    }
}
