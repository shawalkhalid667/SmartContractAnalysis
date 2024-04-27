// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library ECRecovery {
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        require(signature.length == 65, "ECRecovery: invalid signature length");

        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            // Extracting these values is more efficient and faster than using the Solidity 'split' function
            r := mload(add(signature, 32))
            s := mload(add(signature, 64))
            v := byte(0, mload(add(signature, 96)))
        }

        // Version of signature should be either 27 or 28, with 27 being converted to 0 and 28 to 1
        if (v < 27) {
            v += 27;
        }

        require(v == 27 || v == 28, "ECRecovery: invalid signature version");

        return ecrecover(hash, v, r, s);
    }

    function isValidSignature(
        bytes32 hash,
        bytes memory signature,
        address signer
    ) internal pure returns (bool) {
        address recoveredAddress = recover(hash, signature);
        return recoveredAddress == signer;
    }
}
