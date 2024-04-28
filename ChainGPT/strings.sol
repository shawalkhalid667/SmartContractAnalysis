solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library strings {
    struct slice {
        uint _len;
        uint _ptr;
    }

    // We define this struct to easily slice strings

    function memcpy(uint dest, uint src, uint len) private pure {
        // Copy word-length chunks while possible
        for(; len >= 32; len -= 32) {
            assembly {
                mstore(dest, mload(src))
            }
            dest += 32;
            src += 32;
        }

        // Copy remaining bytes
        uint mask = 256 ** (32 - len) - 1;
        assembly {
            let srcpart := and(mload(src), not(mask))
            let destpart := and(mload(dest), mask)
            mstore(dest, or(destpart, srcpart))
        }
    }

    // Converts a slice to a string
    function toString(slice memory s) internal pure returns (string memory) {
        string memory out = new string(s._len);
        uint ptr;
        assembly {
            ptr := add(out, 32)
        }
        memcpy(ptr, s._ptr, s._len);
        return out;
    }

    // Returns the length in runes of the slice s.
    function len(slice memory s) internal pure returns (uint) {
        uint l;
        uint ptr = s._ptr - 31;
        uint end = ptr + s._len;
        for (l = 0; ptr < end; l++) {
            uint8 b;
            assembly { b := and(mload(ptr), 0xFF) }
            if (b < 0x80) {
                ptr += 1;
            } else if(b < 0xE0) {
                ptr += 2;
            } else {
                ptr += 3;
            }
        }
        return l;
    }

    // Returns a newly allocated string containing the concatenation of the slices a and b.
    function concat(slice memory a, slice memory b) internal pure returns (string memory) {
        string memory res = new string(a._len + b._len);
        uint ptr;
        assembly { ptr := add(res, 32) }
        memcpy(ptr, a._ptr, a._len);
        memcpy(ptr + a._len, b._ptr, b._len);
        return res;
    }

    // Other functions like split, join, compare etc. can be implemented in a similar way
}
