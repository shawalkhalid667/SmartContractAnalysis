// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/math/SafeERC20.sol";

contract CrowdsaleWPTByAuction is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for ERC20;

    ERC20 public token;
    address public minterContract;
    uint256 public totalInvested;
    mapping(address => uint256) public investments;
    mapping(address => uint256) public bonuses;
    mapping(uint256 => uint256) public roundCaps;
    uint256 public currentRound;
    bool public saleOpen;

    event RoundStarted(uint256 round);
    event RoundClosed(uint256 round);
    event TokensPurchased(address buyer, uint256 amount, uint256 bonus);
    event FundsForwarded(address wallet, uint256 amount);

    constructor(address _token) {
        token = ERC20(_token);
        saleOpen = false;
    }

    function startRound(uint256 _round, uint256 _cap) external onlyOwner {
        require(!saleOpen, "Previous round must be closed");
        currentRound = _round;
        roundCaps[_round] = _cap;
        saleOpen = true;
        emit RoundStarted(_round);
    }

    function closeRound() external onlyOwner {
        require(saleOpen, "No open round to close");
        saleOpen = false;
        emit RoundClosed(currentRound);
    }

    function purchaseTokens() external payable {
        require(saleOpen, "Crowdsale not open");
        require(msg.value > 0, "Sent ETH must be greater than 0");
        require(investments[msg.sender].add(msg.value) <= roundCaps[currentRound], "Investment cap reached");

        uint256 tokensToPurchase = msg.value;
        uint256 bonus = 0; // Calculate bonus if applicable

        token.safeTransfer(msg.sender, tokensToPurchase);
        totalInvested = totalInvested.add(msg.value);
        investments[msg.sender] = investments[msg.sender].add(msg.value);
        bonuses[msg.sender] = bonuses[msg.sender].add(bonus);

        emit TokensPurchased(msg.sender, tokensToPurchase, bonus);
    }

    function forwardFunds(address _wallet) external onlyOwner {
        require(_wallet != address(0), "Invalid wallet address");
        require(address(this).balance > 0, "No funds to forward");

        payable(_wallet).transfer(address(this).balance);
        emit FundsForwarded(_wallet, address(this).balance);
    }

    // Other functions for managing minter contract, bonus, investment validation, etc.
}

contract CrowdsaleWPTByRounds is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for ERC20;

    ERC20 public token;
    address public minterContract;
    uint256 public totalInvested;
    uint256 public tokenRate;
    mapping(address => uint256) public investments;
    mapping(uint256 => uint256) public roundCaps;
    uint256 public currentRound;
    bool public saleOpen;

    event RoundStarted(uint256 round);
    event RoundClosed(uint256 round);
    event TokensPurchased(address buyer, uint256 amount);
    event FundsForwarded(address wallet, uint256 amount);

    constructor(address _token) {
        token = ERC20(_token);
        saleOpen = false;
    }

    function startRound(uint256 _round, uint256 _cap) external onlyOwner {
        require(!saleOpen, "Previous round must be closed");
        currentRound = _round;
        roundCaps[_round] = _cap;
        saleOpen = true;
        emit RoundStarted(_round);
    }

    function closeRound() external onlyOwner {
        require(saleOpen, "No open round to close");
        saleOpen = false;
        emit RoundClosed(currentRound);
    }

    function purchaseTokens() external payable {
        require(saleOpen, "Crowdsale not open");
        require(msg.value > 0, "Sent ETH must be greater than 0");
        require(investments[msg.sender].add(msg.value) <= roundCaps[currentRound], "Investment cap reached");

        uint256 tokensToPurchase = msg.value.mul(tokenRate);

        token.safeTransfer(msg.sender, tokensToPurchase);
        totalInvested = totalInvested.add(msg.value);
        investments[msg.sender] = investments[msg.sender].add(msg.value);

        emit TokensPurchased(msg.sender, tokensToPurchase);
    }

    function forwardFunds(address _wallet) external onlyOwner {
        require(_wallet != address(0), "Invalid wallet address");
        require(address(this).balance > 0, "No funds to forward");

        payable(_wallet).transfer(address(this).balance);
        emit FundsForwarded(_wallet, address(this).balance);
    }

    // Other functions for managing minter contract, token rate, investment validation, etc.
}
