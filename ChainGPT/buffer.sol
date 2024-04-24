
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

library Buffer {
    struct buffer {
        bytes buf;
        uint capacity;
    }

    function init(buffer storage buf, uint _capacity) internal {
        buf.capacity = _capacity;
        buf.buf = new bytes(_capacity);
    }

    function fromBytes(buffer storage buf, bytes memory data) internal {
        buf.capacity = data.length;
        buf.buf = data;
    }

    function truncate(buffer storage buf) internal {
        buf.buf = new bytes(buf.capacity);
    }

    function resize(buffer storage buf, uint newCapacity) internal {
        bytes memory temp = buf.buf;
        buf.buf = new bytes(newCapacity);
        for (uint i = 0; i < buf.capacity; i++) {
            buf.buf[i] = temp[i];
        }
        buf.capacity = newCapacity;
    }

    function write(buffer storage buf, bytes memory data) internal {
        uint len = buf.buf.length;
        if (len + data.length > buf.capacity) {
            resize(buf, len + data.length);
        }

        for (uint i = 0; i < data.length; i++) {
            buf.buf[len + i] = data[i];
        }
    }

    function append(buffer storage buf, bytes memory data) internal {
        write(buf, data);
    }

    function writeUint8(buffer storage buf, uint8 data) internal {
        write(buf, abi.encodePacked(data));
    }

    function appendUint8(buffer storage buf, uint8 data) internal {
        append(buf, abi.encodePacked(data));
    }

    function writeBytes20(buffer storage buf, bytes20 data) internal {
        write(buf, abi.encodePacked(data));
    }

    function appendBytes20(buffer storage buf, bytes20 data) internal {
        append(buf, abi.encodePacked(data));
    }

    function appendBytes32(buffer storage buf, bytes32 data) internal {
        append(buf, abi.encodePacked(data));
    }
}
