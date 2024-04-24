
pragma solidity ^0.8.0;

library Assert {
    event Assertion(bool success, string message);

    function equal(string memory a, string memory b) internal pure {
        emit Assertion(keccak256(abi.encodePacked(a)) == keccak256(abi.encodePacked(b)), "Strings are not equal");
    }

    function notEqual(string memory a, string memory b) internal pure {
        emit Assertion(keccak256(abi.encodePacked(a)) != keccak256(abi.encodePacked(b)), "Strings are equal");
    }

    function equal(bytes32 a, bytes32 b) internal pure {
        emit Assertion(a == b, "Bytes32 values are not equal");
    }

    function notEqual(bytes32 a, bytes32 b) internal pure {
        emit Assertion(a != b, "Bytes32 values are equal");
    }

    function equal(address a, address b) internal pure {
        emit Assertion(a == b, "Addresses are not equal");
    }

    function notEqual(address a, address b) internal pure {
        emit Assertion(a != b, "Addresses are equal");
    }

    function isEmptyString(string memory a) internal pure {
        emit Assertion(bytes(a).length == 0, "String is not empty");
    }

    function isEmptyBytes32(bytes32 a) internal pure {
        emit Assertion(a == bytes32(0), "Bytes32 value is not empty");
    }

    function isZero(uint256 a) internal pure {
        emit Assertion(a == 0, "Value is not zero");
    }

    function isNotZero(uint256 a) internal pure {
        emit Assertion(a != 0, "Value is zero");
    }

    function compareArrays(uint[] memory a, uint[] memory b) internal pure {
        emit Assertion(a.length == b.length, "Array lengths are not equal");

        for (uint i = 0; i < a.length; i++) {
            emit Assertion(a[i] == b[i], "Array values are not equal");
        }
    }
}
