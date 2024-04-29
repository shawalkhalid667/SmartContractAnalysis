
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/interfaces/IAaveLendingPool.sol";
import "@openzeppelin/contracts/interfaces/IAaveDataProviders.sol";

contract MyV2CreditDelegation is ERC721, Ownable {
    using SafeMath for uint256;

    IAaveLendingPool public lendingPool;
    IAaveDataProviders public dataProvider;
    
    mapping(address => uint256) private _collaterals;
    mapping(address => uint256) private _borrowBalances;
    uint256 private _borrowRateMultiplier;

    constructor(address _lendingPool, address _dataProvider, uint256 _borrowRateMultiplier) ERC721("MyV2CreditDelegation", "MVCD") {
        lendingPool = IAaveLendingPool(_lendingPool);
        dataProvider = IAaveDataProviders(_dataProvider);
        _borrowRateMultiplier = _borrowRateMultiplier;
    }

    function depositCollateral(address asset, uint256 amount) external {
        lendingPool.deposit(asset, amount, address(this), 0);
        _collaterals[asset] = _collaterals[asset].add(amount);
    }

    function withdrawCollateral(address asset) external onlyOwner {
        require(_borrowBalances[asset] == 0, "Outstanding loan exists");
        uint256 amount = _collaterals[asset];
        _collaterals[asset] = 0;
        lendingPool.withdraw(asset, amount, msg.sender);
    }

    function requestCredit(address asset, uint256 amount) external {
        require(ownerOf(msg.sender) > 0, "Not a valid NFT holder");
        lendingPool.borrow(asset, amount, 1, 0, address(this));
        _borrowBalances[asset] = _borrowBalances[asset].add(amount);
    }

    function repayLoan(address asset, uint256 amount) external {
        lendingPool.repay(asset, amount, 1, address(this));
        _borrowBalances[asset] = _borrowBalances[asset].sub(amount);
    }

    function checkBalance(address asset) external view returns (uint256) {
        return _borrowBalances[asset];
    }
}
