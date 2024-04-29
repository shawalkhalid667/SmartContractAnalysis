// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Categorical Event Proxy Contract
contract CategoricalEventProxy {
    // constructor and implementation details are omitted for brevity
}

// Scalar Event Proxy Contract
contract ScalarEventProxy {
    // constructor and implementation details are omitted for brevity
}

// Categorical Event Contract
contract CategoricalEvent {
    // constructor and implementation details are omitted for brevity
}

// Scalar Event Contract
contract ScalarEvent {
    // constructor and implementation details are omitted for brevity
}

// Outcome Token Contract
contract OutcomeToken {
    // constructor and implementation details are omitted for brevity
}

contract EventFactory {
    // Mapping of created categorical events
    mapping(bytes32 => address) public categoricalEvents;
    // Mapping of created scalar events
    mapping(bytes32 => address) public scalarEvents;
    
    // Master copies of event and outcome token contracts
    address public categoricalEventMasterCopy;
    address public scalarEventMasterCopy;
    address public outcomeTokenMasterCopy;
    
    // Events emitted upon creating categorical and scalar events
    event CategoricalEventCreation(bytes32 indexed eventId, address indexed eventAddress);
    event ScalarEventCreation(bytes32 indexed eventId, address indexed eventAddress);

    // Constructor to initialize the contract with master copies of event contracts
    constructor(
        address _categoricalEventMasterCopy,
        address _scalarEventMasterCopy,
        address _outcomeTokenMasterCopy
    ) {
        categoricalEventMasterCopy = _categoricalEventMasterCopy;
        scalarEventMasterCopy = _scalarEventMasterCopy;
        outcomeTokenMasterCopy = _outcomeTokenMasterCopy;
    }
    
    // Function to create a new categorical event
    function createCategoricalEvent(
        address _collateralToken,
        address _oracle,
        uint256 _outcomeCount
    ) external {
        // Create a unique hash for the event
        bytes32 eventId = keccak256(abi.encodePacked(_collateralToken, _oracle, _outcomeCount, block.timestamp));
        // Create an instance of the categorical event contract using a proxy and master copy
        address eventAddress = address(new CategoricalEventProxy());
        // Store the event in the mapping
        categoricalEvents[eventId] = eventAddress;
        // Emit event creation event
        emit CategoricalEventCreation(eventId, eventAddress);
    }
    
    // Function to create a new scalar event
    function createScalarEvent(
        address _collateralToken,
        address _oracle,
        uint256 _lowerBound,
        uint256 _upperBound
    ) external {
        // Create a unique hash for the event
        bytes32 eventId = keccak256(abi.encodePacked(_collateralToken, _oracle, _lowerBound, _upperBound, block.timestamp));
        // Create an instance of the scalar event contract using a proxy and master copy
        address eventAddress = address(new ScalarEventProxy());
        // Store the event in the mapping
        scalarEvents[eventId] = eventAddress;
        // Emit event creation event
        emit ScalarEventCreation(eventId, eventAddress);
    }
}
