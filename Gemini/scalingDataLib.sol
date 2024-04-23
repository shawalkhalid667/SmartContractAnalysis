// SPDX-License-Identifier: MIT

pragma solidity ^0.8.25;

// Interface definition assumed to exist elsewhere
interface IExecutorHelperStruct {
  struct UniSwap {
    address tokenIn;
    address tokenOut;
    uint256 amountIn;
    uint256 amountOutMin;
  }
}

library ScalingDataLib {

  function newUniSwap(bytes calldata data, uint256 oldAmount, uint256 newAmount) public pure returns (bytes memory) {
    // 1. Decode data into UniSwap struct
    IExecutorHelperStruct.UniSwap memory swapData = abi.decode(data, (IExecutorHelperStruct.UniSwap));

    // 2. Scale amountIn based on newAmount
    swapData.amountIn = (swapData.amountIn * newAmount) / oldAmount;

    // 3. Encode modified struct back to bytes
    return abi.encode(swapData);
  }
}
