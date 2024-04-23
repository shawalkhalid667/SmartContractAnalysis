// SPDX-License-Identifier: Apache-2.0
// Copyright 2022 ZeroEx Intl.

pragma solidity ^0.8.19;

import "./SecurityCouncil.sol";
import "./ZeroExTimelock.sol";
import "@openzeppelin/contracts/governance/Governor.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorSettings.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorCountingSimple.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorVotes.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorTimelockControl.sol";

contract ZeroExProtocolGovernor is SecurityCouncil, Governor, GovernorSettings, GovernorCountingSimple, GovernorVotes, GovernorTimelockControl {

    constructor(IVotes _token, ZeroExTimelock _timelock, address _securityCouncil)
        Governor("ZeroExProtocolGovernor")
        GovernorSettings(_timelock, 2 days, 3 days)
        GovernorVotes(_token)
        GovernorTimelockControl(_timelock)
        SecurityCouncil(_securityCouncil)
    {}

    // Quorum is 1% of the total supply
    function quorum(uint256 blockNumber) public view override returns (uint256) {
        return totalSupply(blockNumber) / 100;
    }

    // This function is used to check if the contract supports a specific interface
    function supportsInterface(bytes4 interfaceId) public view override(Governor, IERC165) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    // Override for proposal threshold, requiring proposer to hold at least 2% of total supply
    function proposalThreshold() public view override returns (uint256) {
        return totalSupply(block.number) / 50;
    }

    // Function to create a proposal
    function propose(address[] memory targets, uint256[] memory values, string[] memory descriptions, bytes[] memory calldatas, string memory description)
        public override returns (uint256 proposalId)
    {
        // Only security council can propose
        require(msg.sender == securityCouncil, "Only security council can propose");
        return super.propose(targets, values, descriptions, calldatas, description);
    }

    // Function to cancel a proposal
    function cancel(uint256 proposalId) public override returns (uint256) {
        // Only security council can cancel
        require(msg.sender == securityCouncil, "Only security council can cancel");
        return super.cancel(proposalId);
    }

    // Function to execute a proposal
    function execute(uint256 proposalId) public payable override {
        // Only security council can execute
        require(msg.sender == securityCouncil, "Only security council can execute");
        super.execute(proposalId);
    }

    // Function to queue a proposal
    function queue(uint256 proposalId) public override {
        // Only security council can queue
        require(msg.sender == securityCouncil, "Only security council can queue");
        super.queue(proposalId);
    }
}
