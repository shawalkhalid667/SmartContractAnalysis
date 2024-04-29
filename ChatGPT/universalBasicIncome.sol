// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract UniversalBasicIncome is ReentrancyGuard {
    using SafeMath for uint256;

    // Address of the HumanityRegistry contract
    address public humanityRegistry;
    
    // Address of the Dai token contract
    address public daiToken;
    
    // Constants
    uint256 constant MONTHLY_INCOME = 100 * 10**18; // 100 Dai tokens
    uint256 constant INCOME_PER_SECOND = MONTHLY_INCOME / 30 / 24 / 60 / 60; // Monthly income divided by seconds in a month
    
    // Mapping to track the timestamp of the last claim for each human address
    mapping(address => uint256) public claimTimes;

    constructor(address _humanityRegistry, address _daiToken) {
        humanityRegistry = _humanityRegistry;
        daiToken = _daiToken;
    }

    // Function to allow registered humans to claim their UBI income
    function claim() external nonReentrant {
        require(isRegistered(msg.sender), "Not registered in HumanityRegistry");
        
        uint256 lastClaimTime = claimTimes[msg.sender];
        uint256 currentTime = block.timestamp;
        uint256 elapsedTime = currentTime.sub(lastClaimTime);
        
        uint256 earnedIncome = elapsedTime.mul(INCOME_PER_SECOND);
        
        require(earnedIncome > 0, "Income must be greater than zero");
        
        claimTimes[msg.sender] = currentTime;
        
        IERC20(daiToken).transfer(msg.sender, earnedIncome);
    }

    // Internal function to check if an address is registered in the HumanityRegistry contract
    function isRegistered(address _human) internal view returns (bool) {
        // Implement the logic to check registration status in HumanityRegistry contract
        return true; // Placeholder logic, replace with actual implementation
    }
}
