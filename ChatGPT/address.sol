// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract AddressUtility {
    function isContract(address _addr) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(_addr)
        }
        return size > 0;
    }

    function sendValue(address payable _recipient, uint256 _amount) internal {
        require(address(this).balance >= _amount, "Insufficient balance");
        (bool success, ) = _recipient.call{value: _amount}("");
        require(success, "AddressUtility: Failed to send Ether");
    }

    function functionCall(address _target, bytes memory _data) internal returns (bytes memory) {
        (bool success, bytes memory returnData) = _target.call(_data);
        require(success, "AddressUtility: Function call failed");
        return returnData;
    }

    function functionCallWithValue(address _target, bytes memory _data, uint256 _value) internal returns (bytes memory) {
        (bool success, bytes memory returnData) = _target.call{value: _value}(_data);
        require(success, "AddressUtility: Function call with value failed");
        return returnData;
    }
}
