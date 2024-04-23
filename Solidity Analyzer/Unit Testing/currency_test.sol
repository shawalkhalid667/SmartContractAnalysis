// SPDX-License-Identifier: GPL-3.0
        
pragma solidity >=0.4.22 <0.9.0;

// This import is automatically injected by Remix
import "remix_tests.sol"; 

// This import is required to use custom transaction context
// Although it may fail compilation in 'Solidity Compiler' plugin
// But it will work fine in 'Solidity Unit Testing' plugin
import "remix_accounts.sol";
import "../contracts/chat.sol";

contract CurrencyComparisonTest {
    CurrencyComparison currencyComparison;

    function beforeEach() public {
        currencyComparison = new CurrencyComparison();
    }

    function testComparison() public {
        CurrencyLibrary.Currency memory eth = CurrencyLibrary.Currency(CurrencyLibrary.CurrencyType.NATIVE, address(0));
        CurrencyLibrary.Currency memory dai = CurrencyLibrary.Currency(CurrencyLibrary.CurrencyType.ERC20, address(0x6B175474E89094C44Da98b954EedeAC495271d0F));

        // Test equality
        (bool equal,,,) = currencyComparison.compareCurrencies(eth, eth);
        Assert.equal(equal, true, "Native currencies should be equal");

        // Test greaterThan
        (,,bool greater,) = currencyComparison.compareCurrencies(dai, eth);
        Assert.equal(greater, true, "Dai should be greater than ETH");

        // Test lessThan
        (,,,bool less) = currencyComparison.compareCurrencies(eth, dai);
        Assert.equal(less, true, "ETH should be less than Dai");

        // Test greaterThanOrEqualTo
        (,,,bool greaterOrEqual) = currencyComparison.compareCurrencies(dai, dai);
        Assert.equal(greaterOrEqual, true, "Dai should be greater than or equal to itself");
    }
}
