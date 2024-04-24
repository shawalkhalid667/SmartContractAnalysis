pragma solidity ^ 0.8.0;

interface IFlexibleStorage {

    // View Functions
    function getUIntValue(address contractAddress, bytes32 record) external view returns (uint);
    function getUIntValues(address contractAddress, bytes32[] calldata records) external view returns (uint[] memory);
    function getIntValue(address contractAddress, bytes32 record) external view returns (int);
    function getIntValues(address contractAddress, bytes32[] calldata records) external view returns (int[] memory);
    function getAddressValue(address contractAddress, bytes32 record) external view returns (address);
    function getAddressValues(address contractAddress, bytes32[] calldata records) external view returns (address[] memory);
    function getBoolValue(address contractAddress, bytes32 record) external view returns (bool);
    function getBoolValues(address contractAddress, bytes32[] calldata records) external view returns (bool[] memory);
    function getBytes32Value(address contractAddress, bytes32 record) external view returns (bytes32);
    function getBytes32Values(address contractAddress, bytes32[] calldata records) external view returns (bytes32[] memory);

    // Mutative Functions
    function deleteUIntValue(address contractAddress, bytes32 record) external;
    function deleteIntValue(address contractAddress, bytes32 record) external;
    function deleteAddressValue(address contractAddress, bytes32 record) external;
    function deleteBoolValue(address contractAddress, bytes32 record) external;
    function deleteBytes32Value(address contractAddress, bytes32 record) external;
    function setUIntValue(address contractAddress, bytes32 record, uint value) external;
    function setUIntValues(address contractAddress, bytes32[] calldata records, uint[] calldata values) external;
    function setIntValue(address contractAddress, bytes32 record, int value) external;
    function setIntValues(address contractAddress, bytes32[] calldata records, int[] calldata values) external;
    function setAddressValue(address contractAddress, bytes32 record, address value) external;
    function setAddressValues(address contractAddress, bytes32[] calldata records, address[] calldata values) external;
    function setBoolValue(address contractAddress, bytes32 record, bool value) external;
    function setBoolValues(address contractAddress, bytes32[] calldata records, bool[] calldata values) external;
    function setBytes32Value(address contractAddress, bytes32 record, bytes32 value) external;
    function setBytes32Values(address contractAddress, bytes32[] calldata records, bytes32[] calldata values) external;
}
