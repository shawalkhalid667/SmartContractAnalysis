
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Address.sol";

contract BulkSender is Ownable {
    using Address for address payable;

    // VIP list
    mapping(address => bool) private _vipList;

    // Receiver address for transactions
    address payable private _receiverAddress;

    // Event to log bulk transfers
    event BulkTransfer(address indexed from, address indexed to, uint256 amount);

    // Event to log VIP registration
    event VIPRegistered(address indexed account);

    // Event to log VIP removal
    event VIPRemoved(address indexed account);

    // Set the receiver address
    function setReceiverAddress(address payable receiverAddress) external onlyOwner {
        _receiverAddress = receiverAddress;
    }

    // Get the current balance of the contract
    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }

    // Register the caller as a VIP
    function registerVIP() external payable {
        require(msg.value > 0, "Must send a fee to register as a VIP");
        _receiverAddress.sendValue(msg.value);
        _vipList[msg.sender] = true;
        emit VIPRegistered(msg.sender);
    }

    // Add addresses to the VIP list
    function addToVIPList(address[] calldata accounts) external onlyOwner {
        for (uint256 i = 0; i < accounts.length; i++) {
            _vipList[accounts[i]] = true;
            emit VIPRegistered(accounts[i]);
        }
    }

    // Remove addresses from the VIP list
    function removeFromVIPList(address[] calldata accounts) external onlyOwner {
        for (uint256 i = 0; i < accounts.length; i++) {
            _vipList[accounts[i]] = false;
            emit VIPRemoved(accounts[i]);
        }
    }

    // Check if an address is a VIP
    function isVIP(address account) external view returns (bool) {
        return _vipList[account];
    }

    // Send ether to multiple addresses with the same value
    function ethSendSameValue(address payable[] calldata to, uint256 value) external payable {
        for (uint256 i = 0; i < to.length; i++) {
            to[i].sendValue(value);
            emit BulkTransfer(msg.sender, to[i], value);
        }
    }

    // Send ether to multiple addresses with different values
    function ethSendDifferentValue(address payable[] calldata to, uint256[] calldata values) external payable {
        require(to.length == values.length, "Mismatched arrays");
        for (uint256 i = 0; i < to.length; i++) {
            to[i].sendValue(values[i]);
            emit BulkTransfer(msg.sender, to[i], values[i]);
        }
    }

    // Send ERC20 tokens to multiple addresses with the same value
    function coinSendSameValue(IERC20 token, address[] calldata to, uint256 value) external {
        for (uint256 i = 0; i < to.length; i++) {
            token.transferFrom(msg.sender, to[i], value);
            emit BulkTransfer(msg.sender, to[i], value);
        }
    }

    // Send ERC20 tokens to multiple addresses with different values
    function coinSendDifferentValue(IERC20 token, address[] calldata to, uint256[] calldata values) external {
        require(to.length == values.length, "Mismatched arrays");
        for (uint256 i = 0; i < to.length; i++) {
            token.transferFrom(msg.sender, to[i], values[i]);
            emit BulkTransfer(msg.sender, to[i], values[i]);
        }
    }
}
