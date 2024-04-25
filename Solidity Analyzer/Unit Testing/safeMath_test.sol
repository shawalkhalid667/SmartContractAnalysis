// SPDX-License-Identifier: GPL-3.0
        
pragma solidity >=0.4.22 <0.9.0;

// This import is automatically injected by Remix
import "remix_tests.sol"; 

// This import is required to use custom transaction context
// Although it may fail compilation in 'Solidity Compiler' plugin
// But it will work fine in 'Solidity Unit Testing' plugin
import "remix_accounts.sol";
import "../contracts/chat.sol";

// File name has to end with '_test.sol', this file can contain more than one testSuite contracts
contract MathLibraryExampleTest {

    MathLibraryExample mathLibraryExample;

    function beforeAll() public {
        mathLibraryExample = new MathLibraryExample();
    }

    function testSafeMath() public {
        (uint256 sum, uint256 product) = mathLibraryExample.testSafeMath(5, 6);
        
        Assert.equal(sum, 11, "Sum calculation incorrect");
        Assert.equal(product, 30, "Product calculation incorrect");
    }

    function testSafeMath32() public {
        (uint32 sum, uint32 product) = mathLibraryExample.testSafeMath32(100, 10);
        
        Assert.equal(sum, 110, "Sum calculation incorrect");
        Assert.equal(product, 1000, "Product calculation incorrect");
    }

    function testSafeMath16() public {
        (uint16 sum, uint16 product) = mathLibraryExample.testSafeMath16(20, 4);
        
        Assert.equal(sum, 24, "Sum calculation incorrect");
        Assert.equal(product, 80, "Product calculation incorrect");
    }

    /// Custom Transaction Context: https://remix-ide.readthedocs.io/en/latest/unittesting.html#customization
    /// #sender: account-1
    /// #value: 100
    function checkSenderAndValue() public payable {
        // account index varies 0-9, value is in wei
        Assert.equal(msg.sender, TestsAccounts.getAccount(1), "Invalid sender");
        Assert.equal(msg.value, 100, "Invalid value");
    }
}
