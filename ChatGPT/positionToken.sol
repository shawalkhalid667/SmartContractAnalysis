// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface PositionToken {
    function mintWithToken(address receiver, address depositTokenAddress, uint256 depositAmount, uint256 maxPriceAllowed) external;
    function burnToToken(address receiver, address burnTokenAddress, uint256 burnAmount, uint256 minPriceAllowed) external;
    function tokenPrice() external view returns (uint256);
    function liquidationPrice() external view returns (uint256);
    function currentLeverage() external view returns (uint256);
    function decimals() external view returns (uint8);
    function balanceOf(address account) external view returns (uint256);
}

contract YourContract {
    PositionToken positionTokenContract;
    
    constructor(address _positionTokenContractAddress) {
        positionTokenContract = PositionToken(_positionTokenContractAddress);
    }
    
    function mintPositionTokens(address receiver, address depositTokenAddress, uint256 depositAmount, uint256 maxPriceAllowed) external {
        positionTokenContract.mintWithToken(receiver, depositTokenAddress, depositAmount, maxPriceAllowed);
    }
    
    function burnPositionTokens(address receiver, address burnTokenAddress, uint256 burnAmount, uint256 minPriceAllowed) external {
        positionTokenContract.burnToToken(receiver, burnTokenAddress, burnAmount, minPriceAllowed);
    }
    
    function getTokenPrice() external view returns (uint256) {
        return positionTokenContract.tokenPrice();
    }
    
    function getLiquidationPrice() external view returns (uint256) {
        return positionTokenContract.liquidationPrice();
    }
    
    function getCurrentLeverage() external view returns (uint256) {
        return positionTokenContract.currentLeverage();
    }
    
    function getDecimals() external view returns (uint8) {
        return positionTokenContract.decimals();
    }
    
    function getBalanceOf(address account) external view returns (uint256) {
        return positionTokenContract.balanceOf(account);
    }
}
