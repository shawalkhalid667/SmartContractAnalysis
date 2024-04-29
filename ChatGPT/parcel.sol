// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Parcel is ERC721, Ownable {
    using Strings for uint256;

    // Library for string operations
    library Strings {
        function toString(uint256 value) internal pure returns (string memory) {
            if (value == 0) {
                return "0";
            }
            uint256 temp = value;
            uint256 digits;
            while (temp != 0) {
                digits++;
                temp /= 10;
            }
            bytes memory buffer = new bytes(digits);
            while (value != 0) {
                digits -= 1;
                buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
                value /= 10;
            }
            return string(buffer);
        }
    }

    struct BoundingBox {
        uint256 x1;
        uint256 y1;
        uint256 z1;
        uint256 x2;
        uint256 y2;
        uint256 z2;
    }

    struct ParcelData {
        BoundingBox boundingBox;
        string contentURI;
        uint256 tokenPrice;
    }

    mapping(uint256 => ParcelData) parcels;

    event SetPrice(uint256 indexed tokenId, uint256 price);

    constructor() ERC721("Cryptovoxels Parcel", "CVPA") {
        _mint(msg.sender, 1); // Mint initial token to contract creator
    }

    function mint(address to, uint256 tokenId, uint256 x1, uint256 y1, uint256 z1, uint256 x2, uint256 y2, uint256 z2, string memory contentURI, uint256 tokenPrice) external onlyOwner {
        _mint(to, tokenId);
        parcels[tokenId] = ParcelData(BoundingBox(x1, y1, z1, x2, y2, z2), contentURI, tokenPrice);
    }

    function burn(uint256 tokenId) external onlyOwner {
        _burn(tokenId);
        delete parcels[tokenId];
    }

    function takeOwnership() external onlyOwner {
        transferOwnership(owner());
    }

    function buy(uint256 tokenId) external payable {
        require(ownerOf(tokenId) == owner(), "Parcel: owner can only sell");
        require(msg.value >= parcels[tokenId].tokenPrice, "Parcel: insufficient funds");

        address seller = owner();
        address payable buyer = payable(msg.sender);

        _transfer(seller, buyer, tokenId);
        parcels[tokenId].tokenPrice = 0;

        if (msg.value > parcels[tokenId].tokenPrice) {
            uint256 refundAmount = msg.value - parcels[tokenId].tokenPrice;
            buyer.transfer(refundAmount);
        }
    }

    function setPrice(uint256 tokenId, uint256 price) external onlyOwner {
        parcels[tokenId].tokenPrice = price;
        emit SetPrice(tokenId, price);
    }

    function getPrice(uint256 tokenId) external view returns (uint256) {
        return parcels[tokenId].tokenPrice;
    }

    function setContentURI(uint256 tokenId, string memory contentURI) external onlyOwner {
        parcels[tokenId].contentURI = contentURI;
    }

    function getContentURI(uint256 tokenId) external view returns (string memory) {
        return parcels[tokenId].contentURI;
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory baseURI = "https://api.cryptovoxels.com/parcel/";
        return string(abi.encodePacked(baseURI, tokenId.toString()));
    }
}
