// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library ECRecovery {
    function recover(bytes32 _hash, bytes memory _signature) internal pure returns (address) {
        require(_signature.length == 65, "ECRecovery: invalid signature length");

        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            // First 32 bytes are the signature's r
            r := mload(add(_signature, 32))
            // Next 32 bytes are the signature's s
            s := mload(add(_signature, 64))
            // Final byte is the signature's v
            v := byte(0, mload(add(_signature, 96)))
        }

        if (v < 27) {
            v += 27;
        }

        require(v == 27 || v == 28, "ECRecovery: invalid signature version");

        return ecrecover(_hash, v, r, s);
    }

    function isValidSignature(bytes32 _hash, bytes memory _signature, address _signer) internal pure returns (bool) {
        return recover(_hash, _signature) == _signer;
    }
}
