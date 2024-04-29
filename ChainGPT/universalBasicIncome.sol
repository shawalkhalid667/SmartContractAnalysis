
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

// Assuming the HumanityRegistry contract has a isRegistered function to check if an address is registered
interface IHumanityRegistry {
    function isRegistered(address) external view returns (bool);
}

contract UniversalBasicIncome {
    using SafeMath for uint256;

    IHumanityRegistry public registry;
    IERC20 public dai;

    uint256 public constant MONTHLY_INCOME = 1000 * (10 ** 18); // Assuming 1000 DAI Tokens
    uint256 public constant INCOME_PER_SECOND = MONTHLY_INCOME / 30 days;

    mapping(address => uint256) public claimTimes;

    constructor(IHumanityRegistry _registry, IERC20 _dai) {
        registry = _registry;
        dai = _dai;
    }

    function claim() external {
        require(registry.isRegistered(msg.sender), "Only registered humans can claim UBI");

        uint256 lastClaimTime = claimTimes[msg.sender];
        uint256 currentTime = block.timestamp;

        uint256 income;

        if (lastClaimTime == 0) {
            income = MONTHLY_INCOME;
        } else {
            uint256 timeElapsed = currentTime.sub(lastClaimTime);
            income = timeElapsed.mul(INCOME_PER_SECOND);
        }

        uint256 daiBalance = dai.balanceOf(address(this));

        if (income > daiBalance) {
            income = daiBalance;
        }

        claimTimes[msg.sender] = currentTime;
        dai.transfer(msg.sender, income);
    }
}
