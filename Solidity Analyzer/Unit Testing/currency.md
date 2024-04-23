# Unit Testing Currency Contract

Solidity contract `CurrencyComparison` along with its unit tests written using Remix IDE's Solidity unit testing plugin.


3. **Interpreting the Results**:
    - If all tests pass, you'll see a message indicating that all tests have passed.
    - If any test fails, you'll see an error message indicating the reason for the failure along with the expected and received values.

## Error Highlighted

In the failed test case "Dai should be greater than ETH", the expected value is that Dai (an ERC20 token) should be greater than ETH (native currency). However, the test failed, which suggests that there might be an issue with the currency comparison logic in the contract.

