Prompt for Creating a ZeroEx Protocol Governance Smart Contract:

Please write a Solidity smart contract for a decentralized governance system tailored for the ZeroEx Protocol. The contract should include the following features and functionalities:

License Notice: Include an Apache-2.0 license notice at the beginning of the contract file with copyright belonging to ZeroEx Intl.

Solidity Version: The contract should be compatible with Solidity version ^0.8.19.

Necessary Imports:

Import a custom contract named SecurityCouncil.sol for security-related functionalities.
Import a custom contract named ZeroExTimelock.sol for timelock functionalities.
Use OpenZeppelin libraries for governance features, specifically:
@openzeppelin/governance/Governor.sol
@openzeppelin/governance/extensions/GovernorSettings.sol
@openzeppelin/governance/extensions/GovernorCountingSimple.sol
@openzeppelin/governance/extensions/GovernorVotes.sol
@openzeppelin/governance/extensions/GovernorTimelockControl.sol
Contract Inheritance:

The main contract should be named ZeroExProtocolGovernor and inherit from SecurityCouncil, Governor, GovernorSettings, GovernorCountingSimple, GovernorVotes, and GovernorTimelockControl.
Constructor Requirements:

Construct the governance contract with initial parameters for the voting mechanism (IVotes), timelock specifics (ZeroExTimelock), and the Security Council address.
Quorum Function: Define a quorum function that returns the minimum amount of votes needed for proposals to be considered valid.

Functionality Overrides:

Override necessary functions from base contracts to adjust or specify the governance process according to the ZeroEx Protocol needs, including security permissions.
Proposal Management:

Implement functions for managing governance proposals, including creating, canceling, queuing, and executing proposals.
Security Council Management:

Include functionalities for managing a Security Council, emphasizing its role in governance (e.g., assigning, cancelling proposals, and executing rollbacks).
Interface Support:

Implement a function to check if a given interface is supported by the contract.
Your contract should effectively establish a decentralized governance framework for the ZeroEx Protocol with distinct roles, security features, and mechanisms for proposal management that utilize both custom and OpenZeppelin components.
