// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library ECVerify {
    function ecverify(bytes32 hash, bytes memory signature) internal pure returns (address) {
        require(signature.length == 65, "Invalid signature length");

        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            // Divide the signature into r, s, and v variables
            r := mload(add(signature, 32))
            s := mload(add(signature, 64))
            v := byte(0, mload(add(signature, 96)))
        }

        if (v < 27) {
            v += 27;
        }

        require(v == 27 || v == 28, "Invalid signature version");

        address signer = ecrecover(hash, v, r, s);
        require(signer != address(0), "Invalid signer");

        return signer;
    }
}
