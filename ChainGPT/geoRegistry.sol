solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

contract GeoRegistry {
    using EnumerableSet for EnumerableSet.Bytes32Set;

    // We use bytes32 to represent a geohash for efficient storage.
    struct Zone {
        bytes32 geohash;
        bool enabled;
    }

    // A mapping from zone code to Zone struct.
    mapping(bytes32 => Zone) public zones;

    // A mapping from a zone code to its sub-zones.
    mapping(bytes32 => EnumerableSet.Bytes32Set) private subZones;

    // Event emitted when a new zone is created.
    event ZoneCreated(bytes32 indexed zoneCode, bytes32 geohash);

    // Event emitted when a zone is enabled.
    event ZoneEnabled(bytes32 indexed zoneCode);

    // Event emitted when a sub-zone is added to a zone.
    event SubZoneAdded(bytes32 indexed zoneCode, bytes32 subZoneGeohash);

    // Create a new zone with a unique code and geohash.
    function createZone(bytes32 zoneCode, bytes32 geohash) public {
        require(zones[zoneCode].geohash == bytes32(0), "Zone code already exists");
        zones[zoneCode] = Zone(geohash, false);
        emit ZoneCreated(zoneCode, geohash);
    }

    // Enable a zone for use.
    function enableZone(bytes32 zoneCode) public {
        require(zones[zoneCode].geohash != bytes32(0), "Zone code does not exist");
        zones[zoneCode].enabled = true;
        emit ZoneEnabled(zoneCode);
    }

    // Add a sub-zone to a zone.
    function addSubZone(bytes32 zoneCode, bytes32 subZoneGeohash) public {
        require(zones[zoneCode].geohash != bytes32(0), "Zone code does not exist");
        require(zones[zoneCode].enabled, "Zone is not enabled");
        require(subZoneGeohash != bytes32(0), "Invalid sub-zone geohash");
        require(subZones[zoneCode].add(subZoneGeohash), "Sub-zone already exists");
        emit SubZoneAdded(zoneCode, subZoneGeohash);
    }

    // Check if a zone contains a sub-zone.
    function containsSubZone(bytes32 zoneCode, bytes32 subZoneGeohash) public view returns (bool) {
        require(zones[zoneCode].geohash != bytes32(0), "Zone code does not exist");
        return subZones[zoneCode].contains(subZoneGeohash);
    }
}
