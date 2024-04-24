
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

    struct WordRange {
        uint8 minLength;
        uint8 maxLength;
    }

    BitMaps.BitMap private _forbiddenWordMap;

    constructor() initializer {} // Disable initializers

    function initialize(address admin, WordRange calldata wordRange) external override initializer {
        _setupRole(DEFAULT_ADMIN_ROLE, admin);
        _setWordRange(wordRange);
    }

    function getWordRange() external view override returns (WordRange memory) {
        return WordRange({ minLength: _forbiddenWordMap._start, maxLength: _forbiddenWordMap._end });
    }

    function setWordRange(WordRange calldata wordRange) external override onlyRole(DEFAULT_ADMIN_ROLE) {
        _setWordRange(wordRange);
    }

    function forbidden(string calldata name) external view override returns (bool) {
        return containsBlacklistedWord(name) || containsInvalidCharacter(name);
    }

    function containsBlacklistedWord(string calldata name) public view override returns (bool) {
        return pack(name) & _forbiddenWordMap._data != 0;
    }

    function containsInvalidCharacter(string calldata name) public view override returns (bool) {
        bytes memory nameBytes = bytes(name);
        for (uint i = 0; i < nameBytes.length; i++) {
            if (!_isAlphabet(nameBytes[i]) && !_isNumber(nameBytes[i])) {
                return true;
            }
        }
        return false;
    }

    function pack(string calldata name) public pure override returns (uint256) {
        return LibSubString.pack(name);
    }

    function packBulk(string[] calldata names) external pure override returns (uint256[] memory) {
        uint256[] memory packedNames = new uint256[](names.length);
        for (uint i = 0; i < names.length; i++) {
            packedNames[i] = pack(names[i]);
        }
        return packedNames;
    }

    function setForbiddenWords(uint256[] calldata packedWords) external override onlyRole(DEFAULT_ADMIN_ROLE) {
        _setForbiddenWords(packedWords);
    }

    function totalSubString(string calldata name) external view override returns (uint256) {
        WordRange memory range = getWordRange();
        return LibSubString.totalSubString(name, range.minLength, range.maxLength);
    }

    function getAllSubStrings(string calldata name) external view override returns (string[] memory) {
        WordRange memory range = getWordRange();
        return LibSubString.getAllSubStrings(name, range.minLength, range.maxLength);
    }

    function _setForbiddenWords(uint256[] calldata packedWords) internal {
        for (uint i = 0; i < packedWords.length; i++) {
            _forbiddenWordMap.set(packedWords[i]);
        }
    }

    function _setWordRange(WordRange calldata wordRange) internal {
        require(wordRange.minLength > 0 && wordRange.maxLength > wordRange.minLength, "Invalid word range");
        _forbiddenWordMap._start = wordRange.minLength;
        _forbiddenWordMap._end = wordRange.maxLength;
    }
        function _isAlphabet(bytes1 char) internal pure returns (bool) {
    return (char >= 'a' && char <= 'z') || (char >= 'A' && char <= 'Z');
    }

    function _isNumber(byte char) internal pure returns (bool) {
        return char >= '0' && char <= '9';
    }
}
