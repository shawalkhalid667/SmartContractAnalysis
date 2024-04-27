
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Migrations {
    // Define the contract owner
    address public owner;

    // This will keep track of the last completed migration
    uint public last_completed_migration;

    // This modifier restricts function execution to the contract owner
    modifier restricted() {
        require(msg.sender == owner, "This function is restricted to the contract's owner");
        _;
    }

    // A constructor function that sets the contract owner as the address deploying the contract
    constructor() {
        owner = msg.sender;
    }

    // A function to mark a migration as completed. Can only be executed by the contract owner.
    function setCompleted(uint completed) public restricted {
        last_completed_migration = completed;
    }

    // A function to upgrade the contract. Can only be executed by the contract owner.
    function upgrade(address new_address) public restricted {
        Migrations upgraded = Migrations(new_address);
        upgraded.setCompleted(last_completed_migration);
    }
}
