// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract e2pEscrow {
    address public owner;
    address public verifier;
    uint public fixedCommissionFee;
    uint public commissionToWithdraw;

    mapping(address => uint) public deposits;
    mapping(address => bool) public transferCancelled;

    event Deposit(address indexed from, uint value);
    event Withdraw(address indexed to, uint value);
    event TransferCancelled(address indexed sender, uint value);

    constructor(address _verifier, uint _fixedCommissionFee) {
        owner = msg.sender;
        verifier = _verifier;
        fixedCommissionFee = _fixedCommissionFee;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only contract owner can call this function");
        _;
    }

    modifier onlyVerifier() {
        require(msg.sender == verifier, "Only verifier can call this function");
        _;
    }

    function deposit() external payable {
        require(msg.value > 0, "Value must be greater than zero");
        deposits[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    function withdraw(address payable _recipient, address _signedAddress) external onlyVerifier {
        require(deposits[_recipient] > 0, "No deposit found for the recipient");
        require(!transferCancelled[_recipient], "Transfer is cancelled");

        // Off-chain verification of the signed address should be performed here

        uint commission = calculateCommission();
        uint amountToSend = deposits[_recipient] - commission;
        
        _recipient.transfer(amountToSend);
        commissionToWithdraw += commission;
        deposits[_recipient] = 0;

        emit Withdraw(_recipient, amountToSend);
    }

    function cancelTransfer() external {
        require(deposits[msg.sender] > 0, "No deposit found for the sender");
        require(!transferCancelled[msg.sender], "Transfer is already cancelled");

        transferCancelled[msg.sender] = true;
        uint amountToRefund = deposits[msg.sender];
        deposits[msg.sender] = 0;
        
        payable(msg.sender).transfer(amountToRefund);

        emit TransferCancelled(msg.sender, amountToRefund);
    }

    function changeFixedCommissionFee(uint _newCommissionFee) external onlyOwner {
        fixedCommissionFee = _newCommissionFee;
    }

    function changeVerifier(address _newVerifier) external onlyOwner {
        verifier = _newVerifier;
    }

    function withdrawCommission() external onlyVerifier {
        require(commissionToWithdraw > 0, "No commission to withdraw");
        
        uint commissionAmount = commissionToWithdraw;
        commissionToWithdraw = 0;

        payable(verifier).transfer(commissionAmount);
    }

    function calculateCommission() internal view returns (uint) {
        return fixedCommissionFee;
    }
}
