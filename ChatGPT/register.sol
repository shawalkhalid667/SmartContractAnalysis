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
        // Initialize network details for different chainIds
        // You can add more entries as needed
        s_networkDetails[1] = NetworkDetails({
            chainSelector: 1,
            routerAddress: 0x1F98431c8aD98523631AE4a59f267346ea31F984, // Example address, replace with actual addresses
            linkAddress: 0x514910771AF9Ca656af840dff83E8264EcF986CA, // Example address, replace with actual addresses
            wrappedNativeAddress: 0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2, // Example address, replace with actual addresses
            ccipBnMAddress: 0x1f9840a85d5af5bf1d1762f925bdaddc4201f984, // Example address, replace with actual addresses
            ccipLnMAddress: 0x1f9840a85d5af5bf1d1762f925bdaddc4201f984 // Example address, replace with actual addresses
        });

        s_networkDetails[137] = NetworkDetails({
            chainSelector: 137,
            routerAddress: 0x1F98431c8aD98523631AE4a59f267346ea31F984, // Example address, replace with actual addresses
            linkAddress: 0x514910771AF9Ca656af840dff83E8264EcF986CA, // Example address, replace with actual addresses
            wrappedNativeAddress: 0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2, // Example address, replace with actual addresses
            ccipBnMAddress: 0x1f9840a85d5af5bf1d1762f925bdaddc4201f984, // Example address, replace with actual addresses
            ccipLnMAddress: 0x1f9840a85d5af5bf1d1762f925bdaddc4201f984 // Example address, replace with actual addresses
        });

        // Add more initializations as needed
    }

    function getNetworkDetails(uint256 chainId) public view returns (NetworkDetails memory) {
        return s_networkDetails[chainId];
    }

    function setNetworkDetails(uint256 chainId, NetworkDetails memory networkDetails) public {
        require(chainId != 0, "Invalid chainId"); // ChainId 0 is reserved for invalid chain
        s_networkDetails[chainId] = networkDetails;
    }
}
