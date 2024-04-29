
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Migrations {
    // The address of the contract's owner
    address public owner;
    // The last completed migration
    uint public last_completed_migration;

    // A modifier to restrict functions to only the contract owner
    modifier restricted() {
        require(
            msg.sender == owner,
            "This function is restricted to the contract's owner"
        );
        _;
    }

    // A constructor function that sets the initial owner to the sender
    // msg.sender is the address of the one who called the function (in this case the address where the contract is being deployed from)
    constructor() {
        owner = msg.sender;
    }

    // A function to set the last completed migration
    // restricted to the contract owner
    function setCompleted(uint completed) public restricted {
        last_completed_migration = completed;
    }

    // A function to upgrade the migration contract
    function upgrade(address new_address) public restricted {
        Migrations upgraded = Migrations(new_address);
        upgraded.setCompleted(last_completed_migration);
    }
}
