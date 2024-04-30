
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract FundsRecovery is Ownable, ReentrancyGuard {
    // The address where recovered funds will be sent to.
    address private _fundsDestination;

    // Emitted when the funds destination is updated.
    event DestinationChanged(address indexed previousDestination, address indexed newDestination);

    constructor(address fundsDestination_) {
        require(fundsDestination_ != address(0), "FundsRecovery: destination is the zero address");
        _fundsDestination = fundsDestination_;
    }

    // Allows the owner to set a new destination address for recovered funds.
    function setFundsDestination(address newDestination) external onlyOwner {
        require(newDestination != address(0), "FundsRecovery: new destination is the zero address");
        emit DestinationChanged(_fundsDestination, newDestination);
        _fundsDestination = newDestination;
    }

    // Retrieves the current funds destination address.
    function getFundsDestination() external view returns (address) {
        return _fundsDestination;
    }

    // Transfers native coins sent to the contract to the funds destination.
    function claimNativeCoin() external onlyOwner nonReentrant {
        uint256 balance = address(this).balance;
        payable(_fundsDestination).transfer(balance);
    }

    // Transfers selected tokens held by the contract to the funds destination.
    function claimTokens(IERC20 token) external onlyOwner nonReentrant {
        uint256 balance = token.balanceOf(address(this));
        token.transfer(_fundsDestination, balance);
    }
}
