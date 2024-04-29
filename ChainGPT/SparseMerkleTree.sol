
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract SparseMerkleTree {
    // Array to store default hashes for the Merkle tree nodes
    bytes32[] public defaultHashes;

    constructor() {
        // Set the default hash for index 0
        defaultHashes.push(0x0000000000000000000000000000000000000000000000000000000000000000);
        
        // Set default hashes for the remaining levels in the Merkle tree
        for (uint i = 0; i < 255; i++) {
            defaultHashes.push(computeHash(defaultHashes[i], defaultHashes[i]));
        }
    }

    // Function to compute the hash of two inputs
    function computeHash(bytes32 _left, bytes32 _right) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(_left, _right));
    }

    // Function to verify if a leaf node is a member of the Merkle tree based on the root hash and proof provided
    function checkMembership(bytes32 _leaf, uint _index, bytes32 _root, bytes32[] memory _proof) public view returns (bool) {
        bytes32 computedHash = getRoot(_leaf, _index, _proof);
        return computedHash == _root;
    }

    // Function to compute the root hash of the Merkle tree based on the leaf, index, and proof provided
    function getRoot(bytes32 _leaf, uint _index, bytes32[] memory _proof) public view returns (bytes32) {
        bytes32 computedHash = _leaf;

        for (uint i = 0; i < _proof.length; i++) {
            if (_index % 2 == 0) {
                computedHash = computeHash(computedHash, _proof[i]);
            } else {
                computedHash = computeHash(_proof[i], computedHash);
            }
            _index = _index / 2;
        }

        return computedHash;
    }

    // Function to set the default hashes for the Merkle tree nodes between the specified start and end indexes
    function setDefaultHashes(uint _startIndex, uint _endIndex, bytes32[] memory _hashes) public {
        require(_hashes.length == _endIndex - _startIndex + 1, "Invalid hashes length");

        for (uint i = _startIndex; i <= _endIndex; i++) {
            defaultHashes[i] = _hashes[i - _startIndex];
        }
    }
}
