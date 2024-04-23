// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

// Library for memory management primitives
library MemoryManager {
    struct Pointer {
        uint256 data;
        uint256 next;
    }

    // Function to allocate memory
    function malloc(uint256 size) internal pure returns (Pointer memory) {
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, size)
            mstore(0x40, add(ptr, size))
            Pointer := ptr
        }
    }

    // Function to copy memory
    function copy(Pointer memory from, Pointer memory to, uint256 size) internal pure {
        assembly {
            let i := 0
            for { } lt(i, size) { i := add(i, 32) } {
                mstore(add(to, i), mload(add(from, i)))
            }
        }
    }

    // Function to compare memory
    function equals(Pointer memory ptr1, Pointer memory ptr2, uint256 size) internal pure returns (bool) {
        assembly {
            let i := 0
            for { } lt(i, size) { i := add(i, 32) } {
                if not(eq(mload(add(ptr1, i)), mload(add(ptr2, i))))) {
                    return 0
                }
            }
            return 1
        }
    }
}

// Library for array manipulation
library ArrayHelpers {
    using MemoryManager for MemoryManager.Pointer;

    // Map function for arrays
    function map(uint256[] memory arr, function(uint256) pure returns (uint256) func) internal pure returns (uint256[] memory result) {
        result = new uint256[](arr.length);
        for (uint256 i = 0; i < arr.length; i++) {
            result[i] = func(arr[i]);
        }
    }

    // Filter function for arrays
    function filter(uint256[] memory arr, function(uint256) pure returns (bool) func) internal pure returns (uint256[] memory result) {
        result = new uint256 ;
        for (uint256 i = 0; i < arr.length; i++) {
            if (func(arr[i])) {
                result.push(arr[i]);
            }
        }
    }

    // Reduce function for arrays
    function reduce(uint256[] memory arr, function(uint256, uint256) pure returns (uint256) func, uint256 initialValue) internal pure returns (uint256 result) {
        result = initialValue;
        for (uint256 i = 0; i < arr.length; i++) {
            result = func(result, arr[i]);
        }
    }
}

// Example contract utilizing the libraries
contract ArrayManipulator {
    using ArrayHelpers for uint256[];

    // Example function demonstrating the usage of ArrayHelpers library
    function manipulateArray(uint256[] memory arr) external pure returns (uint256[] memory) {
        // Mapping example: doubling each element
        uint256[] memory mappedArray = arr.map(function(uint256 element) pure returns (uint256) {
            return element * 2;
        });

        // Filtering example: keeping only even elements
        uint256[] memory filteredArray = arr.filter(function(uint256 element) pure returns (bool) {
            return element % 2 == 0;
        });

        // Reducing example: summing all elements
        uint256 sum = arr.reduce(function(uint256 a, uint256 b) pure returns (uint256) {
            return a + b;
        }, 0);

        return mappedArray;
    }
}
