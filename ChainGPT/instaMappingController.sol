
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";

// Interfaces
interface IndexInterface {
    function master() external view returns (address);
}

interface ConnectorsInterface {
    function chief(address) external view returns (bool);
}

contract InstaMappingController is AccessControl {
    bytes32 public constant MASTER_ROLE = keccak256("MASTER_ROLE");

    // Constants for instaIndex and connectors contract addresses
    address public constant instaIndex = 0x2971AdFa57b20E5a416aE5a708A8655A9c74f723;
    address public constant connectors = 0xD6A602C01a023B98Ecfb29Df02FBA380d3B21E0c;

    event RoleGranted(bytes32 indexed role, address indexed account);
    event RoleRevoked(bytes32 indexed role, address indexed account);

    modifier onlyMaster {
        require(hasRole(MASTER_ROLE, msg.sender), "InstaMappingController: not a master");
        _;
    }

    constructor() {
        _setupRole(MASTER_ROLE, msg.sender);
    }

    function grantRole(bytes32 role, address account) public onlyMaster {
        _grantRole(role, account);
        emit RoleGranted(role, account);
    }

    function revokeRole(bytes32 role, address account) public onlyMaster {
        _revokeRole(role, account);
        emit RoleRevoked(role, account);
    }

    function renounceRole(bytes32 role, address account) public {
        require(account == msg.sender, "InstaMappingController: can only renounce roles for self");
        _revokeRole(role, account);
        emit RoleRevoked(role, account);
    }

    function hasRole(bytes32 role, address account) public view returns (bool) {
        return _hasRole(role, account);
    }

    function getRoleMemberCount(bytes32 role) public view returns (uint256) {
        return _getRoleMemberCount(role);
    }

    function getRoleMember(bytes32 role, uint256 index) public view returns (address) {
        return _getRoleMember(role, index);
    }

    // Internal functions for handling the addition and removal of roles for accounts
    function _grantRole(bytes32 role, address account) internal {
        _setupRole(role, account);
    }

    function _revokeRole(bytes32 role, address account) internal {
        revokeRole(role, account);
    }
}
