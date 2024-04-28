
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract WethDeposit {
    using SafeMath for uint256;

    IERC20 public wethToken;
    address public exchangeContract;

    // The constructor reads the function signature hash for approve(address, uint256) 
    // and constructs a call to the WETH contract to give approval for transferring tokens.
    constructor(address _wethToken, address _exchangeContract) {
        wethToken = IERC20(_wethToken);
        exchangeContract = _exchangeContract;
        wethToken.approve(exchangeContract, type(uint256).max);
    }

    // This function allows users to deposit WETH tokens by calling the user_deposit_to_session function on a specified exchange.
    // It captures the incoming value, checks if it's a multiple of 10 ETH to prevent incorrect value deposits.
    function deposit(uint64 user_id, uint32 exchange_id) external payable {
        uint256 amount = msg.value;
        require(amount.mod(10 ether) == 0, "Deposit must be a multiple of 10 ETH");

        // It constructs a call to deposit the received WETH tokens to the specified exchange's session.
        // It passes the user_id, exchange_id, and the calculated deposit amount (derived from the incoming value).
        (bool success, ) = exchangeContract.call(
            abi.encodeWithSignature(
                "user_deposit_to_session(uint64,uint32,uint256)",
                user_id,
                exchange_id,
                amount
            )
        );
        require(success, "Deposit failed");
    }
}
