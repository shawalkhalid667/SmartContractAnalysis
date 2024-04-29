
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// Helper library
library Helpers {
    function contains(address[] memory array, address value) internal pure returns(bool) {
        for(uint i = 0; i < array.length; i++) {
            if(array[i] == value) {
                return true;
            }
        }
        return false;
    }

    function uintToString(uint v) internal pure returns (string memory str) {
        uint maxlength = 100;
        bytes memory reversed = new bytes(maxlength);
        uint i = 0;
        while (v != 0) {
            uint remainder = v % 10;
            v = v / 10;
            reversed[i++] = bytes1(uint8(48 + remainder));
        }
        bytes memory s = new bytes(i); // i is the length of the output string
        for (uint j = 0; j < i; j++) {
            s[j] = reversed[i - 1 - j]; // reverse
        }
        str = string(s);  // finally convert to string
    }
}

// MessageSigning library
library MessageSigning {
    function recoverAddress(bytes32 message, uint8 v, bytes32 r, bytes32 s) internal pure returns (address) {
        bytes32 prefixedHash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", message));
        return ecrecover(prefixedHash, v, r, s);
    }

    function hashMessage(address recipient, uint value, bytes32 transactionHash, uint gasPrice) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(recipient, value, transactionHash, gasPrice));
    }
}

// Message library
library Message {
    function getRecipient(bytes memory message) internal pure returns (address) {
        return address(uint160(uint256(load(message, 20))));
    }

    function getValue(bytes memory message) internal pure returns (uint) {
        return uint256(load(message, 52));
    }

    function getTransactionHash(bytes memory message) internal pure returns (bytes32) {
        return bytes32(load(message, 84));
    }

    function getGasPrice(bytes memory message) internal pure returns (uint) {
        return uint256(load(message, 116));
    }

    function load(bytes memory data, uint start) internal pure returns (bytes32) {
        require(data.length >= start + 32, "Message: OUT_OF_BOUNDS");
        bytes32 temp;
        assembly {
            temp := mload(add(add(data, 32), start))
        }
        return temp;
    }
}

// BridgeDeploymentAddressStorage contract
contract BridgeDeploymentAddressStorage {
    uint public deploymentBlock;

    constructor() {
        deploymentBlock = block.number;
    }
}

// HomeBridge contract
contract HomeBridge {
    // Implementation goes here
}

// ForeignBridge contract
contract ForeignBridge {
    // Implementation goes here
}

// ERC20 interface
interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
}
