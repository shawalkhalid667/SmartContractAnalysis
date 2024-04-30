
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract Trustcoin is ERC20, Ownable, ReentrancyGuard {
    // The address that has the power to set migration information
    address private migrationInfoSetter;

    // The migration information event
    event MigrationInfoSet(string newInfo);

    constructor() ERC20("Trustcoin", "TRST") {
        // Set the decimals, initial supply and the owner of the initial supply
        _setupDecimals(6);
        _mint(msg.sender, 100000000 * (10 ** uint256(decimals())));
        // Set the deployer as the initial migrationInfoSetter
        migrationInfoSetter = msg.sender;
    }

    // Only allow the migrationInfoSetter to call certain functions
    modifier onlyMigrationInfoSetter() {
        require(migrationInfoSetter == msg.sender, "Caller is not the migrationInfoSetter");
        _;
    }

    // Allows to set new migration information
    function setMigrationInfo(string memory newInfo) public onlyMigrationInfoSetter {
        emit MigrationInfoSet(newInfo);
    }

    // Allows to change the migrationInfoSetter
    function changeMigrationInfoSetter(address newSetter) public onlyOwner {
        migrationInfoSetter = newSetter;
    }

    // Override the transfer function to include the nonReentrant modifier
    function transfer(address recipient, uint256 amount) public override nonReentrant returns (bool) {
        return super.transfer(recipient, amount);
    }

    // Override the transferFrom function to include the nonReentrant modifier
    function transferFrom(address sender, address recipient, uint256 amount) public override nonReentrant returns (bool) {
        return super.transferFrom(sender, recipient, amount);
    }
}
