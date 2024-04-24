
// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.25;

contract Register {
    struct NetworkDetails {
        uint64 chainSelector;
        address routerAddress;
        address linkAddress;
        address wrappedNativeAddress;
        address ccipBnMAddress;
        address ccipLnMAddress;
    }

    mapping(uint256 => NetworkDetails) internal s_networkDetails;

    constructor() {
        // Initialize NetworkDetails for different chainIds
        s_networkDetails[1] = NetworkDetails({
            chainSelector: 1,
            routerAddress: address(0x123456789ABCDEF),
            linkAddress: address(0xABCDEF123456789),
            wrappedNativeAddress: address(0x9876543210FEDCB),
            ccipBnMAddress: address(0xFEDCBA098765432),
            ccipLnMAddress: address(0x4567890ABCDEF12)
        });

        s_networkDetails[137] = NetworkDetails({
            chainSelector: 137,
            routerAddress: address(0x9876543210FEDCB),
            linkAddress: address(0xFEDCBA098765432),
            wrappedNativeAddress: address(0x4567890ABCDEF12),
            ccipBnMAddress: address(0x123456789ABCDEF),
            ccipLnMAddress: address(0xABCDEF123456789)
        });

        // Add more NetworkDetails for different chainIds here
    }

    function getNetworkDetails(uint256 chainId) public view returns (NetworkDetails memory) {
        return s_networkDetails[chainId];
    }

    function setNetworkDetails(uint256 chainId, NetworkDetails memory networkDetails) public {
        s_networkDetails[chainId] = networkDetails;
    }
}
