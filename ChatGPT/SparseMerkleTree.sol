// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SparseMerkleTree {
    // State Variables
    bytes32[] public defaultHashes;

    // Constructor
    constructor() {
        // Initialize default hashes
        defaultHashes.push(keccak256(abi.encodePacked(uint256(0))));
    }

    // Functions

    // Verify if a leaf node is a member of the Merkle tree based on the root hash and proof provided
    function checkMembership(bytes32 leaf, uint256 index, bytes32[] memory proof, bytes32 rootHash) public view returns (bool) {
        require(proof.length <= 256, "Proof length exceeds limit");

        bytes32 computedHash = leaf;

        for (uint256 i = 0; i < proof.length; i++) {
            bytes32 proofElement = proof[i];

            if (index & (1 << i) == 0) {
                computedHash = keccak256(abi.encodePacked(computedHash, proofElement));
            } else {
                computedHash = keccak256(abi.encodePacked(proofElement, computedHash));
            }
        }

        return computedHash == rootHash;
    }

    // Compute the root hash of the Merkle tree based on the leaf, token ID, and proof provided
    function getRoot(bytes32 leaf, uint256 index, bytes32[] memory proof) public view returns (bytes32) {
        require(proof.length <= 256, "Proof length exceeds limit");

        bytes32 computedHash = leaf;

        for (uint256 i = 0; i < proof.length; i++) {
            bytes32 proofElement = proof[i];

            if (index & (1 << i) == 0) {
                computedHash = keccak256(abi.encodePacked(computedHash, proofElement));
            } else {
                computedHash = keccak256(abi.encodePacked(proofElement, computedHash));
            }
        }

        return computedHash;
    }

    // Set the default hashes for the Merkle tree nodes between the specified start and end indexes
    function setDefaultHashes(uint256 start, uint256 end, bytes32[] memory hashes) public {
        require(start <= end && end < defaultHashes.length, "Invalid start or end index");
        require(hashes.length == end - start + 1, "Invalid hashes length");

        for (uint256 i = start; i <= end; i++) {
            defaultHashes[i] = hashes[i - start];
        }
    }
}
