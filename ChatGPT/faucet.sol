// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Migrations {
    address public owner;
    uint public last_completed_migration;

    modifier restricted() {
        require(msg.sender == owner, "Restricted: Only owner can call this function");
        _;
    }

    event MigrationCompleted(uint completedStep);
    event ContractUpgraded(address newAddress);

    constructor() {
        owner = msg.sender;
    }

    function setCompleted(uint completed) public restricted {
        last_completed_migration = completed;
        emit MigrationCompleted(completed);
    }

    function upgrade(address newAddress) public restricted {
        Migrations upgraded = Migrations(newAddress);
        upgraded.setCompleted(last_completed_migration);
        emit ContractUpgraded(newAddress);
    }
}
