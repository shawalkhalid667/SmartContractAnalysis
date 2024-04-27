
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library ECVerify {
    // Signature size is 65 bytes (32 bytes r + 32 bytes s + 1 byte v)
    uint256 constant SIGNATURE_SIZE = 65;

    /**
     * @dev Verifies an ECDSA signature.
     * @param _hash Hash to verify against the signature.
     * @param _signature ECDSA signature.
     * @return address recovered from the signature.
     */
    function ecverify(bytes32 _hash, bytes memory _signature) public pure returns (address) {
        require(_signature.length == SIGNATURE_SIZE, "Invalid signature length");

        bytes32 r;
        bytes32 s;
        uint8 v;

        // Split the signature into r, s, and v variables
        // This is necessary because ecrecover does not accept a byte array for the signature
        assembly {
            r := mload(add(_signature, 32)) // First 32 bytes
            s := mload(add(_signature, 64)) // Next 32 bytes
            v := byte(0, mload(add(_signature, 96))) // Final byte (first byte of the next 32 bytes)
        }

        // Ensure the signature version is correct
        require(v == 27 || v == 28, "Invalid signature version");

        // If v is not 27 or 28 adjust it to the correct value
        if (v < 27) {
            v += 27;
        }

        address signer = ecrecover(_hash, v, r, s);
        require(signer != address(0), "Invalid signature");

        return signer;
    }
}
