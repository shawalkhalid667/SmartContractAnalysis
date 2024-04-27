// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface Conference {
    // Events
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event AdminGranted(address indexed admin);
    event AdminRevoked(address indexed admin);
    event ParticipantRegistered(address indexed participant, uint256 amount);
    event EventFinalized(uint256 indexed eventId, address indexed organizer);
    event FundsWithdrawn(address indexed recipient, uint256 amount);
    event EventCanceled(uint256 indexed eventId);
    event ParticipantWithdrawn(address indexed participant, uint256 amount);

    // Owner and Admin Management
    function transferOwnership(address newOwner) external;
    function grantAdmin(address admin) external;
    function revokeAdmin(address admin) external;
    function getAdmins() external view returns (address[] memory);
    function isAdmin(address account) external view returns (bool);

    // Participant Registration and Event Management
    function registerParticipant(uint256 eventId) external payable;
    function finalizeEvent(uint256 eventId) external;
    function withdrawFunds() external;
    function cancelEvent(uint256 eventId) external;
    function withdrawParticipantFunds(uint256 amount) external;

    // Additional Functions
    function setParticipantLimit(uint256 eventId, uint256 limit) external;
    function getParticipantLimit(uint256 eventId) external view returns (uint256);
    function getTokenAddress() external view returns (address);

    // Interaction Security and Compliance
    function checkParticipantRegistration(uint256 eventId, address participant) external view returns (bool);
    function checkParticipantAttendance(uint256 eventId, address participant) external view returns (bool);
    function checkParticipantPayment(uint256 eventId, address participant) external view returns (uint256);

    // ENS Integration
    function resolveENS(string calldata name) external view returns (address);
    function setENSResolver(address resolver) external;

    // Testing and Deployment Procedures
    function testFunctionality() external pure;
    function deployToEthereumNetwork() external;
}
