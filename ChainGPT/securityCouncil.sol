
// SPDX-License-Identifier: Apache-2.0
// Copyright 2023 ZeroEx Intl.

pragma solidity ^0.8.19;

abstract contract SecurityCouncil {
    // State variable to store current security council's address
    address public securityCouncil;

    // Events
    event SecurityCouncilAssigned(address indexed newSecurityCouncil);
    event SecurityCouncilEjected();

    // Modifiers
    modifier onlySecurityCouncil() {
        _checkSenderIsSecurityCouncil();
        _;
    }

    modifier securityCouncilAssigned() {
        require(securityCouncil != address(0), "Security council must be assigned");
        _;
    }

    // Assign a new security council
    function assignSecurityCouncil(address _securityCouncil) public onlySecurityCouncil {
        securityCouncil = _securityCouncil;
        emit SecurityCouncilAssigned(_securityCouncil);
    }

    // Eject the current security council
    function ejectSecurityCouncil() internal onlySecurityCouncil {
        securityCouncil = address(0);
        emit SecurityCouncilEjected();
    }

    // Abstract function for cancellation operations
    function cancel(address[] memory targets, uint256[] memory values, bytes[] memory calldatas, bytes32 descriptionHash) public virtual;

    // Check if the payload is an assignment call to the security council
    function _payloadIsAssignSecurityCouncil(bytes[] memory payloads) private pure returns (bool) {
        bytes4 functionSignature = bytes4(keccak256("assignSecurityCouncil(address)"));
        for(uint i = 0; i < payloads.length; i++) {
            bytes4 payloadFunctionSignature = bytes4(payloads[i][0]) | bytes4(payloads[i][1] >> 8) | bytes4(payloads[i][2] >> 16) | bytes4(payloads[i][3] >> 24);
            if(functionSignature == payloadFunctionSignature) {
                return true;
            }
        }
        return false;
    }

    // Check if the sender is the current security council
    function _checkSenderIsSecurityCouncil() private view {
        require(msg.sender == securityCouncil, "Sender must be the security council");
    }
}
