
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library Fractions8 {
    // Define the maximum allowed values for the nominator and denominator
    uint8 constant MAX_NOMINATOR = 0b11000000; // 2 bits
    uint8 constant MAX_DENOMINATOR = 0b00111111; // 6 
    
    

    // Define a fraction as a uint8, with the higher 2 bits representing the nominator and the lower 6 bits representing the denominator
    struct Fraction {
        uint8 value;
    }

    // Create a proper fraction with nominator less than the denominator
    function createProperFraction8(uint8 nominator, uint8 denominator) internal pure returns (Fraction memory) {
        require(nominator < denominator, "Nominator must be less than denominator");
        require(nominator <= MAX_NOMINATOR, "Nominator exceeds maximum value");
        require(denominator <= MAX_DENOMINATOR, "Denominator exceeds maximum value");
        return Fraction((nominator << 6) | denominator);
    }

    // Convert a fraction to its percent representation, rounding down the value
    function toPercent(Fraction memory fraction) internal pure returns (uint8) {
        return (getNominator(fraction) * 100) / getDenominator(fraction);
    }

    // Check if a fraction represents zero (nominator is zero)
    function isZero(Fraction memory fraction) internal pure returns (bool) {
        return getNominator(fraction) == 0;
    }

    // Check if a fraction represents one (nominator equals denominator)
    function isOne(Fraction memory fraction) internal pure returns (bool) {
        return getNominator(fraction) == getDenominator(fraction);
    }

    // Check if a fraction is proper (nominator less than denominator)
    function isProper(Fraction memory fraction) internal pure returns (bool) {
        return getNominator(fraction) < getDenominator(fraction);
    }

    // Extract the 2-bits fraction nominator
    function getNominator(Fraction memory fraction) internal pure returns (uint8) {
        return fraction.value >> 6;
    }

    // Extract the 6-bits fraction denominator
    function getDenominator(Fraction memory fraction) internal pure returns (uint8) {
        return fraction.value & MAX_DENOMINATOR;
    }

    // Multiply a proper fraction by an integer with rounding down
    function multiplyByInteger(Fraction memory fraction, uint8 integer) internal pure returns (Fraction memory) {
        uint nominator = getNominator(fraction) * integer;
        require(nominator <= MAX_NOMINATOR, "Result exceeds maximum value for nominator");
        return createProperFraction8(uint8(nominator), getDenominator(fraction));
    }
}
