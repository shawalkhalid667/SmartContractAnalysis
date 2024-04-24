// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

abstract contract Proxy {
    function receive() external payable virtual {
        _fallback();
    }

    fallback() external payable {
        _fallback();
    }

    function _implementation() internal virtual view returns (address);

    function _delegate(address implementation) internal {
        assembly {
            // Copy msg.data. We take full control of memory in this inline assembly
            // block because it will not return to Solidity code. We overwrite the
            // Solidity scratch pad at memory position 0.
            calldatacopy(0, 0, calldatasize())

            // Delegate call to the implementation contract
            let result := delegatecall(gas(), implementation, 0, calldatasize(), 0, 0)

            // Copy the returned data
            returndatacopy(0, 0, returndatasize())

            switch result
            // Delegate call succeeded
            case 0 {
                revert(0, returndatasize())
            }
            // Delegate call succeeded
            default {
                return(0, returndatasize())
            }
        }
    }

    function _willFallback() internal virtual {
        // Can be overridden to add functionality
    }

    function _fallback() internal {
        _willFallback();
        _delegate(_implementation());
    }
}
