
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title GameMath
 * @dev Comprehensive SafeMath library in Ethereum Solidity for secure and accurate mathematical operations within smart contracts.
 * This library includes functions for safe integer division, multiplication, addition, and subtraction, 
 * accompanied by square root calculation, squaring, and exponentiation features.
 */
library GameMath {
    /**
     * @dev Returns the division of two unsigned integers, truncating the quotient.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "GameMath: division by zero");
        uint256 c = a / b;
        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverts on overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "GameMath: multiplication overflow");
        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "GameMath: subtraction overflow");
        uint256 c = a - b;
        return c;
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverts on overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "GameMath: addition overflow");
        return c;
    }

    /**
     * @dev Returns the square root of a number.
     */
    function sqrt(uint256 x) internal pure returns (uint256 y) {
        uint256 z = (x + 1) / 2;
        y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
    }

    /**
     * @dev Returns the square of a number.
     */
    function sq(uint256 x) internal pure returns (uint256) {
        return mul(x, x);
    }

    /**
     * @dev Raises x to the power of n.
     */
    function pwr(uint256 x, uint256 n) internal pure returns (uint256) {
        if (x==0) return 0;
        if (n==0) return 1;
        uint256 z = x;
        for (uint256 i = 1; i < n; i++) {
            z = mul(z, x);
        }
        return z;
    }
}
