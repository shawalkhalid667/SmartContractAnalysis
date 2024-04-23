pragma solidity ^0.8.13;

contract MemoryUtils {
  // Memory allocation structure
  struct MemoryPtr {
    uint256 ptr;
  }

  // Error types for memory operations
  error OutOfMemory();
  error InvalidMemoryPtr();

  // Allocate memory of size bytes
  function malloc(uint256 size) internal pure returns (MemoryPtr memory ptr) {
    assembly {
      ptr.ptr := mload(0x40) // Get free memory pointer
      mstore(0x40, add(ptr.ptr, size)) // Update free memory pointer
    }
    if (ptr.ptr == 0) revert OutOfMemory();
  }

  // Copy data from src to dst of size bytes
  function copy(MemoryPtr memory src, MemoryPtr memory dst, uint256 size) internal pure {
    assembly {
      let i := 0
      for { } lt(i, size) { } {
        mstore(add(dst.ptr, mul(i, 32)), mload(add(src.ptr, mul(i, 32))))
        i := add(i, 1)
      }
    }
  }

  // Compare two memory pointers for equality
  function equals(MemoryPtr memory a, MemoryPtr memory b) internal pure returns (bool) {
    return a.ptr == b.ptr;
  }

  // Greater Than comparison for memory pointers (useful for sorting)
  function greaterThan(MemoryPtr memory a, MemoryPtr memory b) internal pure returns (bool) {
    return a.ptr > b.ptr;
  }
}

library ArrayHelpers {
  using MemoryUtils for MemoryUtils.MemoryPtr;

  // Map function with custom callback
  function map(MemoryUtils.MemoryPtr memory arr, uint256 len, function(uint256) pure returns (uint256) callback) internal pure returns (MemoryUtils.MemoryPtr memory) {
    MemoryUtils.MemoryPtr memory result = MemoryUtils.malloc(len * 32);
    for (uint256 i = 0; i < len; i++) {
      uint256 value = callback(getValue(arr, i));
      setValue(result, i, value);
    }
    return result;
  }

  // Filter function with custom predicate
  function filter(MemoryUtils.MemoryPtr memory arr, uint256 len, function(uint256) pure returns (bool) predicate) internal pure returns (MemoryUtils.MemoryPtr memory) {
    uint256 filteredCount = 0;
    for (uint256 i = 0; i < len; i++) {
      if (predicate(getValue(arr, i))) {
        filteredCount++;
      }
    }
    MemoryUtils.MemoryPtr memory result = MemoryUtils.malloc(filteredCount * 32);
    uint256 j = 0;
    for (uint256 i = 0; i < len; i++) {
      if (predicate(getValue(arr, i))) {
        setValue(result, j, getValue(arr, i));
        j++;
      }
    }
    return result;
  }

  // Reduce function with initial value and custom reducer
  function reduce(MemoryUtils.MemoryPtr memory arr, uint256 len, uint256 initialValue, function(uint256, uint256) pure returns (uint256) reducer) internal pure returns (uint256) {
    uint256 result = initialValue;
    for (uint256 i = 0; i < len; i++) {
      result = reducer(result, getValue(arr, i));
    }
    return result;
  }

  // Get value at a specific index in memory array
  function getValue(MemoryUtils.MemoryPtr memory arr, uint256 index) internal pure returns (uint256) {
    if (index >= getLength(arr)) revert("Index out of bounds");
    MemoryUtils.MemoryPtr memory ptr = MemoryUtils.MemoryPtr({ ptr: add(arr.ptr, mul(index, 32)) });
    assembly {
      return mload(ptr.ptr)
    }
  }

  // Set value at a specific index in memory array
  
