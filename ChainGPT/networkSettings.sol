
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Address.sol";

// Interface for the NetworkSettings contract
interface INetworkSettings {
    function networkFeeParams() external view returns (address, uint256);
    function networkFeeWallet() external view returns (address);
    function networkFee() external view returns (uint256);
    function setNetworkFeeWallet(address newNetworkFeeWallet) external;
    function setNetworkFee(uint256 newNetworkFee) external;
}

// NetworkSettings contract
contract NetworkSettings is Ownable, INetworkSettings {
    using Address for address;

    uint256 private _networkFee; // The network fee in units of PPM
    address private _networkFeeWallet; // The wallet that receives the global network fees

    event NetworkFeeWalletUpdated(address indexed prevWallet, address indexed newWallet);
    event NetworkFeeUpdated(uint256 prevFee, uint256 newFee);

    // Initialize the contract with an initial network fee wallet and an initial network fee
    constructor(address initialNetworkFeeWallet, uint256 initialNetworkFee) {
        require(initialNetworkFeeWallet != address(0), "NetworkSettings: wallet address cannot be zero");
        require(initialNetworkFee <= 1000000, "NetworkSettings: invalid network fee"); // PPM cannot exceed 1000000

        _networkFeeWallet = initialNetworkFeeWallet;
        _networkFee = initialNetworkFee;
    }

    // Returns the network fee parameters (network fee wallet and network fee)
    function networkFeeParams() public view override returns (address, uint256) {
        return (_networkFeeWallet, _networkFee);
    }

    // Returns the wallet that receives the global network fees
    function networkFeeWallet() public view override returns (address) {
        return _networkFeeWallet;
    }

    // Returns the global network fee in units of PPM
    function networkFee() public view override returns (uint256) {
        return _networkFee;
    }

    // Sets the network fee wallet. Only callable by the owner
    function setNetworkFeeWallet(address newNetworkFeeWallet) public override onlyOwner {
        require(newNetworkFeeWallet != address(0), "NetworkSettings: new wallet address cannot be zero");

        emit NetworkFeeWalletUpdated(_networkFeeWallet, newNetworkFeeWallet);
        _networkFeeWallet = newNetworkFeeWallet;
    }

    // Sets the network fee in units of PPM. Only callable by the owner
    function setNetworkFee(uint256 newNetworkFee) public override onlyOwner {
        require(newNetworkFee <= 1000000, "NetworkSettings: invalid new network fee"); // PPM cannot exceed 1000000

        emit NetworkFeeUpdated(_networkFee, newNetworkFee);
        _networkFee = newNetworkFee;
    }
}
