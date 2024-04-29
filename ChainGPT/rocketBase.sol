
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "./RocketStorageInterface.sol";

contract RocketBase is Context, AccessControl {
    // Constants
    uint256 constant calcBase = 1 ether;

    // Members
    uint256 public version;
    RocketStorageInterface rocketStorage;

    // Role definitions for access control
    bytes32 public constant LATEST_NETWORK_CONTRACT_ROLE = keccak256("LATEST_NETWORK_CONTRACT_ROLE");
    bytes32 public constant LATEST_CONTRACT_ROLE = keccak256("LATEST_CONTRACT_ROLE");
    bytes32 public constant REGISTERED_NODE_ROLE = keccak256("REGISTERED_NODE_ROLE");
    bytes32 public constant TRUSTED_NODE_ROLE = keccak256("TRUSTED_NODE_ROLE");
    bytes32 public constant REGISTERED_MINIPOOL_ROLE = keccak256("REGISTERED_MINIPOOL_ROLE");
    bytes32 public constant GUARDIAN_ROLE = keccak256("GUARDIAN_ROLE");

    // Constructor
    constructor(address _rocketStorageAddress) {
        rocketStorage = RocketStorageInterface(_rocketStorageAddress);
    }

    // Modifiers
    modifier onlyLatestNetworkContract() {
        require(hasRole(LATEST_NETWORK_CONTRACT_ROLE, _msgSender()), "Not a latest network contract");
        _;
    }

    modifier onlyLatestContract() {
        require(hasRole(LATEST_CONTRACT_ROLE, _msgSender()), "Not a latest contract");
        _;
    }

    modifier onlyRegisteredNode() {
        require(hasRole(REGISTERED_NODE_ROLE, _msgSender()), "Not a registered node");
        _;
    }

    modifier onlyTrustedNode() {
        require(hasRole(TRUSTED_NODE_ROLE, _msgSender()), "Not a trusted node");
        _;
    }

    modifier onlyRegisteredMinipool() {
        require(hasRole(REGISTERED_MINIPOOL_ROLE, _msgSender()), "Not a registered minipool");
        _;
    }

    modifier onlyGuardian() {
        require(hasRole(GUARDIAN_ROLE, _msgSender()), "Not a guardian");
        _;
    }

    // Functions
    function getContractAddress(string memory _name) public view returns (address) {
        return rocketStorage.getAddress(keccak256(abi.encodePacked("contract.address", _name)));
    }

    function getContractAddressUnsafe(string memory _name) public view returns (address) {
        return rocketStorage.getAddress(keccak256(abi.encodePacked("contract.address", _name)));
    }

    function getContractName(address _contractAddress) public view returns (string memory) {
        return rocketStorage.getString(keccak256(abi.encodePacked("contract.name", _contractAddress)));
    }

    function getRevertMsg(bytes memory _returnData) public pure returns (string memory) {
        if (_returnData.length < 68) return 'Transaction reverted silently';

        assembly {
            _returnData := add(_returnData, 0x04)
        }
        return abi.decode(_returnData, (string));
    }

    function getRate() public view returns (uint256) {
        // Implement SRN per 1 ETH rate calculation based on the current time
        return 1;  // Placeholder
    }

    // Rocket Storage Methods
    function setRocketStorageAddress(address _newRocketStorageAddress) public onlyGuardian {
        rocketStorage = RocketStorageInterface(_newRocketStorageAddress);
    }
}
