
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";

// Interface for the DateTimeAPI
interface DateTimeAPI {
    function getNow() external view returns (uint256);
}

contract EJackpot {
    using SafeMath for uint256;

    // Event emitted whenever a case is opened
    event CaseOpened(address indexed user, uint256 amount, uint256 prize);

    // Struct to hold case details
    struct Case {
        uint256 minPrize;
        uint256 maxPrize;
        uint256 probability;
    }

    // Arrays and mappings to store data
    Case[] public cases;
    mapping(address => uint256) public balances;
    mapping(uint256 => uint256) public dailyStats;

    // Referral system
    mapping(address => address) public referrers;
    uint256 public referralPercentage = 5;

    // Owner of the contract
    address public owner;

    // DateTimeAPI instance
    DateTimeAPI public dateTimeAPI;

    // Modifier to restrict calls from other contracts
    modifier notContract() {
        uint size;
        address addr = msg.sender;
        assembly { size := extcodesize(addr) }
        require(size == 0, "Contract calls not allowed");
        _;
    }

    // Constructor to initialize cases and probabilities
    constructor(DateTimeAPI _dateTimeAPI) {
        dateTimeAPI = _dateTimeAPI;
        owner = msg.sender;

        // Initialize cases with minPrize, maxPrize and probability
        cases.push(Case(10, 50, 50));
   
