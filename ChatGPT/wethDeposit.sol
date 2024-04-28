// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface WETH {
    function approve(address spender, uint256 amount) external returns (bool);
    function deposit() external payable;
}

interface Exchange {
    function user_deposit_to_session(uint64 user_id, uint32 exchange_id, uint256 amount) external;
}

contract WethDeposit {
    WETH public weth;
    Exchange public exchange;
    address public owner;

    constructor(address _wethAddress, address _exchangeAddress) {
        weth = WETH(_wethAddress);
        exchange = Exchange(_exchangeAddress);
        owner = msg.sender;
        
        // Approve the exchange contract to spend WETH tokens
        weth.approve(_exchangeAddress, type(uint256).max);
    }

    function deposit(uint64 user_id, uint32 exchange_id) external payable {
        require(msg.value % 10 ether == 0, "Deposit amount must be a multiple of 10 ETH");
        uint256 depositAmount = msg.value;

        // Deposit WETH tokens to exchange's session
        weth.deposit{value: depositAmount}();
        exchange.user_deposit_to_session(user_id, exchange_id, depositAmount);
    }

    // Fallback function to reject any Ether sent directly to the contract
    receive() external payable {
        revert("This contract does not accept direct Ether transfers");
    }

    // Withdraw function to retrieve accidentally sent Ether
    function withdraw() external {
        require(msg.sender == owner, "Only the owner can withdraw");
        payable(msg.sender).transfer(address(this).balance);
    }
}
