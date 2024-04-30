
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/cryptography/ECDSA.sol";

contract e2pEscrow {
    using ECDSA for bytes32;

    // Struct to hold transfer details
    struct Transfer {
        address sender;
        address recipient;
        uint256 amount;
        bool withdrawn;
    }

    // Contract owner (verifier)
    address private _owner;

    // Fixed commission fee
    uint256 private _commissionFee;

    // Accumulated commission
    uint256 private _accumulatedCommission;

    // Mapping of transit addresses to transfers
    mapping(address => Transfer) private _transfers;

    // Events
    event Deposit(address indexed sender, address indexed recipient, uint256 amount);
    event Withdrawal(address indexed recipient, uint256 amount);
    event Cancellation(address indexed sender, uint256 amount);
    event CommissionWithdrawal(uint256 amount);

    // Modifiers
    modifier onlyOwner() {
        require(msg.sender == _owner, "Only the owner can perform this action");
        _;
    }

    modifier onlySender(address transitAddress) {
        require(msg.sender == _transfers[transitAddress].sender, "Only the sender can perform this action");
        _;
    }

    // Constructor
    constructor(uint256 commissionFee, address owner) {
        _commissionFee = commissionFee;
        _owner = owner;
    }

    // Deposit function
    function deposit(address transitAddress, address recipient) external payable {
        require(msg.value > _commissionFee, "Deposit must be greater than the commission fee");
        _transfers[transitAddress] = Transfer(msg.sender, recipient, msg.value - _commissionFee, false);
        _accumulatedCommission += _commissionFee;
        emit Deposit(msg.sender, recipient, msg.value);
    }

    // Withdraw function
    function withdraw(address transitAddress, bytes memory signature) external onlyOwner {
        Transfer storage transfer = _transfers[transitAddress];
        require(!transfer.withdrawn, "Funds have already been withdrawn");

        // Verify signed address
        bytes32 hash = keccak256(abi.encodePacked(transitAddress)).toEthSignedMessageHash();
        address signer = hash.recover(signature);
        require(signer == transfer.recipient, "Invalid signature");

        transfer.withdrawn = true;
        payable(transfer.recipient).transfer(transfer.amount);
        emit Withdrawal(transfer.recipient, transfer.amount);
    }

    // Cancel transfer function
    function cancelTransfer(address transitAddress) external onlySender(transitAddress) {
        Transfer storage transfer = _transfers[transitAddress];
        require(!transfer.withdrawn, "Funds have already been withdrawn");

        transfer.withdrawn = true;
        payable(transfer.sender).transfer(transfer.amount);
        emit Cancellation(transfer.sender, transfer.amount);
    }

    // Change commission fee function
    function changeFixedCommissionFee(uint256 newCommissionFee) external onlyOwner {
        _commissionFee = newCommissionFee;
    }

    // Change verifier function
    function changeVerifier(address newOwner) external onlyOwner {
        _owner = newOwner;
    }

    // Withdraw commission function
    function withdrawCommission() external onlyOwner {
        uint256 amount = _accumulatedCommission;
        _accumulatedCommission = 0;
        payable(_owner).transfer(amount);
        emit CommissionWithdrawal(amount);
    }
}
