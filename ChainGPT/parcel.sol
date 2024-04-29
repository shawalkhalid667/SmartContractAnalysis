
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract Parcel is ERC721, Ownable {
    using Strings for uint256;

    struct BoundingBox {
        uint256 x;
        uint256 y;
        uint256 z;
        uint256 width;
        uint256 height;
        uint256 depth;
    }

    mapping(uint256 => BoundingBox) private _boundingBoxes;
    mapping(uint256 => string) private _tokenURIs;
    mapping(uint256 => uint256) private _tokenPrices;

    event SetPrice(uint256 indexed tokenId, uint256 price);

    constructor() ERC721("Cryptovoxels Parcel", "CVPA") {}

    function mint(address to, BoundingBox memory boundingBox, uint256 price) public onlyOwner {
        uint256 tokenId = totalSupply() + 1; // Generate a new tokenId
        _mint(to, tokenId); // Mint the new token
        _boundingBoxes[tokenId] = boundingBox; // Set the bounding box
        _setTokenPrice(tokenId, price); // Set the token price
    }

    function burn(uint256 tokenId) public onlyOwner {
        _burn(tokenId); // Burn the token
        delete _boundingBoxes[tokenId]; // Delete bounding box
        delete _tokenURIs[tokenId]; // Delete token URI
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }

    function buy(uint256 tokenId) public payable {
        uint256 price = _tokenPrices[tokenId];
        require(msg.value >= price, "Not enough Ether provided");
        _transfer(owner(), msg.sender, tokenId); // Transfer ownership to the buyer
        _setTokenPrice(tokenId, 0); // Set the token price to 0
    }

    function setPrice(uint256 tokenId, uint256 price) public onlyOwner {
        _setTokenPrice(tokenId, price);
    }

    function getPrice(uint256 tokenId) public view returns (uint256) {
        return _tokenPrices[tokenId];
    }

    function setContentURI(uint256 tokenId, string memory contentURI) public onlyOwner {
        _tokenURIs[tokenId] = contentURI;
    }

    function contentURI(uint256 tokenId) public view returns (string memory) {
        return _tokenURIs[tokenId];
    }

    function _setTokenPrice(uint256 tokenId, uint256 price) private {
        _tokenPrices[tokenId] = price;
        emit SetPrice(tokenId, price);
    }
}
