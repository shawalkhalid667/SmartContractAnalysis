// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract FundsRecovery is Ownable, ReentrancyGuard {
    address public fundsDestination;

    event DestinationChanged(address indexed newDestination);

    constructor(address _initialOwner, address _initialDestination) Ownable(_initialOwner) {
        fundsDestination = _initialDestination;
    }

    function setFundsDestination(address _newDestination) external onlyOwner {
        require(_newDestination != address(0), "Invalid destination address");
        fundsDestination = _newDestination;
        emit DestinationChanged(_newDestination);
    }

    function getFundsDestination() external view returns (address) {
        return fundsDestination;
    }

    function claimNativeCoin() external nonReentrant onlyOwner {
        payable(fundsDestination).transfer(address(this).balance);
    }

    function claimTokens(address _token) external nonReentrant onlyOwner {
        require(_token != address(0), "Invalid token address");
        require(_token != address(this), "Cannot claim native token");

        IERC20 token = IERC20(_token);
        uint256 balance = token.balanceOf(address(this));
        require(balance > 0, "No tokens to claim");

        require(token.transfer(fundsDestination, balance), "Token transfer failed");
    }
}
