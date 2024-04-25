// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

library Buffer {
    struct Buffer {
        bytes buffer;
        uint capacity;
    }

    function init(Buffer storage self, uint _capacity) internal {
        require(_capacity % 32 == 0, "Capacity must be multiple of 32");
        self.buffer = new bytes(_capacity);
        self.capacity = _capacity;
    }

    function resize(Buffer storage self, uint _capacity) internal {
        require(_capacity % 32 == 0, "Capacity must be multiple of 32");
        bytes memory temp = new bytes(_capacity);
        for (uint i = 0; i < self.buffer.length; i++) {
            temp[i] = self.buffer[i];
        }
        self.buffer = temp;
        self.capacity = _capacity;
    }

    function setLength(Buffer storage self, uint _length) internal {
        require(_length <= self.capacity, "Length exceeds capacity");
        self.buffer = abi.encodePacked(self.buffer[:_length]);
    }

    function write(Buffer storage self, bytes memory data, uint offset) internal {
        require(offset + data.length <= self.capacity, "Data exceeds buffer capacity");
        for (uint i = 0; i < data.length; i++) {
            self.buffer[offset + i] = data[i];
        }
    }

    function append(Buffer storage self, bytes memory data) internal {
        require(self.buffer.length + data.length <= self.capacity, "Data exceeds buffer capacity");
        for (uint i = 0; i < data.length; i++) {
            self.buffer.push(data[i]);
        }
    }

    function writeByte(Buffer storage self, byte data, uint offset) internal {
        require(offset < self.capacity, "Offset exceeds buffer capacity");
        self.buffer[offset] = data;
    }

    function appendByte(Buffer storage self, byte data) internal {
        require(self.buffer.length < self.capacity, "Buffer is full");
        self.buffer.push(data);
    }

    function appendBytes20(Buffer storage self, bytes20 data) internal {
        require(self.buffer.length + 20 <= self.capacity, "Data exceeds buffer capacity");
        for (uint i = 0; i < 20; i++) {
            self.buffer.push(data[i]);
        }
    }

    function appendBytes32(Buffer storage self, bytes32 data) internal {
        require(self.buffer.length + 32 <= self.capacity, "Data exceeds buffer capacity");
        for (uint i = 0; i < 32; i++) {
            self.buffer.push(data[i]);
        }
    }

    function appendInt(Buffer storage self, uint256 data) internal {
        bytes memory b = new bytes(32);
        assembly { mstore(add(b, 32), data) }
        append(self, b);
    }

    function max(uint a, uint b) internal pure returns (uint) {
        return a > b ? a : b;
    }

    function truncate(Buffer storage self) internal {
        self.buffer = new bytes(0);
    }

    function maxInt(uint256 a, uint256 b) internal pure returns (uint256) {
        return a > b ? a : b;
    }
}
