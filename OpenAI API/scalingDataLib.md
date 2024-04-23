Prompt for Creating a Smart Contract Library for Scaling Transaction Data in DeFi Operations:

Create a Solidity library named ScalingDataLib targeting the Solidity version ^0.8.25 that facilitates the scaling of transaction data across various DeFi protocols during operations such as swaps, liquidity provision, or other transactional actions. This library should dynamically adjust transaction data based on new amounts derived from changes in conditions or strategy modifications. Incorporate utility functions that handle scaling for several predefined types of transactions related to popular DeFi protocols. Each function should:

General Structure:

Start with the SPDX License Identifier set to MIT.
Omit any external imports for the purpose of this prompt, assuming the existence of interface IExecutorHelperStruct which provides structured definitions for transaction types across various protocols.
Core Functionalities:

Include a suite of functions dedicated to adjusting transaction data for a variety of DeFi operations, including but not limited to Uniswap swaps, StableSwap transactions, CurveSwap transactions, and more based on a specified schema found within the supposed IExecutorHelperStruct.
Each function should accept two primary parameters: the original transaction data in bytes, indicating the current transaction details, and two uint256 values indicating the oldAmount and the newAmount for scaling. The output should be the scaled transaction data in bytes.
Scaling Logic:

Implement internal pure functions for each DeFi operation that manipulate the transaction data by:
Decoding the input data into the respective structure as defined by IExecutorHelperStruct.
Adjusting the relevant amount fields (collectAmount, dx, etc.) in the transaction data using the formula (amount * newAmount) / oldAmount to scale the transaction size.
Re-encoding the modified structure back into bytes format to be utilized in transaction execution.
Focus on Popular DeFi Protocols:

Ensure functions are included for operations like:
newUniSwap, newStableSwap, newCurveSwap, newKyberDMM, newUniV3ProMM, newBalancerV2, newDODO, and so on, covering a wide array of platforms such as Uniswap, Balancer, Curve, DODO, among others.
Optionally, add functionalities for lesser-known or emerging protocols to enhance the library's applicability.
Safety and Efficiency:

Emphasize safety in arithmetic operations possibly leveraging Solidity ^0.8's built-in overflow checks.
Prioritize efficient memory usage and computational efficiency in how data is decoded, manipulated, and encoded.
Documentation and Comments:

Alongside each function, provide comprehensive NatSpec comments explaining the purpose, parameters, return values, and any special considerations or limitations.
Include examples of use cases or potential integration patterns within DeFi smart contracts that could leverage this library for managing dynamic transaction data.
Test Cases and Verification:

Outline a basic framework for testing these functions, ensuring that scaling operations are performed accurately without data corruption or unintended side effects.
Discuss potential edge cases in scaling transaction data and how they are handled or mitigated by the library's design.
Finish your creation by reiterating the value of having such a library within the DeFi ecosystem, especially for protocols or platforms that need to dynamically adjust transaction parameters in response to market conditions, user inputs, or protocol-specific requirements without manually reconfiguring or redeploying smart contracts.
