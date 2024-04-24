// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

interface IERC721 {
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
}

contract Marketplace is ReentrancyGuard {
    using ECDSA for bytes32;

    mapping(bytes32 => bool) private _usedSignatures;

    struct Trade {
        address sender;
        address receiver;
        uint256[] tokenIds;
        uint256[] amounts;
        uint256 expiration;
        // Additional fields as needed
    }

    enum AssetType {
        ERC20,
        ERC721
    }

    event TradeExecuted(bytes32 indexed hash);
    event InvalidSignature(bytes32 indexed hash);

    modifier onlyOwner() {
        require(msg.sender == owner(), "Ownable: caller is not the owner");
        _;
    }

    address private _owner;

    constructor() {
        _owner = msg.sender;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _owner = newOwner;
    }

    function owner() public view returns (address) {
        return _owner;
    }

    function generateSignature(bytes32 hash, address signer) internal view returns (bytes memory) {
        return hash.toEthSignedMessageHash().recover(signer);
    }

    function verifySignature(bytes32 hash, bytes memory signature, address signer) internal pure returns (bool) {
        return hash.toEthSignedMessageHash().recover(signature) == signer;
    }

    function executeTrade(bytes32 hash, bytes memory signature) external nonReentrant {
        require(!_usedSignatures[hash], "Signature already used");
        require(verifySignature(hash, signature, msg.sender), "Invalid signature");

        // Execute trade
        _usedSignatures[hash] = true;

        emit TradeExecuted(hash);
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function _pause() internal virtual {
        _paused = true;
    }

    function _unpause() internal virtual {
        _paused = false;
    }

    bool private _paused;

    modifier whenNotPaused() {
        require(!_paused, "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(_paused, "Pausable: not paused");
        _;
    }

    function paused() public view returns (bool) {
        return _paused;
    }
}
