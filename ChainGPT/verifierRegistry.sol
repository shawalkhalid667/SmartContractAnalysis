
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface Verifier_Registry_Interface {
    // Define events
    event ProofSubmitted(bytes32 indexed proof, uint256 vkId);
    event VerifierKeyRegistered(uint256 vkId, address[] associatedContracts);
    event VerifierContractRegistered(address verifierContract);
    event ProofAttested(bytes32 indexed proof, uint256 vkId, bool result);
    event AttestationChallenged(bytes32 indexed proof, address verifierContract);

    // Verifier Functions
    function getVk(uint256 vkId) external view returns (bytes32);
    function registerVerifierContract(address verifierContract) external;
    function registerVk(bytes32 vk, address[] calldata associatedContracts) external returns (uint256 vkId);
    function challengeAttestation(bytes32 proof, address verifierContract) external;
    function createNewVkId(bytes32 vk) external returns (uint256 vkId);

    // Proof Submission & Verification
    function submitProof(bytes32 proof, bytes32[] calldata inputs, uint256 vkId) external;
    function submitProofAndVerify(bytes32 proof, bytes32[] calldata inputs, uint256 vkId, address verifierContract) external;
    function attestProof(bytes32 proof, uint256 vkId, bool result) external;

    // Batch Operations
    function attestProofs(bytes32[] calldata proofs, uint256[] calldata vkIds, bool[] calldata results) external;
}
