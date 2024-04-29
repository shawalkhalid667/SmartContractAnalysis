pragma solidity ^0.8.0;

import "@openzeppelin/contracts/ownership/Ownable.sol";
import "@openzeppelin/contracts/access/Roles.sol";

/**
 * @title DAORoles
 * @author Vittorio Minacori (https://github.com/vittominacori)
 * @dev It identifies the DAO roles
 */
contract DAORoles is Ownable {
    using Roles for Roles.Role;

    event OperatorAdded(address indexed account);
    event OperatorRemoved(address indexed account);

    event DappAdded(address indexed account);
    event DappRemoved(address indexed account);

    Roles.Role private _operators;
    Roles.Role private _dapps;

    constructor () internal {} // solhint-disable-line no-empty-blocks

    modifier onlyOperator() {
        require(isOperator(msg.sender));
        _;
    }

    modifier onlyDapp() {
        require(isDapp(msg.sender));
        _;
    }

    /**
     * @dev Check if an address has the `operator` role
     * @param account Address you want to check
     */
    function isOperator(address account) public view returns (bool) {
        return _operators.has(account);
    }

    /**
     * @dev Check if an address has the `dapp` role
     * @param account Address you want to check
     */
    function isDapp(address account) public view returns (bool) {
        return _dapps.has(account);
    }

    /**
     * @dev Add the `operator` role from address
     * @param account Address you want to add role
     */
    function addOperator(address account) public onlyOwner {
        _addOperator(account);
    }

    /**
     * @dev Add the `dapp` role from address
     * @param account Address you want to add role
     */
    function addDapp(address account) public onlyOperator {
        _addDapp(account);
    }

    /**
     * @dev Remove the `operator` role from address
     * @param account Address you want to remove role
     */
    function removeOperator(address account) public onlyOwner {
        _removeOperator(account);
    }

    /**
     * @dev Remove the `operator` role from address
     * @param account Address you want to remove role
     */
    function removeDapp(address account) public onlyOperator {
        _removeDapp(account);
    }

    function _addOperator(address account) internal {
        _operators.add(account);
        emit OperatorAdded(account);
    }

    function _addDapp(address account) internal {
        _dapps.add(account);
        emit DappAdded(account);
    }

    function _removeOperator(address account) internal {
        _operators.remove(account);
        emit OperatorRemoved(account);
    }

    function _removeDapp(address account) internal {
        _dapps.remove(account);
        emit DappRemoved(account);
    }
}
