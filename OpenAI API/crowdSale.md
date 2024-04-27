Prompt for CrowdsaleConfig Contract (crowdsale.sol):
Crowdsale Configuration Constants:

Develop the CrowdsaleConfig contract in Solidity, which serves as the repository for all constants used in the SelfKeyCrowdsale contract. These constants include configurations related to token supply, distribution, pricing, caps, and wallet addresses.
Token Decimals and Minimum Token Unit:

Define the constants for TOKEN_DECIMALS and MIN_TOKEN_UNIT, which are essential for handling the token decimals and minimum token value in the crowdsale contract. Be sure to set the correct decimal value as per the token standard.
Token Supply Cap and Sale Cap:

Specify the TOTAL_SUPPLY_CAP and SALE_CAP constants, representing the total token supply cap and the cap for the initial sale of tokens, respectively. These values help in managing the token distribution during the crowdsale.
Purchaser Caps and Pricing:

Set the minimum and maximum token caps per purchaser during the public sale, along with the token pricing information. Define the minimum token cap, maximum token caps for different phases, and the corresponding token prices in USD.
Token Allocations and Founders' Distribution:

Allocate tokens for various purposes such as foundation pool, community pool, founders, and legal expenses. Include details on the vested tokens for certain allocations and the distribution percentages for each pool.
Contract Wallet Addresses and Allocations:

Specify the wallet addresses for the crowdsale, foundation pool, community pool, founders' pool, and legal expenses. These addresses will receive the allocated tokens based on the defined distribution plan.
Vesting Period and Legal Expenses:

Define the vesting period duration in seconds for certain token allocations, such as pre-commitment half-vesting for founders. Ensure that the vesting schedule aligns with the token distribution plan.
Event Logging and Address Verification:

Implement events for key contract actions like ownership transfer, registration, finalization, withdrawals, cancellations, and limit updates. Define functions for transferring ownership and granting/reviewing admin permissions.
Usability and Readability:

Structure the CrowdsaleConfig contract in a clear and organized manner to facilitate usability, readability, and maintainability. Use meaningful names for variables and functions to enhance code comprehension.
Deployment and Verification:

Prepare the contract for deployment on the desired Ethereum network by ensuring proper testing and verification of the configurations and constants included in the CrowdsaleConfig contract.
