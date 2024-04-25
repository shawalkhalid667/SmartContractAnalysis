// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

library Buffer {
  struct buffer {
    bytes data;
    uint256 capacity;
  }

  // Initializes a buffer with a specific capacity, ensuring alignment with 32 bytes
  function init(buffer storage buf, uint256 capacity) public {
    uint256 newCapacity = capacity + 31 & ~31; // Round up to nearest multiple of 32 bytes
    assembly {
      mstore(buf.slot, mul(newCapacity, 1)) // Allocate memory for data
    }
    buf.data = new bytes(newCapacity);
    buf.capacity = newCapacity;
  }

  // Creates a new buffer from existing bytes
  function fromBytes(bytes memory data) public pure returns (buffer memory) {
    buffer memory buf;
    buf.data = data;
    buf.capacity = data.length;
    return buf;
  }

  // Resizes the buffer if needed before appending new data
  function resize(buffer storage buf, uint256 requiredCapacity) internal {
    if (buf.capacity < requiredCapacity) {
      uint256 newCapacity = max(buf.capacity * 2, requiredCapacity);
      assembly {
        mstore(buf.slot, mul(newCapacity, 1)) // Allocate new memory
        let src := add(buf.data, 32) // Copy existing data
        let dst := add(mload(buf.slot), 32) // New data location
        let size := mload(buf.data) // Copy size of existing data
        copy(src, dst, size) // Copy existing data to new buffer
      }
      buf.data = new bytes(newCapacity);
      buf.capacity = newCapacity;
    }
  }

  // Sets the buffer length to 0
  function truncate(buffer storage buf) public {
    assembly {
      mstore(buf.data, 0) // Set length to 0
    }
  }

  // Writes bytes to the buffer at a specific offset
  function write(buffer storage buf, uint256 offset, bytes memory data) public {
    uint256 requiredCapacity = offset + data.length;
    resize(buf, requiredCapacity);
    assembly {
      let dst := add(add(buf.data, 32), offset) // Destination for data
      let src := add(data, 32) // Copy from memory
      let size := mload(data) // Copy size of data
      copy(src, dst, size) // Copy data to buffer
    }
  }

  // Appends bytes to the buffer
  function append(buffer storage buf, bytes memory data) public {
    write(buf, buf.data.length, data);
  }

  // Writes a single byte to the buffer
  function writeByte(buffer storage buf, uint8 value) public {
    append(buf, abi.encodePacked(value));
  }

  // Appends a single byte to the buffer
  function appendByte(buffer storage buf, uint8 value) public {
    writeByte(buf, value);
  }

  // Appends bytes20 data to the buffer
  function appendBytes20(buffer storage buf, bytes20 data) public {
    append(buf, abi.encodePacked(data));
  }

  // Appends bytes32 data to the buffer
  function appendBytes32(buffer storage buf, bytes32 data) public {
    append(buf, abi.encodePacked(data));
  }

  // Appends an integer to the buffer (assumes uint256)
  function appendUint(buffer storage buf, uint256 value) public {
    append(buf, abi.encodePacked(value));
  }

  // Utility functions

  function max(uint256 a, uint256 b) internal pure returns (uint256) {
    return a >= b ? a : b;
  }
}
