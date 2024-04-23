// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2023 ZeroEx Intl.

pragma solidity ^0.8.19;

abstract contract SecurityCouncil {
    address public securityCouncil;

    event SecurityCouncilAssigned(address indexed newSecurityCouncil);
    event SecurityCouncilEjected(address indexed ejectedSecurityCouncil);

    modifier onlySecurityCouncil() {
        require(msg.sender == securityCouncil, "Caller is not the Security Council");
        _;
    }

    modifier securityCouncilAssigned() {
        require(securityCouncil != address(0), "Security Council not assigned");
        _;
    }

    function assignSecurityCouncil(address _securityCouncil) external virtual;

    function ejectSecurityCouncil() internal virtual;

    function cancel(address[] memory targets, uint256[] memory values, bytes[] memory calldatas, bytes32 descriptionHash) public virtual;

    function _payloadIsAssignSecurityCouncil(bytes[] memory payloads) private pure returns (bool) {
        require(payloads.length > 0, "Payloads must not be empty");
        bytes4 expectedFunctionSignature = bytes4(keccak256(bytes("assignSecurityCouncil(address)")));
        bytes4 payloadFunctionSignature = abi.decode(payloads[0][0:4], (bytes4));
        return payloadFunctionSignature == expectedFunctionSignature;
    }

    function _checkSenderIsSecurityCouncil() private view {
        require(msg.sender == securityCouncil, "Sender is not the Security Council");
    }
}
