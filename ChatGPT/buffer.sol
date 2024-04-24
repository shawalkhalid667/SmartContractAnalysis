// SPDX-License-Identifier: MIT
pragma solidity >=0.8.13;

library Buffer {
    struct buffer {
        bytes buf;
        uint256 capacity;
    }

    function init(buffer storage buf, uint256 _capacity) internal {
        buf.buf = new bytes(_capacity);
        buf.capacity = _capacity;
    }

    function fromBytes(buffer storage buf, bytes memory initial) internal {
        buf.buf = initial;
        buf.capacity = initial.length;
    }

    function truncate(buffer storage buf) internal {
        buf.buf = new bytes(0);
        buf.capacity = 0;
    }

    function resize(buffer storage buf, uint256 newCapacity) private {
        bytes memory temp = new bytes(newCapacity);
        for (uint256 i = 0; i < buf.buf.length && i < newCapacity; i++) {
            temp[i] = buf.buf[i];
        }
        buf.buf = temp;
        buf.capacity = newCapacity;
    }

    function write(buffer storage buf, bytes memory data) internal {
        uint256 len = buf.buf.length;
        uint256 dataLen = data.length;
        if (len + dataLen > buf.capacity) {
            resize(buf, len + dataLen);
        }
        for (uint256 i = 0; i < dataLen; i++) {
            buf.buf[len + i] = data[i];
        }
    }

    function append(buffer storage buf, bytes memory data) internal {
        write(buf, data);
    }

    function writeUint8(buffer storage buf, uint8 data) internal {
        uint256 len = buf.buf.length;
        if (len + 1 > buf.capacity) {
            resize(buf, len + 1);
        }
        buf.buf[len] = bytes1(data);
    }

    function appendUint8(buffer storage buf, uint8 data) internal {
        writeUint8(buf, data);
    }

    function writeBytes20(buffer storage buf, bytes20 data) internal {
        uint256 len = buf.buf.length;
        if (len + 20 > buf.capacity) {
            resize(buf, len + 20);
        }
        for (uint256 i = 0; i < 20; i++) {
            buf.buf[len + i] = data[i];
        }
    }

    function appendBytes20(buffer storage buf, bytes20 data) internal {
        writeBytes20(buf, data);
    }

    function writeBytes32(buffer storage buf, bytes32 data) internal {
        uint256 len = buf.buf.length;
        if (len + 32 > buf.capacity) {
            resize(buf, len + 32);
        }
        for (uint256 i = 0; i < 32; i++) {
            buf.buf[len + i] = data[i];
        }
    }

    function appendBytes32(buffer storage buf, bytes32 data) internal {
        writeBytes32(buf, data);
    }
}
