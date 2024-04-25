// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;
library Fractions8 {
    struct Fraction8 {
        uint8 data;
    }

    // Create a proper fraction with nominator less than the denominator
    function createProperFraction8(uint8 nominator, uint8 denominator) internal pure returns (Fraction8 memory) {
        require(nominator < denominator, "Nominator must be less than denominator");
        require(denominator > 0, "Denominator cannot be zero");

        return Fraction8((nominator << 6) | denominator);
    }

    // Convert a fraction to its percent representation, rounding down
    function toPercent(Fraction8 memory fraction) internal pure returns (uint8) {
        return uint8((uint(fraction.data) * 100) / 64);
    }

    // Check if a fraction represents zero (nominator is zero)
    function isZero(Fraction8 memory fraction) internal pure returns (bool) {
        return getNominator(fraction) == 0;
    }

    // Check if a fraction represents one (nominator equals denominator)
    function isOne(Fraction8 memory fraction) internal pure returns (bool) {
        return getNominator(fraction) == getDenominator(fraction);
    }

    // Check if a fraction is proper (nominator less than denominator)
    function isProper(Fraction8 memory fraction) internal pure returns (bool) {
        return getNominator(fraction) < getDenominator(fraction);
    }

    // Extract the 2-bits fraction nominator
    function getNominator(Fraction8 memory fraction) internal pure returns (uint8) {
        return fraction.data >> 6;
    }

    // Extract the 6-bits fraction denominator
    function getDenominator(Fraction8 memory fraction) internal pure returns (uint8) {
        return fraction.data & 0x3F;
    }

    // Multiply a proper fraction by an integer with rounding down
    function multiplyByInteger(Fraction8 memory fraction, uint8 multiplier) internal pure returns (Fraction8 memory) {
        uint256 result = uint256(getNominator(fraction)) * uint256(multiplier);
        require(result <= type(uint8).max, "Multiplication result exceeds uint8 range");

        return createProperFraction8(uint8(result), getDenominator(fraction));
    }
}
