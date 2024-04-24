
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/utils/structs/BitMaps.sol";

library LibSubString {
    function substring(string memory str, uint startIndex, uint endIndex) public pure returns (string memory) {
        bytes memory strBytes = bytes(str);
        bytes memory result = new bytes(endIndex-startIndex);
        for(uint i = 0; i<endIndex-startIndex; i++) {
            result[i] = strBytes[i+startIndex];
        }
        return string(result);
    }
}

// Instead of importing, we have added the interface directly to the code
interface INameChecker {
    function checkName(string calldata name) external view returns (bool);
}

contract NameChecker is Initializable, AccessControlEnumerable, INameChecker {

    using BitMaps for BitMaps.BitMap;
    using LibSubString for LibSubString.WordRange;

    LibSubString.WordRange private _wordRange;
    BitMaps.BitMap private _forbiddenWordMap;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    constructor() {
        // Disabling the initializer so that it can only be called once
        __Context_init_unchained();
        __AccessControlEnumerable_init_unchained();
    }

    function initialize(address admin, uint256 min, uint256 max) public initializer {
        _setupRole(DEFAULT_ADMIN_ROLE, admin);
        _wordRange.min = min;
        _wordRange.max = max;
    }

    function getWordRange() public view returns (uint256, uint256) {
        return (_wordRange.min, _wordRange.max);
    }

    function setWordRange(uint256 min, uint256 max) public {
        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "NameChecker: must have admin role to change word range");
        _wordRange.min = min;
        _wordRange.max = max;
    }

    function forbidden(string memory name) public view returns (bool) {
        return containsInvalidCharacter(name) || containsBlacklistedWord(name);
    }

    function containsBlacklistedWord(string memory name) public view returns (bool) {
        uint256 packed = pack(name);
        return _forbiddenWordMap.get(packed);
    }

    function containsInvalidCharacter(string memory name) public view returns (bool) {
        // implement your own logic
    }

    function pack(string memory name) public pure returns (uint256) {
        // implement your own logic
    }

    function packBulk(string[] memory names) public pure returns (uint256[] memory) {
        // implement your own logic
    }

    function setForbiddenWords(uint256[] memory packedWords, bool forbidden) public {
        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "NameChecker: must have admin role to set forbidden words");
        for (uint256 i = 0; i < packedWords.length; i++) {
            if (forbidden) {
                _forbiddenWordMap.set(packedWords[i]);
            } else {
                _forbiddenWordMap.remove(packedWords[i]);
            }
        }
    }

    function totalSubString(string memory name) public view returns (uint256) {
        // implement your own logic
    }

    function getAllSubStrings(string memory name) public view returns (string[] memory) {
        // implement your own logic
    }

    // Internal helper functions
    function _setForbiddenWords(uint256[] memory packedWords, bool forbidden) internal {
        for (uint256 i = 0; i < packedWords.length; i++) {
            if (forbidden) {
                _forbiddenWordMap.set(packedWords[i]);
            } else {
                _forbiddenWordMap.remove(packedWords[i]);
            }
        }
    }

    function _setWordRange(uint256 min, uint256 max) internal {
        _wordRange.min = min;
        _wordRange.max = max;
    }

    function _isAlphabet(string memory name) internal pure returns (bool) {
        // implement your own logic
    }

    function _isNumber(string memory name) internal pure returns (bool) {
        // implement your own logic
    }
}
