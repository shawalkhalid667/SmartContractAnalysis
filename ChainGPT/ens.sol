
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";

interface ENS {
    function setRecord(bytes32 node, address owner, address resolver, uint64 ttl) external;
    function setSubnodeRecord(bytes32 node, bytes32 label, address owner, address resolver, uint64 ttl) external;
    function setSubnodeOwner(bytes32 node, bytes32 label, address owner) external returns(bytes32);
    function setResolver(bytes32 node, address resolver) external;
    function setOwner(bytes32 node, address owner) external;
    function setTTL(bytes32 node, uint64 ttl) external;
    function owner(bytes32 node) external view returns (address);
    function resolver(bytes32 node) external view returns (address);
    function ttl(bytes32 node) external view returns (uint64);
    function recordExists(bytes32 node) external view returns (bool);
}

contract ENSInterface is AccessControl {
    bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");

    ENS public ens;

    event NewOwner(bytes32 indexed node, address indexed owner);
    event Transfer(bytes32 indexed node, address indexed owner);
    event NewResolver(bytes32 indexed node, address indexed resolver);
    event NewTTL(bytes32 indexed node, uint64 ttl);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    constructor(address _ens) {
        ens = ENS(_ens);
       grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function setRecord(bytes32 node, address owner, address resolver, uint64 ttl) public onlyRole(OPERATOR_ROLE) {
        ens.setRecord(node, owner, resolver, ttl);
        emit NewOwner(node, owner);
        emit NewResolver(node, resolver);
        emit NewTTL(node, ttl);
    }

    function setSubnodeRecord(bytes32 node, bytes32 label, address owner, address resolver, uint64 ttl) public onlyRole(OPERATOR_ROLE) {
        ens.setSubnodeRecord(node, label, owner, resolver, ttl);
        emit NewOwner(node, owner);
        emit NewResolver(node, resolver);
        emit NewTTL(node, ttl);
    }

    function setSubnodeOwner(bytes32 node, bytes32 label, address owner) public onlyRole(OPERATOR_ROLE) returns(bytes32) {
        ens.setSubnodeOwner(node, label, owner);
        emit NewOwner(node, owner);
        return node;
    }

    function setResolver(bytes32 node, address resolver) public onlyRole(OPERATOR_ROLE) {
        ens.setResolver(node, resolver);
        emit NewResolver(node, resolver);
    }

    function setOwner(bytes32 node, address owner) public onlyRole(OPERATOR_ROLE) {
        ens.setOwner(node, owner);
        emit NewOwner(node, owner);
    }

    function setTTL(bytes32 node, uint64 ttl) public onlyRole(OPERATOR_ROLE) {
        ens.setTTL(node, ttl);
        emit NewTTL(node, ttl);
    }

    function setApprovalForAll(address operator, bool approved) public {
        grantRole(OPERATOR_ROLE, operator);
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function isApprovedForAll(address owner, address operator) public view returns (bool) {
        return hasRole(OPERATOR_ROLE, operator);
    }

    function owner(bytes32 node) public view returns (address) {
        return ens.owner(node);
    }

    function resolver(bytes32 node) public view returns (address) {
        return ens.resolver(node);
    }

    function ttl(bytes32 node) public view returns (uint64) {
        return ens.ttl(node);
    }

    function recordExists(bytes32 node) public view returns (bool) {
        return ens.recordExists(node);
    }
}
