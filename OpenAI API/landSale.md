Smart Contract Prompt: LandSale.sol

You are tasked with implementing a timed, refundable crowdsale contract for the sale of land.
The crowdsale will have tiered pricing based on the type of land being sold.
The contract must support the purchase of villages, towns, and cities with different pricing structures for each type.
Users can purchase land using Ethereum or other payment methods such as credit cards.
Refunds can be claimed if the crowdsale is unsuccessful.
Contract Architecture:
Ownable Contract:

The Ownable contract manages the ownership of the contract, allowing for basic authorization control.
It ensures that certain functions can only be called by the contract owner.
SafeMath Library:

The SafeMath library provides mathematical operations with safety checks to prevent overflows and underflows.
RefundVault Contract:

This contract is responsible for storing funds during the crowdsale.
It supports refunding funds if the crowdsale fails and forwarding funds if it succeeds.
LandSale Contract:

The main contract for the land crowdsale.
It includes functions for purchasing villages, towns, and cities with tiered pricing.
Users can purchase land using Ethereum or credit cards.
The contract handles goal tracking, refund processing, and finalization of the crowdsale.
Contract Functions:
Modifiers:

onlyWhileOpen: Ensures that certain functions can only be called during the crowdsale period.
Constructor:

Initializes the crowdsale with the goal amount, opening and closing times, and wallet address to collect funds.
Purchase Functions:

purchaseVillage, purchaseTown, purchaseCity: Allows users to purchase villages, towns, and cities respectively.
Users can purchase multiple units of land at the current price.
The contract tracks the number of each land type sold and updates user holdings.
Other Purchase Functions:

purchaseLandWithCC: Allows the owner to record land purchases made using credit cards for audit purposes.
Pricing Functions:

villagePrice, townPrice, cityPrice: Calculate the current price of villages, towns, and cities based on the number sold.
Admin Functions:

pause, resume: Owner can pause and resume land purchases during the crowdsale.
isPaused: Check if the purchase of land is currently paused.
hasClosed: Check if the crowdsale period has ended.
Refund and Finalization Functions:

claimRefund: Investors can claim refunds if the crowdsale is unsuccessful.
goalReached: Check if the funding goal was reached.
finalize: Finalize the crowdsale, either closing the vault or enabling refunds based on the outcome.
Events:
The contract emits events for each land purchase, credit card purchase, and finalization of the crowdsale.
