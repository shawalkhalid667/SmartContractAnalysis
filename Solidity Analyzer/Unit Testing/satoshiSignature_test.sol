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
contract chatTest {
    SatoshiSignature private token;

    function beforeAll() public {
        token = new SatoshiSignature("SatoshiSignature", "SAT", 18, 1000000);
    }

    function checkTokenNameSymbolDecimals() public {
        Assert.equal(token.name(), "SatoshiSignature", "Invalid token name");
        Assert.equal(token.symbol(), "SAT", "Invalid token symbol");
        Assert.equal(token.decimals(), 18, "Invalid token decimals");
    }

    function checkTotalSupply() public {
        Assert.equal(token.totalSupply(), 1000000 * 10**18, "Invalid total supply");
    }

    function checkBalanceOfOwner() public {
        Assert.equal(token.balanceOf(address(this)), 1000000 * 10**18, "Invalid balance of owner");
    }

    function checkTransfer() public {
        address recipient = TestsAccounts.getAccount(1);
        uint256 amount = 1000 * 10**18;

        token.transfer(recipient, amount);
        Assert.equal(token.balanceOf(recipient), amount, "Transfer failed");
    }

    function checkApprovalAndTransferFrom() public {
        address spender = TestsAccounts.getAccount(2);
        address recipient = TestsAccounts.getAccount(3);
        uint256 amount = 500 * 10**18;

        token.approve(spender, amount);
        token.transferFrom(address(this), recipient, amount);

        Assert.equal(token.balanceOf(recipient), amount, "TransferFrom failed");
    }

    function checkBurn() public {
        uint256 amount = 100 * 10**18;
        token.burn(amount);
        Assert.equal(token.totalSupply(), 999900 * 10**18, "Burn failed");
    }

    function checkMint() public {
        address recipient = TestsAccounts.getAccount(4);
        uint256 amount = 500 * 10**18;

        token.mint(recipient, amount);
        Assert.equal(token.balanceOf(recipient), amount, "Mint failed");
    }

    function checkSetReflectionFee() public {
        uint256 fee = 5;
        token.setReflectionFee(fee);
        Assert.equal(token.balanceOf(address(this)), 999400 * 10**18, "Reflection fee setting failed");
    }

    function checkStartAndPauseTokenSale() public {
        token.startTokenSale();
        Assert.equal(token.isTokenSaleActive(), true, "Token sale start failed");

        token.pauseTokenSale();
        Assert.equal(token.isTokenSaleActive(), false, "Token sale pause failed");
    }

    function checkAirdrop() public {
        address[] memory recipients = new address[](3);
        recipients[0] = TestsAccounts.getAccount(5);
        recipients[1] = TestsAccounts.getAccount(6);
        recipients[2] = TestsAccounts.getAccount(7);

        uint256[] memory amounts = new uint256[](3);
        amounts[0] = 100 * 10**18;
        amounts[1] = 200 * 10**18;
        amounts[2] = 300 * 10**18;

        token.airdrop(recipients, amounts);

        Assert.equal(token.balanceOf(recipients[0]), 100 * 10**18, "Airdrop failed for recipient 1");
        Assert.equal(token.balanceOf(recipients[1]), 200 * 10**18, "Airdrop failed for recipient 2");
        Assert.equal(token.balanceOf(recipients[2]), 300 * 10**18, "Airdrop failed for recipient 3");
    }
}
