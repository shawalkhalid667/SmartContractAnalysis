
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Migrations {
    address public owner; // The address of the owner of the contract
    uint public last_completed_migration; // Unsigned integer to store the completion status of the last migration

    // Modifier to ensure that only the contract owner can execute certain functions
    modifier restricted() {
        require(
            msg.sender == owner,
            "This function is restricted to the contract's owner"
        );
        _;
    }

    // Constructor function to initialize the contract by setting the deployer's address as the owner
    constructor() {
        owner = msg.sender;
    }

    // Function to allow the owner to set the completion status of a migration
    function setCompleted(uint completed) public restricted {
        last_completed_migration = completed;
    }

    // Function to allow the owner to upgrade to a new address by transferring the completion status of the last migration
    function upgrade(address new_address) public restricted {
        Migrations upgraded = Migrations(new_address);
        upgraded.setCompleted(last_completed_migration);
    }
}
