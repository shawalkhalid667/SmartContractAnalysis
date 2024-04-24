
// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

abstract contract Proxy {
    function receive() external payable virtual {
        _fallback();
    }
    
    function fallback() external payable virtual {
        _fallback();
    }
    
    function _implementation() internal view virtual returns (address);
    
    function _delegate(address implementation) internal {
        assembly {
            let ptr := mload(0x40)
            calldatacopy(ptr, 0, calldatasize())
            
            let result := delegatecall(gas(), implementation, ptr, calldatasize(), 0, 0)
            let size := returndatasize()
            returndatacopy(ptr, 0, size)
            
            switch result
            case 0 { revert(ptr, size) }
            default { return(ptr, size) }
        }
    }
    
    function _willFallback() internal virtual {
        // Additional functionality can be added in derived contracts
    }
    
    function _fallback() internal {
        _willFallback();
        _delegate(_implementation());
    }
}
