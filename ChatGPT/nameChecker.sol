// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/utils/structs/BitMaps.sol";
import "./libraries/LibSubString.sol";
import "./interfaces/INameChecker.sol";

contract NameChecker is Initializable, AccessControlEnumerable, INameChecker {
    using BitMaps for BitMaps.BitMap;
    using LibSubString for LibSubString.WordRange;

    struct WordRange {
        uint256 min;
        uint256 max;
    }

    BitMaps.BitMap private _forbiddenWordMap;
    WordRange private _wordRange;

    bytes32 public constant DEFAULT_ADMIN_ROLE = keccak256("DEFAULT_ADMIN_ROLE");

    modifier onlyAdmin() {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "Caller is not the admin");
        _;
    }

    function initialize(address admin, uint256 min, uint256 max) external initializer {
        _setupRole(DEFAULT_ADMIN_ROLE, admin);
        _setWordRange(min, max);
    }

    function getWordRange() external view returns (uint256 min, uint256 max) {
        return (_wordRange.min, _wordRange.max);
    }

    function setWordRange(uint256 min, uint256 max) external onlyAdmin {
        _setWordRange(min, max);
    }

    function forbidden(string memory word) external view override returns (bool) {
        return containsInvalidCharacter(word) || containsBlacklistedWord(word);
    }

    function containsBlacklistedWord(string memory word) public view returns (bool) {
        return _forbiddenWordMap.intersects(_packBulk(_getAllSubStrings(word)));
    }

    function containsInvalidCharacter(string memory word) public pure returns (bool) {
        bytes memory wordBytes = bytes(word);
        for (uint256 i = 0; i < wordBytes.length; i++) {
            if (!_isAlphabet(uint8(wordBytes[i])) && !_isNumber(uint8(wordBytes[i]))) {
                return true;
            }
        }
        return false;
    }

    function pack(string memory word) public pure returns (uint256) {
        return LibSubString.pack(word);
    }

    function packBulk(string[] memory words) public pure returns (uint256[] memory) {
        uint256[] memory packedWords = new uint256[](words.length);
        for (uint256 i = 0; i < words.length; i++) {
            packedWords[i] = pack(words[i]);
        }
        return packedWords;
    }

    function setForbiddenWords(uint256[] calldata packedWords, bool status) external onlyAdmin {
        _setForbiddenWords(packedWords, status);
    }

    function totalSubString(string memory word) public view returns (uint256) {
        return _wordRange.totalSubString(word);
    }

    function getAllSubStrings(string memory word) public view returns (string[] memory) {
        return _wordRange.getAllSubStrings(word);
    }

    function _setForbiddenWords(uint256[] memory packedWords, bool status) internal {
        for (uint256 i = 0; i < packedWords.length; i++) {
            if (status) {
                _forbiddenWordMap.set(packedWords[i]);
            } else {
                _forbiddenWordMap.unset(packedWords[i]);
            }
        }
    }

    function _setWordRange(uint256 min, uint256 max) internal {
        require(max >= min, "Invalid word range");
        _wordRange = WordRange(min, max);
    }

    function _isAlphabet(uint8 char) internal pure returns (bool) {
        return (char >= 65 && char <= 90) || (char >= 97 && char <= 122);
    }

    function _isNumber(uint8 char) internal pure returns (bool) {
        return (char >= 48 && char <= 57);
    }
}
