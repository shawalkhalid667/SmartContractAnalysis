
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title AddressUtility
 * @dev Utility functions related to the address type
 */
contract AddressUtility {
    
    /**
     * @dev Checks if an address is a contract.
     * @param _addr The address to check
     * @return True if the address is a contract, false otherwise
     */
    function isContract(address _addr) public view returns (bool) {
        uint32 size;
        assembly {
            size := extcodesize(_addr)
        }
        return (size > 0);
    }

    /**
     * @dev Sends value to a payable address using low-level call to prevent reentrancy attacks
     * @param _to The address to send value to
     * @param _value The amount of value to send
     */
    function sendValue(address payable _to, uint _value) public payable {
        require(address(this).balance >= _value, "Insufficient balance");
        
        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = _to.call{ value: _value }("");
        require(success, "Transfer failed");
    }

    /**
     * @dev Performs a low-level call with data
     * @param _to The address to call
     * @param _data The data to call with
     */
    function functionCall(address _to, bytes memory _data) public returns (bytes memory) {
        return functionCallWithValue(_to, 0, _data);
    }

    /**
     * @dev Performs a low-level call with data and value
     * @param _to The address to call
     * @param _value The value to send with the call
     * @param _data The data to call with
     */
    function functionCallWithValue(address _to, uint _value, bytes memory _data) public payable returns (bytes memory) {
        require(address(this).balance >= _value, "Insufficient balance");
        
        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = _to.call{ value: _value }(_data);
        
        // Verify call was successful
        if (success) {
            return returndata;
        } else {
            // solhint-disable-next-line no-inline-assembly
            assembly {
                revert(add(32, returndata), mload(returndata))
            }
        }
    }
}
