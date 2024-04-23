## Objective: 
Write a Solidity smart contract for a multi-signature wallet, enabling multiple parties to agree before executing transactions. Refer to the provided example to guide the development process, taking into account the specified features and requirements.

## Background: 
A multi-signature wallet is essential for enhancing security in transactions by requiring multiple approvals from designated owners before any funds can be moved. This is particularly useful for managing collective funds, ensuring that no single individual has unilateral control over transactions.

## Specifications:

Initialization:

The smart contract should allow the specification of wallet owners and the number of confirmations required for a transaction to execute, both set at deployment.
Owners must be unique and non-zero addresses. The required confirmations should not exceed the number of owners and must be at least one.
Deposit Functionality:

The contract should accept deposits from any address and emit a corresponding event detailing the sender address, deposit amount, and the new wallet balance.
Transaction Submission:

Allow wallet owners to submit transactions. A transaction consists of the recipient's address, value to transfer, and optional data (for calling other contract functions).
Emit an event for each transaction submission, including transaction details and its index.
Transaction Confirmation:

Enable owners to confirm submitted transactions by referencing their index.
A transaction must exist and not already be executed or confirmed by the calling owner to accept a new confirmation.
Emit an event for each transaction confirmation.
Transaction Execution:

Upon reaching the required number of confirmations, allow the transaction to be executed.
Ensure that transactions are only executed once and emit an event upon execution.
Handle potential execution failures gracefully.
Confirmation Revocation:

Permit owners to revoke their confirmations for a pending transaction, adjusting the confirmation count accordingly and emitting an event.
Utility Functions:

Include functions to retrieve the list of owners, the count of transactions, and specific transaction details by index.
Access Control:

Implement checks to ensure only wallet owners can submit, confirm, execute, or revoke transactions.
Validate the existence and execution status of transactions for relevant operations.
Additional Notes:

Use events extensively to provide transparency over wallet activities.
Ensure the contract adheres to the specified Solidity version (^0.5.17) and employs best practices for security and efficiency.
Consider edge cases, such as input validation and protection against common vulnerabilities.

## Deliverables:

A Solidity smart contract fulfilling the above requirements with well-documented code.
Test cases demonstrating the functionality and security of the contract.
