
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Governable {
    // Storage position for the current Governor.
    address private _governor;
    // Storage position for the pending Governor.
    address private _pendingGovernor;
    // Storage position for reentrant status.
    bool private _reentryStatus;

    // Emitted when governance transfer is initiated.
    event PendingGovernorshipTransfer(address indexed from, address indexed to);
    // Emitted when governance transfer is completed.
    event GovernorshipTransferred(address indexed from, address indexed to);

    // Modifier to restrict a function to be called only by the current Governor.
    modifier onlyGovernor() {
        require(msg.sender == _governor, "Caller is not the governor");
        _;
    }

    // Modifier to prevent reentrancy by managing a reentry status during function execution.
    modifier nonReentrant() {
        require(!_reentryStatus, "Reentrant call");
        _reentryStatus = true;
        _;
        _reentryStatus = false;
    }

    // The initial Governor is set to the deployer (contract creator).
    constructor() {
        _setGovernor(msg.sender);
    }

    // Allows the current Governor to transfer governance to a new address.
    function transferGovernance(address newGovernor) public onlyGovernor nonReentrant {
        require(newGovernor != address(0), "New governor is the zero address");
        _setPendingGovernor(newGovernor);
        emit PendingGovernorshipTransfer(_governor, newGovernor);
    }

    // Allows the pending Governor to claim governance after it has been transferred.
    function claimGovernance() public nonReentrant {
        require(msg.sender == _pendingGovernor, "Not the pending governor");
        _changeGovernor(_pendingGovernor);
        emit GovernorshipTransferred(_governor, _pendingGovernor);
    }

    // Internal function to set the new Governor.
    function _setGovernor(address newGovernor) internal {
        _governor = newGovernor;
    }

    // Internal function to set the pending Governor.
    function _setPendingGovernor(address newGovernor) internal {
        _pendingGovernor = newGovernor;
    }

    // Internal function to change the Governor to the new address.
    function _changeGovernor(address newGovernor) internal {
        _setGovernor(newGovernor);
        _setPendingGovernor(address(0));
    }
}
