// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ENSInterface {
    // Events
    event NewOwner(bytes32 indexed node, address indexed owner);
    event Transfer(bytes32 indexed node, address indexed owner);
    event NewResolver(bytes32 indexed node, address indexed resolver);
    event NewTTL(bytes32 indexed node, uint64 ttl);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    // Record Management Functions
    function setRecord(bytes32 node, address owner, address resolver, uint64 ttl) external;
    function setSubnodeRecord(bytes32 node, bytes32 label, address owner, address resolver, uint64 ttl) external;
    function setSubnodeOwner(bytes32 node, bytes32 label, address owner) external;
    function setResolver(bytes32 node, address resolver) external;
    function setOwner(bytes32 node, address owner) external;
    function setTTL(bytes32 node, uint64 ttl) external;

    // Approval Management
    function setApprovalForAll(address operator, bool approved) external;

    // Node Information Queries
    function owner(bytes32 node) external view returns (address);
    function resolver(bytes32 node) external view returns (address);
    function ttl(bytes32 node) external view returns (uint64);
    function recordExists(bytes32 node) external view returns (bool);

    // Approval Check Functionality
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}
