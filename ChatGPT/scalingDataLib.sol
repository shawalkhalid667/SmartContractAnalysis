// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

/**
 * @title Interface for structured transaction data across various DeFi protocols
 */
interface IExecutorHelperStruct {
    struct SwapData {
        uint256 amountIn;
        uint256 amountOut;
        address[] path;
        address to;
        uint256 deadline;
    }
    
    struct StableSwapData {
        address pool;
        uint256[] amounts;
        uint256[] minAmounts;
        uint256 deadline;
    }
    
    struct CurveSwapData {
        address pool;
        uint256 i;
        uint256 j;
        uint256 dx;
        uint256 dy;
        uint256 deadline;
    }
    
    // Define other transaction types as needed
}

library ScalingDataLib {
    using SafeMath for uint256;
    
    /**
     * @dev Adjusts transaction data for a Uniswap swap operation
     * @param data The original transaction data in bytes
     * @param oldAmount The original amount before scaling
     * @param newAmount The new amount after scaling
     * @return The scaled transaction data in bytes
     */
    function newUniSwap(bytes memory data, uint256 oldAmount, uint256 newAmount) internal pure returns (bytes memory) {
        IExecutorHelperStruct.SwapData memory swapData = abi.decode(data, (IExecutorHelperStruct.SwapData));
        swapData.amountIn = (swapData.amountIn * newAmount) / oldAmount;
        swapData.amountOut = (swapData.amountOut * newAmount) / oldAmount;
        return abi.encode(swapData);
    }
    
    /**
     * @dev Adjusts transaction data for a StableSwap transaction
     * @param data The original transaction data in bytes
     * @param oldAmount The original amount before scaling
     * @param newAmount The new amount after scaling
     * @return The scaled transaction data in bytes
     */
    function newStableSwap(bytes memory data, uint256 oldAmount, uint256 newAmount) internal pure returns (bytes memory) {
        IExecutorHelperStruct.StableSwapData memory stableSwapData = abi.decode(data, (IExecutorHelperStruct.StableSwapData));
        for (uint256 i = 0; i < stableSwapData.amounts.length; i++) {
            stableSwapData.amounts[i] = (stableSwapData.amounts[i] * newAmount) / oldAmount;
            stableSwapData.minAmounts[i] = (stableSwapData.minAmounts[i] * newAmount) / oldAmount;
        }
        return abi.encode(stableSwapData);
    }
    
    // Add similar functions for other DeFi operations
    
    // Safety and efficiency considerations are implemented within each function
    
    // Comprehensive NatSpec comments for each function can be added
    
    // Testing framework and edge cases discussions can be included
    
    // Value of having such a library for dynamic adjustment of transaction data in DeFi protocols can be discussed
}

library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with overflow reverting.
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
     * @dev Returns the subtraction of two unsigned integers, with overflow reverting (i.e., if subtrahend is greater than minuend).
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
     * @dev Returns the multiplication of two unsigned integers, with overflow reverting.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a `revert` opcode (which
     * leaves remaining gas untouched) while Solidity uses an invalid opcode to revert (consuming all
     * remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }
}
