pragma solidity ^0.8.19;

// DopeRaider Calculations Contract V3
// by gasmasters.io
// contact: team@doperaider.com

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() public {
    owner = msg.sender;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}


contract DopeRaiderCalculations is Ownable {

 // configuration parameters
 // busting
 uint256 public bustRange = 10;
 uint64  public bustCoefficient = 5;


  uint64  public attS = 10; // attack zone scalar
  uint64  public defS = 5; // defense zone scalar

  bool public wasRaidSuccess  = false;


  uint64 public earlyRaidScalar = 5;
  uint64 public earlyRaidCoefVictim = 2;

  uint64 public raidRespectLimit  = 150;

  function isRaided(uint16 _respectAttacker, uint16 _respectVictim, uint16 _attackSkill , uint16 _defenseSkill) public returns (bool raided) {

      if ((_respectAttacker>earlyRaidScalar+(earlyRaidCoefVictim*_respectVictim)) && _respectVictim < raidRespectLimit) {
        wasRaidSuccess = false;
        return false;
      }

    uint64 attackZone  =  (attS + _attackSkill + _defenseSkill);
    uint64 result = random(attackZone);
    uint64 defenseZone = ( defS + _defenseSkill);

      if (result>defenseZone){
          wasRaidSuccess = true;
          return true;
      }
      wasRaidSuccess = false;
      return false;
  }

    // chance of busted based on speed skill
    function isBusted(uint16 _speedSkill) public returns (bool busted) {
        uint64 bustChance=random(50+(bustCoefficient*_speedSkill));
        if (bustChance<=bustRange){
        return true;
        }
        return false;
    }


    function setBustRange(uint256 _range) public onlyOwner{
        bustRange = _range;
    }
    // pseudo random - but does that matter?
    uint64 private seed = 0;
    function setRandomSeed(uint64 _seed) public onlyOwner{
        seed = _seed;
    }
    function random(uint64 upper) internal returns (uint64 randomNumber) {
        seed = uint64(keccak256(keccak256(block.blockhash(block.number-1), seed), now));
        return seed % upper;
    }

    function setEarylRaidScaler(uint64 _v) public onlyOwner{
        earlyRaidScalar = _v;
    }

    function setEarylRaidCoefVictim(uint64 _v) public onlyOwner{
        earlyRaidCoefVictim = _v;
    }

    function setRaidRespectLimit(uint64 _v) public onlyOwner{
        raidRespectLimit = _v;
    }

    function setAttackScalar(uint64 _v) public onlyOwner{
        attS = _v;
    }
    function setDefenseScalar(uint64 _v) public onlyOwner{
        defS = _v;
    }
}
