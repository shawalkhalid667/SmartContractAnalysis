
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Importing OpenZeppelin's Ownable Contract to manage contract ownership


contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// Haltable contract, inheriting from the Ownable contract
contract Haltable is Ownable {
    // State variable indicating the halted state of the contract
    bool private halted;

    // Event for logging the halt
    event Halted();

    // Event for logging the unhalt
    event Unhalted();

    // Modifier to make a function callable only when the contract is not halted.
    modifier stopInEmergency {
        require(!halted, "Contract is halted");
        _;
    }

    // Modifier to make a function callable only when the contract is halted.
    modifier onlyInEmergency {
        require(halted, "Contract is not halted");
        _;
    }

    // Modifier to allow owner to call a function even when the contract is halted
    modifier stopNonOwnersInEmergency {
        if (!owner()) {
            require(!halted, "Contract is halted");
        }
        _;
    }

    // Called by the owner on emergency, triggers stopped state
    function halt() public onlyOwner {
        halted = true;
        emit Halted();
    }

    // Called by the owner on end of emergency, returns to normal state
    function unhalt() public onlyOwner onlyInEmergency {
        halted = false;
        emit Unhalted();
    }
}
