pragma solidity ^0.8.0;

library Assert {
  event LogAssertion(string message, bool success);

  // String comparison functions
  function equalString(string memory a, string memory b) public {
    bool success = keccak256(abi.encodePacked(a)) == keccak256(abi.encodePacked(b));
    emit LogAssertion("String equality assertion", success);
    require(success, "String comparison failed");
  }

  function notEqualString(string memory a, string memory b) public {
    bool success = keccak256(abi.encodePacked(a)) != keccak256(abi.encodePacked(b));
    emit LogAssertion("String inequality assertion", success);
    require(success, "String comparison failed");
  }

  // Bytes32 comparison functions
  function equalBytes32(bytes32 a, bytes32 b) public {
    bool success = a == b;
    emit LogAssertion("Bytes32 equality assertion", success);
    require(success, "Bytes32 comparison failed");
  }

  function notEqualBytes32(bytes32 a, bytes32 b) public {
    bool success = a != b;
    emit LogAssertion("Bytes32 inequality assertion", success);
    require(success, "Bytes32 comparison failed");
  }

  // Address comparison functions
  function equalAddress(address a, address b) public {
    bool success = a == b;
    emit LogAssertion("Address equality assertion", success);
    require(success, "Address comparison failed");
  }

  function notEqualAddress(address a, address b) public {
    bool success = a != b;
    emit LogAssertion("Address inequality assertion", success);
    require(success, "Address comparison failed");
  }

  // Empty value checks
  function isEmptyString(string memory a) public {
    bool success = bytes(a).length == 0;
    emit LogAssertion("Empty string check", success);
    require(success, "String is not empty");
  }

  function isEmptyBytes32(bytes32 a) public {
    bool success = a == bytes32(0);
    emit LogAssertion("Empty bytes32 check", success);
    require(success, "Bytes32 is not empty");
  }

  // Integer comparison functions
  function equalUint(uint a, uint b) public {
    bool success = a == b;
    emit LogAssertion("Unsigned integer equality assertion", success);
    require(success, "Unsigned integer comparison failed");
  }

  function notEqualUint(uint a, uint b) public {
    bool success = a != b;
    emit LogAssertion("Unsigned integer inequality assertion", success);
    require(success, "Unsigned integer comparison failed");
  }

  function equalInt(int a, int b) public {
    bool success = a == b;
    emit LogAssertion("Signed integer equality assertion", success);
    require(success, "Signed integer comparison failed");
  }

  function notEqualInt(int a, int b) public {
    bool success = a != b;
    emit LogAssertion("Signed integer inequality assertion", success);
    require(success, "Signed integer comparison failed");
  }

  function isZero(uint a) public {
    bool success = a == 0;
    emit LogAssertion("Zero value check", success);
    require(success, "Value is not zero");
  }

  // Array comparison functions (focus on uint, int, and address)
  function equalUintArray(uint[] memory a, uint[] memory b) public {
    require(a.length == b.length, "Array length mismatch");
    bool success = true;
    for (uint i = 0; i < a.length; i++) {
      if (a[i] != b[i]) {
        success = false;
        break;
      }
    }
    emit LogAssertion("Uint array equality assertion", success);
    require(success, "Uint array comparison failed");
  }

  function equalIntArray(int[] memory a, int[] memory b) public {
    require(a.length == b.length, "Array length mismatch");
    bool success = true;
    for (uint i = 0; i < a.length; i++) {
      if (a[i] != b[i])
