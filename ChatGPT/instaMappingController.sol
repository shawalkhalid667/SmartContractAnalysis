// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IndexInterface {
    // Define IndexInterface here
}

interface ConnectorsInterface {
    // Define ConnectorsInterface here
}

contract InstaMappingController {
    mapping(bytes32 => mapping(address => bool)) private _roles;
    mapping(bytes32 => address[]) private _roleMembers;
    
    address public migrationInfoSetter;
    address public constant instaIndex = address(0x123); // Placeholder address
    address public constant connectors = address(0x456); // Placeholder address

    modifier onlyMaster() {
        require(msg.sender == migrationInfoSetter || msg.sender == connectors, "Only master or chief connectors can call this function");
        _;
    }

    event RoleGranted(bytes32 role, address account);
    event RoleRevoked(bytes32 role, address account);

    constructor(address _migrationInfoSetter) {
        migrationInfoSetter = _migrationInfoSetter;
    }

    function setupRole(bytes32 role, address[] calldata accounts) external onlyMaster {
        for (uint256 i = 0; i < accounts.length; i++) {
            _grantRole(role, accounts[i]);
        }
    }

    function grantRole(bytes32 role, address account) external onlyMaster {
        _grantRole(role, account);
    }

    function revokeRole(bytes32 role, address account) external onlyMaster {
        _revokeRole(role, account);
    }

    function renounceRole(bytes32 role) external {
        _revokeRole(role, msg.sender);
    }

    function hasRole(bytes32 role, address account) external view returns (bool) {
        return _roles[role][account];
    }

    function getRoleMemberCount(bytes32 role) external view returns (uint256) {
        return _roleMembers[role].length;
    }

    function getRoleMember(bytes32 role, uint256 index) external view returns (address) {
        require(index < _roleMembers[role].length, "Index out of bounds");
        return _roleMembers[role][index];
    }

    function _grantRole(bytes32 role, address account) internal {
        require(!_roles[role][account], "Account already has role");
        _roles[role][account] = true;
        _roleMembers[role].push(account);
        emit RoleGranted(role, account);
    }

    function _revokeRole(bytes32 role, address account) internal {
        require(_roles[role][account], "Account does not have role");
        _roles[role][account] = false;
        for (uint256 i = 0; i < _roleMembers[role].length; i++) {
            if (_roleMembers[role][i] == account) {
                _roleMembers[role][i] = _roleMembers[role][_roleMembers[role].length - 1];
                _roleMembers[role].pop();
                emit RoleRevoked(role, account);
                return;
            }
        }
    }
}
