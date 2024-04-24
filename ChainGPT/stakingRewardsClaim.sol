
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/draft-EIP712.sol";

// Interfaces for external systems interaction
interface ITokenGovernance {
    function mint(address to, uint256 amount) external;
}

interface IBancorNetworkV3 {
    function deposit(address token, address to, uint256 amount) external;
}

contract RewardClaimer is ReentrancyGuard, EIP712 {
    using ECDSA for bytes32;

    // State variables
    address private _owner;
    bool private _paused = false;
    IERC20 public token;
    ITokenGovernance public tokenGovernance;
    IBancorNetworkV3 public bancorNetwork;

    // Events
    event RewardClaimed(address indexed user, uint256 amount);
    event RewardStaked(address indexed user, uint256 amount);

    // Modifiers
    modifier onlyOwner() {
        require(msg.sender == _owner, "Only owner can call this function.");
        _;
    }

    modifier whenNotPaused() {
        require(!_paused, "Pausable: paused");
        _;
    }

    constructor(address token_, address tokenGovernance_, address bancorNetwork_)
        EIP712("RewardClaimer", "1.0")
    {
        _owner = msg.sender;
        token = IERC20(token_);
        tokenGovernance = ITokenGovernance(tokenGovernance_);
        bancorNetwork = IBancorNetworkV3(bancorNetwork_);
    }

    function pause() external onlyOwner {
        _paused = true;
    }

    function unpause() external onlyOwner {
        _paused = false;
    }

    function claimReward(uint256 amount, bytes calldata signature) external nonReentrant whenNotPaused {
        bytes32 hash = _hashTypedDataV4(keccak256(abi.encodePacked(msg.sender, amount)));
        address signer = hash.recover(signature);
        require(signer == _owner, "Invalid signature");

        tokenGovernance.mint(msg.sender, amount);
        emit RewardClaimed(msg.sender, amount);
    }

    function stakeReward(uint256 amount, bytes calldata signature) external nonReentrant whenNotPaused {
        bytes32 hash = _hashTypedDataV4(keccak256(abi.encodePacked(msg.sender, amount)));
        address signer = hash.recover(signature);
        require(signer == _owner, "Invalid signature");

        tokenGovernance.mint(address(this), amount);
        token.approve(address(bancorNetwork), amount);
        bancorNetwork.deposit(address(token), msg.sender, amount);
        emit RewardStaked(msg.sender, amount);
    }
}
