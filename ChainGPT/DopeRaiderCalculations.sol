
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract DopeRaiderCalculations is Ownable {
    using SafeMath for uint256;

    // Configuration parameters
    uint256 public bustRange;
    uint256 public bustCoefficient;
    uint256 public attackScalar;
    uint256 public defenseScalar;
    uint256 public earlyRaidScalar;
    uint256 public victimCoefficient;
    uint256 public raidRespectLimit;

    constructor() {
        // Initialize parameters as required
        bustRange = 100;
        bustCoefficient = 2;
        attackScalar = 1;
        defenseScalar = 1;
        earlyRaidScalar = 1;
        victimCoefficient = 1;
        raidRespectLimit = 100;
    }

    // Configuration functions
    function setBustRange(uint256 _bustRange) public onlyOwner {
        bustRange = _bustRange;
    }

    function setBustCoefficient(uint256 _bustCoefficient) public onlyOwner {
        bustCoefficient = _bustCoefficient;
    }

    function setAttackScalar(uint256 _attackScalar) public onlyOwner {
        attackScalar = _attackScalar;
    }

    function setDefenseScalar(uint256 _defenseScalar) public onlyOwner {
        defenseScalar = _defenseScalar;
    }

    function setEarlyRaidScalar(uint256 _earlyRaidScalar) public onlyOwner {
        earlyRaidScalar = _earlyRaidScalar;
    }

    function setVictimCoefficient(uint256 _victimCoefficient) public onlyOwner {
        victimCoefficient = _victimCoefficient;
    }

    function setRaidRespectLimit(uint256 _raidRespectLimit) public onlyOwner {
        raidRespectLimit = _raidRespectLimit;
    }

    // Raiding mechanics
    function isRaided(uint256 attackerSkill, uint256 victimSkill, uint256 respect) public view returns (bool) {
        uint256 raidSuccessChance = (attackerSkill.mul(attackScalar)).div(victimSkill.mul(defenseScalar));
        return respect <= raidRespectLimit && raidSuccessChance > random();
    }

    // Busting mechanics
    function isBusted(uint256 speedSkill) public view returns (bool) {
        uint256 bustChance = speedSkill.mul(bustCoefficient);
        return bustChance > random();
    }

    // Pseudo-random number generator
    function random() private view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(block.difficulty, block.timestamp)));
    }
}
