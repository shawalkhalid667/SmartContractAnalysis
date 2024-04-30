// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Interface defining the functions that the NetworkSettings contract implements
interface INetworkSettings {
    function networkFeeParams() external view returns (address, uint256);
    function networkFeeWallet() external view returns (address);
    function networkFee() external view returns (uint256);
    function setNetworkFeeWallet(address newNetworkFeeWallet) external;
    function setNetworkFee(uint256 newNetworkFee) external;
}

// NetworkSettings contract
contract NetworkSettings {
    // State variables
    address private _owner;
    address private _networkFeeWallet;
    uint256 private _networkFee;

    // Initialization
    constructor(address initialNetworkFeeWallet, uint256 initialNetworkFee) {
        _owner = msg.sender;
        _networkFeeWallet = initialNetworkFeeWallet;
        _networkFee = initialNetworkFee;
    }

    // Events
    event NetworkFeeWalletUpdated(address indexed newNetworkFeeWallet);
    event NetworkFeeUpdated(uint256 newNetworkFee);

    // Functions

    // Returns the network fee parameters (network fee wallet and network fee)
    function networkFeeParams() external view returns (address, uint256) {
        return (_networkFeeWallet, _networkFee);
    }

    // Returns the wallet that receives the global network fees
    function networkFeeWallet() external view returns (address) {
        return _networkFeeWallet;
    }

    // Returns the global network fee in units of PPM
    function networkFee() external view returns (uint256) {
        return _networkFee;
    }

    // Sets the network fee wallet. Only callable by the owner.
    function setNetworkFeeWallet(address newNetworkFeeWallet) external ownerOnly validAddress(newNetworkFeeWallet) {
        _networkFeeWallet = newNetworkFeeWallet;
        emit NetworkFeeWalletUpdated(newNetworkFeeWallet);
    }

    // Sets the network fee in units of PPM. Only callable by the owner.
    function setNetworkFee(uint256 newNetworkFee) external ownerOnly validFee(newNetworkFee) {
        _networkFee = newNetworkFee;
        emit NetworkFeeUpdated(newNetworkFee);
    }

    // Modifiers

    // Ensures that only the owner of the contract can access certain functions
    modifier ownerOnly() {
        require(msg.sender == _owner, "Only the owner can call this function");
        _;
    }

    // Validates that the address passed is not zero
    modifier validAddress(address addr) {
        require(addr != address(0), "Invalid address");
        _;
    }

    // Validates that the network fee is a valid value
    modifier validFee(uint256 fee) {
        require(fee > 0 && fee <= 1000000, "Invalid network fee");
        _;
    }
}
