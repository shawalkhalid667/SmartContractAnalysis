
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Importing required OpenZeppelin contracts for Safe Math Operations and Address Checks
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Address.sol";

// IExecutorHelperStruct Interface
interface IExecutorHelperStruct {

    // Swap struct
    struct Swap {
        bytes data;
        bytes32 selectorAndFlags;
    }

    // SwapExecutorDescription struct
    struct SwapExecutorDescription {
        Swap[][] swaps;
        address inputToken;
        address outputToken;
        uint256 minTotalAmountOut;
        address recipient;
        uint256 deadline;
        bytes positiveSlippageData;
    }

    // UniSwap struct
    struct UniSwap {
        address pool;
        address tokenIn;
        address tokenOut;
        uint256 amountIn;
        uint256 amountOutMin;
        uint256 deadline;
        address to;
    }

    // StableSwap struct
    struct StableSwap {
        bool isSaddle;
        address pool;
        address tokenIn;
        address tokenOut;
        uint256 amountIn;
        uint256 minAmountOut;
    }

    // CurveSwap struct
    struct CurveSwap {
        address pool;
        int128 i;
        int128 j;
        uint256 dx;
        uint256 minDy;
    }

    // UniswapV3KSElastic struct
    struct UniswapV3KSElastic {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        uint256 amountIn;
        uint256 amountOutMinimum;
        uint160 sqrtPriceLimitX96;
    }

    // BalancerV2 struct
    struct BalancerV2 {
        address pool;
        address tokenIn;
        address tokenOut;
        uint256 amountIn;
        uint256 minAmountOut;
        uint256 maxPrice;
    }

    // WSTETH struct
    struct WSTETH {
        address stETH; // stETH token address
        uint256 amount; // amount of stETH to wrap
    }

    // Maverick struct
    struct Maverick {
        address tokenIn;
        address tokenOut;
        uint256 amountIn;
        uint256 minAmountOut;
        uint256 deadline;
    }

    // BalancerBatch struct
    struct BalancerBatch {
        address pool;
        address tokenIn;
        address tokenOut;
        uint256 totalAmountIn;
        uint256 minTotalAmountOut;
    }

    // PufferFinance struct
    struct PufferFinance {
        address tokenIn;
        address tokenOut;
        uint256 amountIn;
        uint256 minAmountOut;
        uint256 deadline;
    }
}
