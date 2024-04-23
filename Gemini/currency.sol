// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IERC20Minimal {
  function balanceOf(address account) external view returns (uint256);
  function transfer(address recipient, uint256 amount) external returns (bool);
  function approve(address spender, uint256 amount) external returns (bool);
  function allowance(address owner, address spender) external view returns (uint256);
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

enum Currency {
  NATIVE_CURRENCY,
  ERC20
}

struct CurrencyValue {
  uint256 amount;
}

library CurrencyLibrary {
  function isNative(Currency currency) internal pure returns (bool) {
    return currency == Currency.NATIVE_CURRENCY;
  }

  function toId(Currency currency) internal pure returns (bytes32) {
    return keccak256(abi.encodePacked(currency));
  }

  function fromId(bytes32 id) internal pure returns (Currency) {
    return Currency(uint8(uint256(id)));
  }

  function transfer(Currency currency, address from, address to, uint256 amount) internal {
    if (isNative(currency)) {
      // Safe native currency transfer with assembly for efficiency
      assembly {
        if eq(call(gas(), gasprice(), to, amount, 0, 0, 0)) {
          // Revert if native currency transfer fails
          revert(0, 0)
        }
      }
    } else {
      // ERC20 token transfer using minimal interface
      IERC20Minimal(payable(address(currency))).transfer(to, amount);
      require(IERC20Minimal(payable(address(currency))).transfer(to, amount), "ERC20 token transfer failed");
    }
  }

  function balanceOf(Currency currency, address account) internal view returns (uint256) {
    if (isNative(currency)) {
      // Native currency balance (cast to uint256 for compatibility)
      return uint256(address(account).balance);
    } else {
      // ERC20 token balance using minimal interface
      return IERC20Minimal(payable(address(currency))).balanceOf(account);
    }
  }
}

contract MyCurrencyContract {
  // ... other contract logic (can include functions like convertErc20ToEth)

  function compareCurrencies(Currency currency1, CurrencyValue memory value1, Currency currency2, CurrencyValue memory value2) public view returns (bool) {
    if (currency1 == currency2) {
      // Simple comparison for same currencies
      return value1.amount >= value2.amount;
    } else if (currency1 == Currency.NATIVE_CURRENCY) {
      // Convert ERC20 value to ETH equivalent for comparison
      uint256 ethValue2 = convertErc20ToEth(currency2, value2.amount); // Implement conversion function here (not shown)
      return value1.amount >= ethValue2;
    } else {
      // Convert ETH value to ERC20 equivalent for comparison (revert on failure)
      revert("Unsupported currency conversion for comparison");
    }
  }
}
