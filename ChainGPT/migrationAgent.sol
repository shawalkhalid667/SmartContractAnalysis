pragma solidity ^0.8.0;

contract MigrationAgent {
    // Struct for Migration
    struct Migration {
        uint256 id;
        address participant;
        string eosAccountName;
        uint256 amount;
    }

    // State variables
    address public game_address;
    address public token_address;
    uint256 public migration_id;

    // Events
    event Migrated(uint256 id, address participant, uint256 amount, string eosAccountName);
    event NameRegistered(address participant, string eosAccountName);

    // Mappings
    mapping(address => string) public registrations;
    mapping(uint256 => Migration) public migrations;
    mapping(address => uint256[]) public participant_migrations;

    // Register function for participants to register their EOS account names
    function register(string memory eosAccountName) public {
        // Check if participant has already registered
        require(bytes(registrations[msg.sender]).length == 0, "Participant already registered");

        // Update registrations mapping
        registrations[msg.sender] = eosAccountName;

        // Emit NameRegistered event
        emit NameRegistered(msg.sender, eosAccountName);
    }

    // Function to check if a participant has registered their EOS account
    function participantRegistered(address participant) public view returns (bool) {
        return bytes(registrations[participant]).length > 0;
    }

    // MigrateFrom function for participants to initiate migration requests
    function migrateFrom(address participant, uint256 amount) public {
        // Check if the caller is the token_address
        require(msg.sender == token_address, "Caller is not token address");

        // Check if participant has registered
        require(participantRegistered(participant), "Participant not registered");

        // Check if the amount to migrate is above a minimal threshold
        require(amount > 0.0001 ether, "Amount below minimum threshold");

        // Increase the migration_id counter
        migration_id++;

        // Create a new Migration struct
        Migration memory migration = Migration({
            id: migration_id,
            participant: participant,
            eosAccountName: registrations[participant],
            amount: amount
        });

        // Update migrations mapping
        migrations[migration_id] = migration;

        // Update participant_migrations mapping
        participant_migrations[participant].push(migration_id);

        // Emit Migrated event
        emit Migrated(migration_id, participant, amount, registrations[participant]);
    }
}
