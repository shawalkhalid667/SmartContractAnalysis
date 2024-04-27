
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

// Define the interface for the Conference contract
interface IConference is IERC721 {
    event Register(address indexed participant);
    event Finalize(uint[] maps);
    event Withdraw(address indexed participant, uint amount);
    event Cancel();
    event GrantAdmin(address indexed admin);
    event RevokeAdmin(address indexed admin);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event UpdateParticipantLimit(uint limit);

    function register() external payable;
    function withdraw() external;
    function finalize(uint[] calldata maps) external;
    function cancel() external;
    function setParticipantLimit(uint _limit) external;
    function grantAdmin(address _admin) external;
    function revokeAdmin(address _admin) external;
    function transferOwnership(address newOwner) external;
    function getParticipantLimit() external view returns (uint);
    function getTotalRegistred() external view returns (uint);
    function getBalance() external view returns (uint);
    function isRegistered(address _participant) external view returns (bool);
    function isAdmin(address _admin) external view returns (bool);
    function isFinalized() external view returns (bool);
    function isCancelled() external view returns (bool);
    function getDeposit() external view returns (uint);
    function getEventName() external view returns (string memory);
    function getPayout() external view returns (uint);
    function getAttendance() external view returns (uint);
    function getWithdrawn() external view returns (uint);
    function token() external view returns (address);
}

// The actual Conference contract
contract Conference is Ownable, IConference {
    // Define your variables, mappings, and arrays
    // ...

    // Implement your functions
    // ...
}
