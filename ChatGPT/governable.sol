// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Governable {
    address private governorPosition;
    address private pendingGovernorPosition;
    bool private reentryStatusPosition;

    event PendingGovernorshipTransfer(address indexed previousGovernor, address indexed newGovernor);
    event GovernorshipTransferred(address indexed previousGovernor, address indexed newGovernor);

    modifier onlyGovernor() {
        require(msg.sender == governorPosition, "Only the current Governor can call this function");
        _;
    }

    modifier nonReentrant() {
        require(!reentryStatusPosition, "Reentrant call");
        reentryStatusPosition = true;
        _;
        reentryStatusPosition = false;
    }

    constructor() {
        governorPosition = msg.sender;
    }

    function transferGovernance(address newGovernor) external onlyGovernor nonReentrant {
        _setPendingGovernor(newGovernor);
    }

    function claimGovernance() external nonReentrant {
        require(msg.sender == pendingGovernorPosition, "Only the pending Governor can claim governance");
        _changeGovernor(pendingGovernorPosition);
    }

    function _setGovernor(address newGovernor) internal {
        governorPosition = newGovernor;
    }

    function _setPendingGovernor(address newPendingGovernor) internal {
        pendingGovernorPosition = newPendingGovernor;
        emit PendingGovernorshipTransfer(governorPosition, newPendingGovernor);
    }

    function _changeGovernor(address newGovernor) internal {
        address previousGovernor = governorPosition;
        _setGovernor(newGovernor);
        pendingGovernorPosition = address(0);
        emit GovernorshipTransferred(previousGovernor, newGovernor);
    }

    function currentGovernor() external view returns (address) {
        return governorPosition;
    }

    function pendingGovernor() external view returns (address) {
        return pendingGovernorPosition;
    }

    function isReentrant() external view returns (bool) {
        return reentryStatusPosition;
    }
}
