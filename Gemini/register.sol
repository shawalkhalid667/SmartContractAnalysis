// SPDX-License-Identifier: Apache-2.0

pragma solidity ^0.8.0;

abstract contract Proxy {
  // Function signatures for external calls (payable)
  receive() external payable virtual;
  fallback() external payable virtual;

  // Internal function to retrieve the implementation address
  internal virtual view returns (address) {
    return _implementation();
  }

  // Internal function for delegating execution
  internal function _delegate(address implementation) private {
    assembly {
      // Load calldata size into a register
      let dataSize := calldatasize()

      // Copy calldata into memory pointed to by msg.data
      calldatacopy(msg.data, 0, dataSize)

      // Delegate call to the implementation contract
      let result := delegatecall(gas, implementation, msg.data, dataSize, 0, 0)

      // Load return data size from memory
      returndatasize := returndatasize()

      // Copy return data into memory pointed to by returndata
      returndatacopy(returndata, 0, returndatasize)

      // If delegation failed, bubble up the revert message
      if iszero(result) {
        revert(returndata, returndatasize)
      }

      // Otherwise, return whatever the implementation returned
      return(returndata, returndatasize)
    }
  }

  // Virtual function allowing derived contracts to add pre-delegation logic
  internal virtual {
    _willFallback();
  }

  // Fallback function that triggers delegation
  internal {
    _willFallback();
    _delegate(_implementation());
  }

  // Abstract function requiring derived contracts to define the implementation address
  internal virtual view returns (address) = 0;
}
