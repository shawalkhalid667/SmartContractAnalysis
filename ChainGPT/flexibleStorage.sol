
pragma solidity >=0.8.0;

interface IFlexibleStorage {
    function getUIntValue(address contractAddress, bytes32 record) external view returns (uint256);
    function getUIntValues(address contractAddress, bytes32[] calldata records) external view returns (uint256[] memory);
    function getIntValue(address contractAddress, bytes32 record) external view returns (int256);
    function getIntValues(address contractAddress, bytes32[] calldata records) external view returns (int256[] memory);
    function getAddressValue(address contractAddress, bytes32 record) external view returns (address);
    function getAddressValues(address contractAddress, bytes32[] calldata records) external view returns (address[] memory);
    function getBoolValue(address contractAddress, bytes32 record) external view returns (bool);
    function getBoolValues(address contractAddress, bytes32[] calldata records) external view returns (bool[] memory);
    function getBytes32Value(address contractAddress, bytes32 record) external view returns (bytes32);
    function getBytes32Values(address contractAddress, bytes32[] calldata records) external view returns (bytes32[] memory);
}
