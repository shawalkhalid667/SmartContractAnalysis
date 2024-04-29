// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

library Address {
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");
        (bool success, bytes memory returndata) = target.call(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

library EnumerableSet {
    struct Set {
        bytes32[] _values;
        mapping(bytes32 => uint256) _indexes;
    }

    function _add(Set storage set, bytes32 value) internal returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    function _remove(Set storage set, bytes32 value) internal returns (bool) {
        uint256 valueIndex = set._indexes[value];
        if (valueIndex != 0) {
            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;
            bytes32 lastvalue = set._values[lastIndex];

            set._values[toDeleteIndex] = lastvalue;
            set._indexes[lastvalue] = toDeleteIndex + 1; 
            set._values.pop();
            delete set._indexes[value];
            return true;
        } else {
            return false;
        }
    }

    function _contains(Set storage set, bytes32 value) internal view returns (bool) {
        return set._indexes[value] != 0;
    }

    function _length(Set storage set) internal view returns (uint256) {
        return set._values.length;
    }

    function _at(Set storage set, uint256 index) internal view returns (bytes32) {
        require(index < set._values.length, "EnumerableSet: index out of bounds");
        return set._values[index];
    }
}

library EnumerableMap {
    struct MapEntry {
        bytes32 _key;
        bytes32 _value;
    }

    struct Map {
        MapEntry[] _entries;
        mapping(bytes32 => uint256) _indexes;
    }

    function _set(Map storage map, bytes32 key, bytes32 value) internal returns (bool) {
        uint256 keyIndex = map._indexes[key];
        if (keyIndex == 0) {
            map._entries.push(MapEntry({_key: key, _value: value}));
            map._indexes[key] = map._entries.length;
            return true;
        } else {
            map._entries[keyIndex - 1]._value = value;
            return false;
        }
    }

    function _remove(Map storage map, bytes32 key) internal returns (bool) {
        uint256 keyIndex = map._indexes[key];
        if (keyIndex != 0) {
            uint256 toDeleteIndex = keyIndex - 1;
            uint256 lastIndex = map._entries.length - 1;
            MapEntry storage lastEntry = map._entries[lastIndex];

            map._entries[toDeleteIndex] = lastEntry;
            map._indexes[lastEntry._key] = toDeleteIndex + 1; 
            map._entries.pop();
            delete map._indexes[key];
            return true;
        } else {
            return false;
        }
    }

    function _contains(Map storage map, bytes32 key) internal view returns (bool) {
        return map._indexes[key] != 0;
    }

    function _length(Map storage map) internal view returns (uint256) {
        return map._entries.length;
    }

    function _at(Map storage map, uint256 index) internal view returns (bytes32, bytes32) {
        require(index < map._entries.length, "EnumerableMap: index out of bounds");
        MapEntry storage entry = map._entries[index];
        return (entry._key, entry._value);
    }

    function get(Map storage map, bytes32 key) internal view returns (bytes32) {
        return map._entries[map._indexes[key] - 1]._value;
    }
}

library Math {
    function log10(uint256 x) internal pure returns (uint256) {
        require(x > 0, "Math: invalid input");
        uint256 result = 0;
        while (x >= 10) {
            result += 1;
            x /= 10;
        }
        return result;
    }
}

library Strings {
    function toString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }
}

interface ITNT165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

interface ITNT721 is ITNT165 {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    function balanceOf(address owner) external view returns (uint256 balance);
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
    function transferFrom(address from, address to, uint256 tokenId) external;
    function approve(address to, uint256 tokenId) external;
    function getApproved(uint256 tokenId) external view returns (address operator);
    function setApprovalForAll(address operator, bool _approved) external;
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}

interface ITNT721Metadata is ITNT721 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function tokenURI(uint256 tokenId) external view returns (string memory);
}

interface ITNT721Enumerable is ITNT721 {
    function totalSupply() external view returns (uint256);
    function tokenByIndex(uint256 index) external view returns (uint256);
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);
}

interface ITNT721Receiver {
    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4);
}

abstract contract TNT165 is ITNT165 {
    bytes4 private constant _INTERFACE_ID_TNT165 = 0x01ffc9a7;

    function supportsInterface(bytes4 interfaceId) external view override returns (bool) {
        return interfaceId == _INTERFACE_ID_TNT165;
    }
}

contract TNT721 is Context, ITNT721, ITNT721Metadata, ITNT721Enumerable {
    using SafeMath for uint256;
    using Address for address;
    using EnumerableSet for EnumerableSet.Set;
    using EnumerableMap for EnumerableMap.Map;
    using Strings for uint256;

    // TNT721 Token Mapping
    mapping(uint256 => address) private _tokenOwners;
    mapping(uint256 => address) private _tokenApprovals;
    mapping(address => EnumerableSet.Set) private _ownedTokens;
    EnumerableMap.Map private _tokenURIs;

    // TNT721 Token Metadata
    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    // TNT721 Token Metadata Functions
    function name() external view override returns (string memory) {
        return _name;
    }

    function symbol() external view override returns (string memory) {
        return _symbol;
    }

    function tokenURI(uint256 tokenId) external view override returns (string memory) {
        require(_exists(tokenId), "TNT721: URI query for nonexistent token");
        return _tokenURIs.get(tokenId);
    }

    // TNT721 Token Ownership Functions
    function balanceOf(address owner) external view override returns (uint256) {
        require(owner != address(0), "TNT721: balance query for the zero address");
        return _ownedTokens[owner]._length();
    }

    function ownerOf(uint256 tokenId) external view override returns (address) {
        address owner = _tokenOwners[tokenId];
        require(owner != address(0), "TNT721: owner query for nonexistent token");
        return owner;
    }

    function _exists(uint256 tokenId) internal view returns (bool) {
        return _tokenOwners[tokenId] != address(0);
    }

    // TNT721 Token Transfer Functions
    function safeTransferFrom(address from, address to, uint256 tokenId) external override {
        _safeTransfer(from, to, tokenId, "");
    }

    function transferFrom(address from, address to, uint256 tokenId) external override {
        _transfer(from, to, tokenId);
    }

    function approve(address to, uint256 tokenId) external override {
        address owner = ownerOf(tokenId);
        require(to != owner, "TNT721: approval to current owner");
        require(_msgSender() == owner || isApprovedForAll(owner, _msgSender()), "TNT721: approve caller is not owner nor approved for all");
        _tokenApprovals[tokenId] = to;
        emit Approval(owner, to, tokenId);
    }

    function getApproved(uint256 tokenId) external view override returns (address) {
        require(_exists(tokenId), "TNT721: approved query for nonexistent token");
        return _tokenApprovals[tokenId];
    }

    function setApprovalForAll(address operator, bool approved) external override {
        require(operator != _msgSender(), "TNT721: approve to caller");
        _operatorApprovals[_msgSender()][operator] = approved;
        emit ApprovalForAll(_msgSender(), operator, approved);
    }

    function isApprovedForAll(address owner, address operator) public view override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    // Internal TNT721 Token Transfer Functions
    function _transfer(address from, address to, uint256 tokenId) internal {
        require(ownerOf(tokenId) == from, "TNT721: transfer of token that is not own");
        require(to != address(0), "TNT721: transfer to the zero address");

        _tokenApprovals[tokenId] = address(0);
        _ownedTokens[from]._remove(tokenId);
        _ownedTokens[to]._add(tokenId);
        _tokenOwners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    function _safeTransfer(address from, address to, uint256 tokenId, bytes memory _data) internal {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "TNT721: transfer to non ERC721Receiver implementer");
    }

    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory _data) private returns (bool) {
        if (!to.isContract()) {
            return true;
        }
        bytes4 retval = ITNT721Receiver(to).onERC721Received(_msgSender(), from, tokenId, _data);
        return (retval == _ERC721_RECEIVED);
    }

    // Enumerable TNT721 Token Functions
    function totalSupply() external view override returns (uint256) {
        return _tokenURIs._length();
    }

    function tokenByIndex(uint256 index) external view override returns (uint256) {
        (bytes32 tokenId, ) = _tokenURIs._at(index);
        return uint256(tokenId);
    }

    function tokenOfOwnerByIndex(address owner, uint256 index) external view override returns (uint256) {
        require(index < balanceOf(owner), "TNT721: owner index out of bounds");
        return uint256(_ownedTokens[owner]._at(index));
    }
}

contract CoolNFT is TNT721 {
    constructor() TNT721("CoolNFT", "CNFT") {
        _mint(msg.sender);
    }

    function _mint(address to) internal {
        uint256 tokenId = totalSupply().add(1);
        _tokenOwners[tokenId] = to;
        _ownedTokens[to]._add(tokenId);
        _tokenURIs._set(tokenId, bytes32(uint256(tokenId).toString()));
        emit Transfer(address(0), to, tokenId);
    }
}
