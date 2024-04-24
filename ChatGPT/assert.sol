// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library Assert {
    event AssertionResult(bool success, string message);

    function equal(string memory a, string memory b) internal pure {
        emit AssertionResult(keccak256(abi.encodePacked(a)) == keccak256(abi.encodePacked(b)), "Strings are not equal");
    }

    function notEqual(string memory a, string memory b) internal pure {
        emit AssertionResult(keccak256(abi.encodePacked(a)) != keccak256(abi.encodePacked(b)), "Strings are equal");
    }

    function isEmptyString(string memory a) internal pure {
        emit AssertionResult(bytes(a).length == 0, "String is not empty");
    }

    function equal(bytes32 a, bytes32 b) internal pure {
        emit AssertionResult(a == b, "Bytes32 are not equal");
    }

    function notEqual(bytes32 a, bytes32 b) internal pure {
        emit AssertionResult(a != b, "Bytes32 are equal");
    }

    function isEmptyBytes32(bytes32 a) internal pure {
        emit AssertionResult(uint256(a) == 0, "Bytes32 is not empty");
    }

    function equal(address a, address b) internal pure {
        emit AssertionResult(a == b, "Addresses are not equal");
    }

    function notEqual(address a, address b) internal pure {
        emit AssertionResult(a != b, "Addresses are equal");
    }

    function isEmptyAddress(address a) internal pure {
        emit AssertionResult(a == address(0), "Address is not empty");
    }

    function equal(uint256 a, uint256 b) internal pure {
        emit AssertionResult(a == b, "Uintegers are not equal");
    }

    function notEqual(uint256 a, uint256 b) internal pure {
        emit AssertionResult(a != b, "Uintegers are equal");
    }

    function isZero(uint256 a) internal pure {
        emit AssertionResult(a == 0, "Integer is not zero");
    }

    function equal(int256 a, int256 b) internal pure {
        emit AssertionResult(a == b, "Integers are not equal");
    }

    function notEqual(int256 a, int256 b) internal pure {
        emit AssertionResult(a != b, "Integers are equal");
    }

    function isZero(int256 a) internal pure {
        emit AssertionResult(a == 0, "Integer is not zero");
    }

    function equal(address[] memory a, address[] memory b) internal pure {
        if (a.length != b.length) {
            emit AssertionResult(false, "Arrays are not equal in length");
            return;
        }
        
        for (uint i = 0; i < a.length; i++) {
            if (a[i] != b[i]) {
                emit AssertionResult(false, "Arrays differ at index " + string(i));
                return;
            }
        }
        
        emit AssertionResult(true, "Arrays are equal");
    }

    function equal(uint256[] memory a, uint256[] memory b) internal pure {
        if (a.length != b.length) {
            emit AssertionResult(false, "Arrays are not equal in length");
            return;
        }
        
        for (uint i = 0; i < a.length; i++) {
            if (a[i] != b[i]) {
                emit AssertionResult(false, "Arrays differ at index " + string(i));
                return;
            }
        }
        
        emit AssertionResult(true, "Arrays are equal");
    }

    function equal(int256[] memory a, int256[] memory b) internal pure {
        if (a.length != b.length) {
            emit AssertionResult(false, "Arrays are not equal in length");
            return;
        }
        
        for (uint i = 0; i < a.length; i++) {
            if (a[i] != b[i]) {
                emit AssertionResult(false, "Arrays differ at index " + string(i));
                return;
            }
        }
        
        emit AssertionResult(true, "Arrays are equal");
    }
}
