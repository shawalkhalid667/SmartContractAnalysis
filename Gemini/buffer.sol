// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

library Buffer {
    struct buffer {
        bytes buf;
        uint capacity;
    }

    // Initializes a buffer with a specified initial capacity.
    function init(buffer storage b, uint capacity) internal {
        require(capacity > 0, "Buffer: Initial capacity must be greater than 0");
        b.buf = new bytes(capacity);
        b.capacity = capacity;
    }

    // Initializes a new buffer from an existing bytes object.
    function fromBytes(buffer memory b, bytes memory data) internal pure {
        b.buf = data;
        b.capacity = data.length;
    }

    // Sets the buffer length to 0.
    function truncate(buffer storage b) internal {
        b.buf = "";
    }

    // Writes a byte string to the buffer, resizing if the capacity is exceeded.
    function write(buffer storage b, bytes memory data) internal {
        uint neededCapacity = b.length + data.length;
        resize(b, max(b.capacity, neededCapacity));
        bytes memory newBuf = abi.encodePacked(b.buf, data);
        assembly {
            mstore(b.buf_ptr, newBuf)
        }
    }

    // Appends a byte string to the buffer, resizing if the capacity is exceeded.
    function append(buffer storage b, bytes memory data) internal {
        write(b, data);
    }

    // Writes a byte to the buffer, resizes if the capacity is exceeded.
    function writeUint8(buffer storage b, uint8 data) internal {
        resize(b, max(b.capacity, b.length + 1));
        assembly {
            mstore8(add(b.buf_ptr, b.length), data)
            b.length := add(b.length, 1)
        }
    }

    // Appends a byte to the buffer, resizes if the capacity is exceeded.
    function appendUint8(buffer storage b, uint8 data) internal {
        writeUint8(b, data);
    }

    // Writes a bytes20 to the buffer, resizes if the capacity is exceeded.
    function writeBytes20(buffer storage b, bytes20 data) internal {
        resize(b, max(b.capacity, b.length + 20));
        assembly {
            mstore(add(b.buf_ptr, b.length), data)
            b.length := add(b.length, 20)
        }
    }

    // Appends a bytes20 to the buffer, resizes if the capacity is exceeded.
    function appendBytes20(buffer storage b, bytes20 data) internal {
        writeBytes20(b, data);
    }

    // Appends a bytes32 to the buffer, resizes if the capacity is exceeded.
    function appendBytes32(buffer storage b, bytes32 data) internal {
        resize(b, max(b.capacity, b.length + 32));
        assembly {
            mstore(add(b.buf_ptr, b.length), data)
            b.length := add(b.length, 32)
        }
    }

    // Internal function to resize the buffer.
    function resize(buffer storage b, uint newCapacity) private {
        require(newCapacity > b.length, "Buffer: New capacity must be greater than current length");
        bytes memory newBuf = new bytes(newCapacity);
        assembly {
            copy(newBuf_ptr, b.buf_ptr, b.length)
        }
        b.buf = newBuf;
        b.capacity = newCapacity;
    }

    // Internal function to calculate the maximum of two values.
    function max(uint a, uint b) private pure returns (uint) {
        return a >= b ? a : b;
    }

    // Internal functions for writing data types like uint and integer to the buffer
    // can be implemented here based on your specific needs.

}
