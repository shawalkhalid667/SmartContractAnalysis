pragma solidity ^ 0.8.0;

interface IFlexibleStorage {
  // View functions to retrieve data
  function getUIntValue(address contractAddress, bytes32 record) external view returns (uint256);
  function getUIntValues(address contractAddress, bytes32[] memory records) external view returns (uint256[] memory);

  function getIntValue(address contractAddress, bytes32 record) external view returns (int256);
  function getIntValues(address contractAddress, bytes32[] memory records) external view returns (int256[] memory);

  function getAddressValue(address contractAddress, bytes32 record) external view returns (address);
  function getAddressValues(address contractAddress, bytes32[] memory records) external view returns (address[] memory);

  function getBoolValue(address contractAddress, bytes32 record) external view returns (bool);
  function getBoolValues(address contractAddress, bytes32[] memory records) external view returns (bool[] memory);

  function getBytes32Value(address contractAddress, bytes32 record) external view returns (bytes32);
  function getBytes32Values(address contractAddress, bytes32[] memory records) external view returns (bytes32[] memory);

  // Mutative functions to update data
  function deleteUIntValue(address contractAddress, bytes32 record) external;
  function deleteIntValue(address contractAddress, bytes32 record) external;
  function deleteAddressValue(address contractAddress, bytes32 record) external;
  function deleteBoolValue(address contractAddress, bytes32 record) external;
  function deleteBytes32Value(address contractAddress, bytes32 record) external;

  function setUIntValue(address contractAddress, bytes32 record, uint256 value) external;
  function setUIntValues(address contractAddress, bytes32[] memory records, uint256[] memory values) external;

  function setIntValue(address contractAddress, bytes32 record, int256 value) external;
  function setIntValues(address contractAddress, bytes32[] memory records, int256[] memory values) external;

  function setAddressValue(address contractAddress, bytes32 record, address value) external;
  function setAddressValues(address contractAddress, bytes32[] memory records, address[] memory values) external;

  function setBoolValue(address contractAddress, bytes32 record, bool value) external;
  function setBoolValues(address contractAddress, bytes32[] memory records, bool[] memory values) external;

  function setBytes32Value(address contractAddress, bytes32 record, bytes32 value) external;
  function setBytes32Values(address contractAddress, bytes32[] memory records, bytes32[] memory values) external;
}
