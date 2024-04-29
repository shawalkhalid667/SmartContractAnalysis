// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DAORoles {
    // Role for operators within the DAO
    struct Role {
        mapping(address => bool) bearer;
    }
    
    // Role-related events
    event OperatorAdded(address indexed account);
    event OperatorRemoved(address indexed account);
    event DappAdded(address indexed account);
    event DappRemoved(address indexed account);
    
    // State variables
    Role private _operators;
    Role private _dapps;
    
    // Modifiers
    modifier onlyOperator() {
        require(isOperator(msg.sender), "DAORoles: caller is not an operator");
        _;
    }
    
    modifier onlyDapp() {
        require(isDapp(msg.sender), "DAORoles: caller is not a dapp");
        _;
    }
    
    // Functions
    function isOperator(address account) public view returns (bool) {
        return _operators.bearer[account];
    }
    
    function isDapp(address account) public view returns (bool) {
        return _dapps.bearer[account];
    }
    
    function addOperator(address account) public onlyOperator {
        _addOperator(account);
    }
    
    function addDapp(address account) public onlyOperator {
        _addDapp(account);
    }
    
    function removeOperator(address account) public onlyOperator {
        _removeOperator(account);
    }
    
    function removeDapp(address account) public onlyOperator {
        _removeDapp(account);
    }
    
    // Internal functions
    function _addOperator(address account) internal {
        _operators.bearer[account] = true;
        emit OperatorAdded(account);
    }
    
    function _addDapp(address account) internal {
        _dapps.bearer[account] = true;
        emit DappAdded(account);
    }
    
    function _removeOperator(address account) internal {
        _operators.bearer[account] = false;
        emit OperatorRemoved(account);
    }
    
    function _removeDapp(address account) internal {
        _dapps.bearer[account] = false;
        emit DappRemoved(account);
    }
}
