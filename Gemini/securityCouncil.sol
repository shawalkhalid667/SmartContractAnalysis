// SPDX-License-Identifier: Apache-2.0
// Copyright (C) 2023 0x (ZeroEx Intl.)

pragma solidity ^0.8.19;

abstract contract SecurityCouncil {

    // State Variable
    address public securityCouncil;

    // Events
    event SecurityCouncilAssigned(address newSecurityCouncil);
    event SecurityCouncilEjected();

    // Modifiers
    modifier onlySecurityCouncil() {
        _checkSenderIsSecurityCouncil();
        _;
    }

    modifier securityCouncilAssigned() {
        require(securityCouncil != address(0), "Security Council not assigned");
        _;
    }

    // Functions

    function assignSecurityCouncil(address _securityCouncil) public {
        require(!_payloadIsAssignSecurityCouncil(msg.data), "Cannot assign within assign tx");
        securityCouncil = _securityCouncil;
        emit SecurityCouncilAssigned(_securityCouncil);
    }

    function ejectSecurityCouncil() internal {
        securityCouncil = address(0);
        emit SecurityCouncilEjected();
    }

    function cancel(address[] memory targets, uint256[] memory values, bytes[] memory calldatas, bytes32 descriptionHash) public virtual onlySecurityCouncil;

    // Internal Functions

    function _payloadIsAssignSecurityCouncil(bytes[] memory payloads) private pure returns (bool) {
        for (uint256 i = 0; i < payloads.length; i++) {
            bytes4 functionSignature = bytes4(keccak256(payloads[i]));
            if (functionSignature == keccak256("assignSecurityCouncil(address)")) {
                return true;
            }
        }
        return false;
    }

    function _checkSenderIsSecurityCouncil() private view {
        require(msg.sender == securityCouncil, "Only Security Council can call");
    }
}
