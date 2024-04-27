
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

library ECRecovery {

    // Function to recover signer address from a message using the corresponding signature
    function recover(bytes32 hash, bytes memory signature) public pure returns (address) {
        // Check the signature length
        if (signature.length != 65) {
            return (address(0));
        }

        // Divide the signature in r, s and v variables
        bytes32 r;
        bytes32 s;
        uint8 v;

        // Extract ECDSA signature components
        assembly {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
            v := byte(0, mload(add(signature, 0x60)))
        }

        // Version of signature should be 27 or 28, but 0 and 1 are also possible versions
        if (v < 27) {
            v += 27;
        }

        // If the version is not correct return zero address
        if (v != 27 && v != 28) {
            return (address(0));
        } else {
            // If the version is correct, recover the address from the signature
            // ecrecover returns zero on error, which is just fine here
            return ecrecover(hash, v, r, s);
        }
    }
}
