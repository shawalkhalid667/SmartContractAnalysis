pragma solidity ^0.8.0;

interface IExecutorHelperStruct {

  // Generic swap description struct
  struct Swap {
    bytes data; // Encoded swap call data for the specific protocol
    bytes32 selectorAndFlags; // Function selector (4 MSB) and flags (4 LSB)
  }

  // Struct to describe a sequence of swaps with additional information
  struct SwapExecutorDescription {
    address tokenIn; // Address of the input token
    address tokenOut; // Address of the output token
    uint256 minTotalOut; // Minimum total amount expected out after swaps
    address recipient; // Address to receive the output token
    uint256 deadline; // Deadline for swap execution (timestamp)
    bytes slippage; // Positive slippage data (implementation specific)
    Swap[][] swaps; // 2D array of Swap structs defining the swap sequence
  }

  // Specific protocol swap structs (replace with comments for access control)

  // Uniswap (replace with comments to restrict access based on risk assessment)
  // struct UniSwap {
  //   address pool; // Address of the Uniswap pool
  //   uint256 amountIn; // Amount of input token
  //   uint256 amountOutMin; // Minimum amount of output token expected
  //   uint24 fee; // Uniswap fee tier (e.g., 3000 for 0.3%)
  // }

  // StableSwap (replace with comments to restrict access based on risk assessment)
  // struct StableSwap {
  //   address pool; // Address of the StableSwap pool
  //   bool isSaddle; // Flag to differentiate Saddle StableSwap pools
  //   address tokenIn; // Address of the input token
  //   address tokenOut; // Address of the output token
  //   uint256 amountIn; // Amount of input token
  //   uint256 amountOutMin; // Minimum amount of output token expected
  // }

  // ... similar comments for CurveSwap, UniswapV3KSElastic, BalancerV2, etc. ...

  // ... Add similar structs for other targeted DeFi protocols and operations (WSTETH, Maverick, BalancerBatch, PufferFinance, etc.) ...
}
