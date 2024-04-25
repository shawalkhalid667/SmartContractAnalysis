pragma solidity ^0.8.25;

contract SafeMathContract {

  // SafeMath functions for uint256
  function mul256(uint256 a, uint256 b) public pure returns (uint256) {
    return SafeMath.mul(a, b);
  }

  function div256(uint256 a, uint256 b) public pure returns (uint256) {
    return SafeMath.div(a, b);
  }

  function sub256(uint256 a, uint256 b) public pure returns (uint256) {
    return SafeMath.sub(a, b);
  }

  function add256(uint256 a, uint256 b) public pure returns (uint256) {
    return SafeMath.add(a, b);
  }

  // SafeMath functions for uint32
  function mul32(uint32 a, uint32 b) public pure returns (uint32) {
    return SafeMath32.mul(a, b);
  }

  function div32(uint32 a, uint32 b) public pure returns (uint32) {
    return SafeMath32.div(a, b);
  }

  function sub32(uint32 a, uint32 b) public pure returns (uint32) {
    return SafeMath32.sub(a, b);
  }

  function add32(uint32 a, uint32 b) public pure returns (uint32) {
    return SafeMath32.add(a, b);
  }

  // SafeMath functions for uint16
  function mul16(uint16 a, uint16 b) public pure returns (uint16) {
    return SafeMath16.mul(a, b);
  }

  function div16(uint16 a, uint16 b) public pure returns (uint16) {
    return SafeMath16.div(a, b);
  }

  function sub16(uint16 a, uint16 b) public pure returns (uint16) {
    return SafeMath16.sub(a, b);
  }

  function add16(uint16 a, uint16 b) public pure returns (uint16) {
    return SafeMath16.add(a, b);
  }
}
