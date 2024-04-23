## Prompt for Creating a Contract to Handle Game Asset Migration:

Write a Solidity smart contract named MigrationAgent that facilitates the migration of game assets for participants to a new platform, specifically targeting the EOS blockchain. The contract should define a migration process where participants can register their EOS account names and initiate asset transfer requests. Include the following specifications and functionalities:

Solidity Version: Set the contract to be compatible with Solidity version ^0.4.0.

State Variables and Struct:

Define a Migration struct with properties for an identifier (id), participant address, EOS account name, and the amount to be migrated.
Declare a game_address to specify the game contract's address.
Initialize a public token_address representing the address from which tokens will be migrated.
Maintain a migration_id counter to uniquely identify each migration.
Events:

Create an event Migrated that logs each migration request, including ID, participant address, amount, and EOS account name.
Add an event NameRegistered to log when a participant successfully registers their EOS account name.
Mappings:

Implement a mapping named registrations to track participant addresses to their registered EOS account names.
Use a mapping named migrations to associate migration IDs with Migration struct instances.
Include a mapping participant_migrations to correlate participant addresses with an array of their migration requests.
Functions:

Write a migrateFrom function allowing participants to initiate migration requests. Ensure it validates:
The caller is the token_address.
The participant has registered.
The amount to migrate is above a minimal threshold (e.g., 0.0001 ether).
If conditions are met, log the migration event and update mappings accordingly.
Implement a register function where participants can register their EOS account names. This should update the registrations mapping and emit a NameRegistered event if successful.
Add a participantRegistered function to check whether a given participant has registered their EOS account.
Constraints and Checks:

Incorporate necessary validations to reject unauthorized or invalid migration and registration requests.
Use Solidity programming constructs appropriate for version ^0.4.0, including var declarations and constant functions.
