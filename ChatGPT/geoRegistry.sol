pragma solidity ^0.8.0;

contract GeoRegistry {
    struct Zone {
        bool enabled;
        mapping(bytes => bool) subZones; // Mapping to store sub-zones identified by geohash characters
    }
    
    mapping(bytes32 => Zone) public zones; // Mapping to store zones identified by unique zone codes
    
    event ZoneActivation(bytes32 zoneCode);
    event SubZoneAdded(bytes32 zoneCode, bytes geohash);
    
    modifier onlyEnabledZone(bytes32 zoneCode) {
        require(zones[zoneCode].enabled, "Zone is not enabled");
        _;
    }
    
    function createZone(bytes32 zoneCode, bytes[] memory geohashes) external {
        require(!zones[zoneCode].enabled, "Zone already exists");
        Zone storage newZone = zones[zoneCode];
        for (uint i = 0; i < geohashes.length; i++) {
            newZone.subZones[geohashes[i]] = true;
            emit SubZoneAdded(zoneCode, geohashes[i]);
        }
    }
    
    function activateZone(bytes32 zoneCode) external {
        require(!zones[zoneCode].enabled, "Zone already activated");
        zones[zoneCode].enabled = true;
        emit ZoneActivation(zoneCode);
    }
    
    function isSubZone(bytes32 zoneCode, bytes memory geohash) public view onlyEnabledZone(zoneCode) returns (bool) {
        return zones[zoneCode].subZones[geohash];
    }
    
    function batchAddSubZones(bytes32 zoneCode, bytes[] memory geohashes) external onlyEnabledZone(zoneCode) {
        for (uint i = 0; i < geohashes.length; i++) {
            zones[zoneCode].subZones[geohashes[i]] = true;
            emit SubZoneAdded(zoneCode, geohashes[i]);
        }
    }
    
    function isValidGeohash(bytes memory geohash) public pure returns (bool) {
        // Implement geohash validation logic here
        return true; // Placeholder logic
    }
}
