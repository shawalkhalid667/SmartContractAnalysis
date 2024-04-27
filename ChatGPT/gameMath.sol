// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `require` statement to revert when dividing by zero. This function will
     * throw an exception when `b` is zero. In Solidity, division by zero is
     * flagged by the Solidity compiler as invalid opcode indicating the
     * division operation throwing an exception.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    /**
     * @dev Returns the square root of a given unsigned integer.
     *
     * Note: This function uses a simple numerical approximation technique
     * and may not always provide exact results.
     */
    function sqrt(uint256 x) internal pure returns (uint256) {
        if (x == 0) return 0;
        uint256 z = (x + 1) / 2;
        uint256 y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
        return y;
    }

    /**
     * @dev Returns the square of a given unsigned integer.
     */
    function sq(uint256 x) internal pure returns (uint256) {
        return x * x;
    }

    /**
     * @dev Returns `base` raised to the power of `exp`.
     *
     * Requirements:
     *
     * - `exp` must be non-negative.
     */
    function pwr(uint256 base, uint256 exp) internal pure returns (uint256) {
        if (exp == 0) return 1;
        if (base == 0) return 0;

        uint256 result = 1;
        for (uint256 i = 0; i < exp; i++) {
            result *= base;
        }
        return result;
    }
}
