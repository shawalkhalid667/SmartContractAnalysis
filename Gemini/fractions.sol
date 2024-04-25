pragma solidity ^0.8.0;

library Fractions8 {
  // Define the bit positions for nominator and denominator
  uint8 constant private NOMINATOR_MASK = 0xC0; // 11000000
  uint8 constant private DENOMINATOR_MASK = 0x3F; // 00111111

  // Error for invalid fractions
  error InvalidFraction();

  // Error for division by zero
  error DivisionByZero();

  // Create a proper fraction with nominator less than denominator
  function createProperFraction8(uint8 numerator, uint8 denominator) public pure returns (uint8) {
    if (numerator >= denominator) {
      revert InvalidFraction();
    }
    return (numerator << 6) | denominator;
  }

  // Convert a fraction to its percent representation (rounding down)
  function toPercent(uint8 fraction) public pure returns (uint8) {
    return fraction * 100 / getDenominator(fraction);
  }

  // Check if a fraction represents zero
  function isZero(uint8 fraction) public pure returns (bool) {
    return getNominator(fraction) == 0;
  }

  // Check if a fraction represents one
  function isOne(uint8 fraction) public pure returns (bool) {
    return getNominator(fraction) == getDenominator(fraction);
  }

  // Check if a fraction is proper (nominator less than denominator)
  function isProper(uint8 fraction) public pure returns (bool) {
    return getNominator(fraction) < getDenominator(fraction);
  }

  // Extract the 2-bits fraction nominator
  function getNominator(uint8 fraction) public pure returns (uint8) {
    return (fraction & NOMINATOR_MASK) >> 6;
  }

  // Extract the 6-bits fraction denominator
  function getDenominator(uint8 fraction) public pure returns (uint8) {
    return fraction & DENOMINATOR_MASK;
  }

  // Multiply a proper fraction by an integer with rounding down
  function multiplyByInteger(uint8 fraction, uint8 factor) public pure returns (uint8) {
    if (!isProper(fraction)) {
      revert InvalidFraction();
    }
    uint16 product = uint16(getNominator(fraction)) * factor;
    // Check for overflow
    if (product > 2**64 - 1) {
      revert("Multiplication Overflow");
    }
    // Round down by dividing by denominator and discarding remainder
    return uint8(product / getDenominator(fraction));
  }
}
