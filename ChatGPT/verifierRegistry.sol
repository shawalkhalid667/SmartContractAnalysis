// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface Verifier_Registry_Interface {

    // Events
    event ProofSubmitted(address indexed submitter, bytes proofData, bytes inputs, bytes32 vkId);
    event VerifierKeyRegistered(bytes32 vkId, address indexed verifierContract);
    event VerifierKeyRegisteredWithContract(bytes32 vkId, address indexed verifierContract);
    event ProofAttested(bytes32 vkId, bool result);
    event ProofChallenged(bytes32 vkId, bytes proofDetails, address indexed verifierContract);
    
    // Verifier Functions
    function getVk(bytes32 vkId) external view returns (bytes memory);
    function registerVerifierContract(address verifierContract) external;
    function registerVk(bytes32 vkId, address[] calldata verifierContracts) external;
    function challengeAttestation(bytes32 vkId, bytes calldata proofDetails, address verifierContract) external;
    function createNewVkId(bytes memory verifierKey) external view returns (bytes32);

    // Proof Submission & Verification
    function submitProof(bytes calldata proofData, bytes calldata inputs, bytes32 vkId) external;
    function submitProofAndVerify(bytes calldata proofData, bytes calldata inputs, bytes32 vkId, address verifierContract) external;
    function attestProof(bytes32 vkId, bool result) external;

    // Batch Operations
    function attestProofs(bytes32[] calldata vkIds, bool[] calldata results) external;
}
