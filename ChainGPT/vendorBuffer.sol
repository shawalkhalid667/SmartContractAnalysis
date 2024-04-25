
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

// Defining the Buffer library
library Buffer {
    struct buffer {
        bytes buf; // Buffer data
        uint capacity; // Buffer capacity
    }

    // Function to initialize a buffer with a specific capacity
    function init(buffer memory buf, uint capacity) internal pure {
        if(capacity%32 != 0) capacity += 32 - (capacity%32);
        // Ensure capacity is a multiple of 32 bytes
        buf.capacity = capacity;
        buf.buf = new bytes(capacity);
    }

    // Function to resize the buffer if needed while appending new data
    function resize(buffer memory buf, uint newCapacity) private pure {
        bytes memory oldBuf = buf.buf;
        // Create a new buffer and copy the old buffer's contents to the new buffer
        buf.buf = new bytes(newCapacity);
        for (uint i = 0; i < buf.buf.length; i++) {
            buf.buf[i] = oldBuf[i];
        }
        buf.capacity = newCapacity;
    }

    // Function to write bytes to the buffer at a specific offset
    function write(buffer memory buf, uint off, bytes memory data) internal pure {
        if (off + data.length > buf.capacity) {
            resize(buf, max(buf.capacity, off + data.length));
        }

        bytes memory dst = buf.buf;
        for(uint i = 0; i < data.length; i++) {
            dst[off+i] = data[i];
        }
    }

    // Function to append bytes to the buffer
    function append(buffer memory buf, bytes memory data) internal pure {
        write(buf, buf.buf.length, data);
    }

    // Function to append bytes, bytes20, and bytes32 data to the buffer
    function append(buffer memory buf, bytes20 data) internal pure {
        append(buf, abi.encodePacked(data));
    }

    function append(buffer memory buf, bytes32 data) internal pure {
        append(buf, abi.encodePacked(data));
    }

    // Utility Functions
    function max(uint a, uint b) private pure returns(uint) {
        if(a > b) {
            return a;
        }
        return b;
    }

    // Function to truncate the buffer length to 0
    function truncate(buffer memory buf) internal pure {
        buf.buf = new bytes(0);
    }
}
