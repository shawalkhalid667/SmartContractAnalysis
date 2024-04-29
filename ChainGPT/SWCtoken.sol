
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

// The Scanetchain contract inherits from the ERC20 contract
contract Scanetchain is ERC20 {
    // Using SafeMath for safe arithmetic operations to prevent overflow and underflow errors
    using SafeMath for uint256;

    // Token details
    string private constant NAME = "Scanetchain";
    string private constant SYMBOL = "SWC";
    uint8 private constant DECIMALS = 18;
    uint256 private constant INITIAL_TOTAL_SUPPLY = 1e9 * (10 ** uint256(DECIMALS)); // 1,000,000,000 SWC

    constructor() ERC20(NAME, SYMBOL) {
        // Upon deployment, the total supply of Scanetchain tokens is minted and allocated to the contract creator
        _mint(msg.sender, INITIAL_TOTAL_SUPPLY);
    }

    // Allows users to transfer tokens to a specified address
    function transfer(address _to, uint256 _value) public override returns (bool) {
        return super.transfer(_to, _value);
    }

    // Returns the total supply of Scanetchain tokens
    function totalSupply() public view override returns (uint256) {
        return super.totalSupply();
    }

    // Retrieves the balance of tokens for a given address
    function balanceOf(address _owner) public view override returns (uint256 balance) {
        return super.balanceOf(_owner);
    }

    // Allows token transfer on behalf of the token owner
    function transferFrom(address _from, address _to, uint256 _value) public override returns (bool) {
        return super.transferFrom(_from, _to, _value);
    }

    // Approves the spender to spend a specified amount of tokens on behalf of the owner
    function approve(address _spender, uint256 _value) public override returns (bool) {
        return super.approve(_spender, _value);
    }

    // Checks the remaining allowance that the owner has approved for the spender
    function allowance(address _owner, address _spender) public view override returns (uint256 remaining) {
        return super.allowance(_owner, _spender);
    }

    // Increases the allowed value for a spender to spend from the owner
    function increaseApproval(address _spender, uint256 _addedValue) public returns (bool) {
        return super.increaseAllowance(_spender, _addedValue);
    }

    // Decreases the allowed value for a spender to spend from the owner
    function decreaseApproval(address _spender, uint256 _subtractedValue) public returns (bool) {
        return super.decreaseAllowance(_spender, _subtractedValue);
    }
}
