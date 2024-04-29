// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
}

contract BulkSender {
    address public owner;
    address public receiver;
    uint public fee;
    mapping(address => bool) public vipList;

    constructor() {
        owner = msg.sender;
        receiver = msg.sender;
        fee = 0;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    modifier onlyVIP() {
        require(vipList[msg.sender], "Only VIPs can call this function");
        _;
    }

    function getBalance() external onlyOwner {
        payable(receiver).transfer(address(this).balance);
    }

    function registerVIP() external payable {
        require(msg.value == fee, "Incorrect fee amount");
        vipList[msg.sender] = true;
        payable(receiver).transfer(msg.value);
    }

    function addToVIPList(address _address) external onlyOwner {
        vipList[_address] = true;
    }

    function removeFromVIPList(address _address) external onlyOwner {
        delete vipList[_address];
    }

    function isVIP(address _address) external view returns (bool) {
        return vipList[_address];
    }

    function setReceiverAddress(address _receiver) external onlyOwner {
        receiver = _receiver;
    }

    function setTransactionFee(uint _fee) external onlyOwner {
        fee = _fee;
    }

    function ethSendSameValue(address[] calldata _recipients, uint _value) external payable {
        require(_recipients.length > 0, "No recipients specified");
        require(msg.value >= _value * _recipients.length, "Insufficient funds");
        for (uint i = 0; i < _recipients.length; i++) {
            payable(_recipients[i]).transfer(_value);
        }
    }

    function ethSendDifferentValue(address[] calldata _recipients, uint[] calldata _values) external payable {
        require(_recipients.length > 0 && _values.length > 0 && _recipients.length == _values.length, "Invalid input");
        uint totalValue = 0;
        for (uint i = 0; i < _values.length; i++) {
            totalValue += _values[i];
        }
        require(msg.value >= totalValue, "Insufficient funds");
        for (uint i = 0; i < _recipients.length; i++) {
            require(_values[i] > 0, "Invalid value");
            payable(_recipients[i]).transfer(_values[i]);
        }
    }

    function sendEth(address payable _recipient, uint _value) external onlyVIP payable {
        require(msg.value >= _value, "Insufficient funds");
        _recipient.transfer(_value);
    }

    function bulksend(address payable[] calldata _recipients, uint[] calldata _values) external onlyVIP payable {
        require(_recipients.length > 0 && _values.length > 0 && _recipients.length == _values.length, "Invalid input");
        uint totalValue = 0;
        for (uint i = 0; i < _values.length; i++) {
            totalValue += _values[i];
        }
        require(msg.value >= totalValue, "Insufficient funds");
        for (uint i = 0; i < _recipients.length; i++) {
            require(_values[i] > 0, "Invalid value");
            _recipients[i].transfer(_values[i]);
        }
    }

    function bulkSendETHWithDifferentValue(address payable[] calldata _recipients, uint[] calldata _values) external onlyVIP payable {
        bulksend(_recipients, _values);
    }

    function bulkSendETHWithSameValue(address payable[] calldata _recipients, uint _value) external onlyVIP payable {
        uint[] memory values = new uint[](_recipients.length);
        for (uint i = 0; i < _recipients.length; i++) {
            values[i] = _value;
        }
        bulksend(_recipients, values);
    }

    function bulkSendCoinWithSameValue(address _tokenAddress, address[] calldata _recipients, uint _value) external onlyVIP {
        require(_recipients.length > 0, "No recipients specified");
        IERC20 token = IERC20(_tokenAddress);
        for (uint i = 0; i < _recipients.length; i++) {
            token.transferFrom(msg.sender, _recipients[i], _value);
        }
    }

    function bulkSendCoinWithDifferentValue(address _tokenAddress, address[] calldata _recipients, uint[] calldata _values) external onlyVIP {
        require(_recipients.length > 0 && _values.length > 0 && _recipients.length == _values.length, "Invalid input");
        IERC20 token = IERC20(_tokenAddress);
        for (uint i = 0; i < _recipients.length; i++) {
            require(_values[i] > 0, "Invalid value");
            token.transferFrom(msg.sender, _recipients[i], _values[i]);
        }
    }

    function bulksendToken(address _tokenAddress, address payable[] calldata _recipients, uint[] calldata _values) external onlyVIP {
        require(_recipients.length > 0 && _values.length > 0 && _recipients.length == _values.length, "Invalid input");
        IERC20 token = IERC20(_tokenAddress);
        for (uint i = 0; i < _recipients.length; i++) {
            require(_values[i] > 0, "Invalid value");
            token.transferFrom(msg.sender, _recipients[i], _values[i]);
        }
    }

    function drop(address _tokenAddress, address payable[] calldata _recipients, uint _value) external onlyVIP {
        require(_recipients.length > 0, "No recipients specified");
        IERC20 token = IERC20(_tokenAddress);
        for (uint i = 0; i < _recipients.length; i++) {
            token.transfer(_recipients[i], _value);
        }
    }
}
