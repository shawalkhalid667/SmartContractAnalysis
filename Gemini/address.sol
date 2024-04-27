pragma solidity ^0.8.0;

contract AddressUtility {

  // Function to check if an address is a contract
  function isContract(address addr) public view returns (bool) {
    uint256 size;
    assembly { size := extcodesize(addr) }
    return size > 0;
  }

  // Function to send value (ether) to a payable address securely
  function sendValue(address payable recipient, uint256 amount) public payable {
    require(msg.value >= amount, "Insufficient funds for transfer");
    (bool success, ) = recipient.call{value: amount}("");
    require(success, "Transfer failed");
  }

  // Function to perform a function call on a contract
  function functionCall(address target, bytes memory data) public returns (bytes memory) {
    (bool success, bytes memory returnData) = target.call(data);
    require(success, "Function call failed");
    return returnData;
  }

  // Function to perform a function call on a contract with value transfer
  function functionCallWithValue(address target, bytes memory data, uint256 value) public payable returns (bytes memory) {
    (bool success, bytes memory returnData) = target.call{value: value}(data);
    require(success, "Function call failed");
    return returnData;
  }
}
