
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";

// Contract to manage roles within a DAO
contract DAORoles is AccessControl {
    // Define the roles
    bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");
    bytes32 public constant DAPP_ROLE = keccak256("DAPP_ROLE");

    // Define the events
    event OperatorAdded(address indexed operator);
    event OperatorRemoved(address indexed operator);
    event DappAdded(address indexed dapp);
    event DappRemoved(address indexed dapp);

    constructor() {
        // Grant the contract deployer the initial roles
        _setupRole(OPERATOR_ROLE, msg.sender);
        _setupRole(DAPP_ROLE, msg.sender);
    }

    // Modifier to restrict access to only operators
    modifier onlyOperator() {
        require(hasRole(OPERATOR_ROLE, msg.sender), "DAORoles: caller is not an operator");
        _;
    }

    // Modifier to restrict access to only dapps
    modifier onlyDapp() {
        require(hasRole(DAPP_ROLE, msg.sender), "DAORoles: caller is not a dapp");
        _;
    }

    // Check if an address is an operator
    function isOperator(address account) public view returns (bool) {
        return hasRole(OPERATOR_ROLE, account);
    }

    // Check if an address is a dapp
    function isDapp(address account) public view returns (bool) {
        return hasRole(DAPP_ROLE, account);
    }

    // Add an operator
    function addOperator(address account) public onlyOperator {
        grantRole(OPERATOR_ROLE, account);
        emit OperatorAdded(account);
    }

    // Add a dapp
    function addDapp(address account) public onlyOperator {
        grantRole(DAPP_ROLE, account);
        emit DappAdded(account);
    }

    // Remove an operator
    function removeOperator(address account) public onlyOperator {
        revokeRole(OPERATOR_ROLE, account);
        emit OperatorRemoved(account);
    }

    // Remove a dapp
    function removeDapp(address account) public onlyOperator {
        revokeRole(DAPP_ROLE, account);
        emit DappRemoved(account);
    }
}
