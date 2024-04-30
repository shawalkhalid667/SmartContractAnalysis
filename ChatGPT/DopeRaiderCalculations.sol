// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract DopeRaiderCalculations is Ownable {
    uint256 public bustRange;
    uint256 public bustCoefficient;
    uint256 public attackScalar;
    uint256 public defenseScalar;
    uint256 public earlyRaidScalar;
    uint256 public victimCoefficient;
    uint256 public raidRespectLimit;
    uint256 public seed;

    event ParametersUpdated(
        uint256 bustRange,
        uint256 bustCoefficient,
        uint256 attackScalar,
        uint256 defenseScalar,
        uint256 earlyRaidScalar,
        uint256 victimCoefficient,
        uint256 raidRespectLimit
    );

    constructor(
        address initialOwner,
        uint256 _bustRange,
        uint256 _bustCoefficient,
        uint256 _attackScalar,
        uint256 _defenseScalar,
        uint256 _earlyRaidScalar,
        uint256 _victimCoefficient,
        uint256 _raidRespectLimit,
        uint256 _seed
    ) Ownable(initialOwner) {
        bustRange = _bustRange;
        bustCoefficient = _bustCoefficient;
        attackScalar = _attackScalar;
        defenseScalar = _defenseScalar;
        earlyRaidScalar = _earlyRaidScalar;
        victimCoefficient = _victimCoefficient;
        raidRespectLimit = _raidRespectLimit;
        seed = _seed;
    }

    function setParameters(
        uint256 _bustRange,
        uint256 _bustCoefficient,
        uint256 _attackScalar,
        uint256 _defenseScalar,
        uint256 _earlyRaidScalar,
        uint256 _victimCoefficient,
        uint256 _raidRespectLimit
    ) external onlyOwner {
        bustRange = _bustRange;
        bustCoefficient = _bustCoefficient;
        attackScalar = _attackScalar;
        defenseScalar = _defenseScalar;
        earlyRaidScalar = _earlyRaidScalar;
        victimCoefficient = _victimCoefficient;
        raidRespectLimit = _raidRespectLimit;
        emit ParametersUpdated(
            _bustRange,
            _bustCoefficient,
            _attackScalar,
            _defenseScalar,
            _earlyRaidScalar,
            _victimCoefficient,
            _raidRespectLimit
        );
    }

    function _random() internal view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty, seed)));
    }

    function isRaided(uint256 attackerSkill, uint256 victimSkill, uint256 attackerRespect) external view returns (bool) {
        require(attackerSkill > 0 && victimSkill > 0, "Invalid skill level");
        require(attackerRespect >= raidRespectLimit, "Respect level too low");

        uint256 rand = _random();
        uint256 successChance = (attackerSkill * attackScalar) / (victimSkill * defenseScalar) * earlyRaidScalar;

        return rand % 100 < successChance;
    }

    function isBusted(uint256 playerSpeed) external view returns (bool) {
        require(playerSpeed > 0, "Invalid speed level");

        uint256 rand = _random();
        uint256 bustChance = (playerSpeed * bustCoefficient) / bustRange;

        return rand % 100 < bustChance;
    }
}
