
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

//This is a simple ERC20 token contract, without any imports.

contract SimpleToken {
    // Mapping that stores the balance of each address
    mapping (address => uint256) public balanceOf;

    // The name of the token
    string public name;

    // The symbol of the token
    string public symbol;

    // The total supply of the tokens
    uint256 public totalSupply;

    // Event that is emitted when a transfer has occurred
    event Transfer(address indexed from, address indexed to, uint256 value);

    // Initializes the contract with an initial supply of tokens
    constructor(uint256 initialSupply, string memory tokenName, string memory tokenSymbol) {
        totalSupply = initialSupply;
        balanceOf[msg.sender] = initialSupply;
        name = tokenName;
        symbol = tokenSymbol;
    }

    // Function to transfer tokens from one address to another
    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value, "Insufficient balance");
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }
}
