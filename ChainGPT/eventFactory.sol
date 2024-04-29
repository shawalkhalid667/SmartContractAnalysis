
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/proxy/Clones.sol";

// EventFactory contract
contract EventFactory {
    // State variables
    mapping(bytes32 => address) public categoricalEvents;
    mapping(bytes32 => address) public scalarEvents;
    address public categoricalEventMasterCopy;
    address public scalarEventMasterCopy;
    address public outcomeTokenMasterCopy;

    // Events
    event CategoricalEventCreation(bytes32 indexed eventId, address indexed eventAddress);
    event ScalarEventCreation(bytes32 indexed eventId, address indexed eventAddress);

    // Constructor
    constructor(address _categoricalEventMasterCopy, address _scalarEventMasterCopy, address _outcomeTokenMasterCopy) {
        categoricalEventMasterCopy = _categoricalEventMasterCopy;
        scalarEventMasterCopy = _scalarEventMasterCopy;
        outcomeTokenMasterCopy = _outcomeTokenMasterCopy;
    }

    // Function to create a new categorical event
    function createCategoricalEvent(address collateralToken, address oracle, uint outcomeCount) public returns (address) {
        bytes32 eventId = keccak256(abi.encodePacked(collateralToken, oracle, outcomeCount));
        address clone = Clones.clone(categoricalEventMasterCopy);
        categoricalEvents[eventId] = clone;
        emit CategoricalEventCreation(eventId, clone);
        return clone;
    }

    // Function to create a new scalar event
    function createScalarEvent(address collateralToken, address oracle, int lowerBound, int upperBound) public returns (address) {
        bytes32 eventId = keccak256(abi.encodePacked(collateralToken, oracle, lowerBound, upperBound));
        address clone = Clones.clone(scalarEventMasterCopy);
        scalarEvents[eventId] = clone;
        emit ScalarEventCreation(eventId, clone);
        return clone;
    }
}
