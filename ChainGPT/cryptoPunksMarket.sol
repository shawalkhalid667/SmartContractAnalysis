pragma solidity ^0.8.0;

contract CryptoPunksMarket { address public creator;

struct Punk {
    address owner;
    uint256 minPrice;
    bool forSale;
    address bidder;
    uint256 bidAmount;
}

mapping(uint256 => Punk) public punks;
mapping(address => uint256[]) public ownedPunks;

constructor() {
    creator = msg.sender;
}

modifier onlyCreator() {
    require(msg.sender == creator, "You are not the creator of this contract");
    _;
}

function setInitialOwner(uint256 punkId, address owner) public onlyCreator {
    punks[punkId].owner = owner;
    ownedPunks[owner].push(punkId);
}

function setInitialOwners(uint256[] calldata punkIds, address[] calldata owners) public onlyCreator {
    require(punkIds.length == owners.length, "Arrays length must be equal");
    
    for (uint256 i = 0; i < punkIds.length; i++) {
        setInitialOwner(punkIds[i], owners[i]);
    }
}

function getPunk(uint256 punkId) public {
    require(punks[punkId].owner == address(0), "Punk is already owned");
    
    punks[punkId].owner = msg.sender;
    ownedPunks[msg.sender].push(punkId);
}

function transferPunk(uint256 punkId, address to) public {
    require(punks[punkId].owner == msg.sender, "You are not the owner of this punk");
    
    punks[punkId].owner = to;
    
    // Update ownedPunks mapping
    uint256[] storage ownerPunks = ownedPunks[msg.sender];
    for (uint256 i = 0; i < ownerPunks.length; i++) {
        if (ownerPunks[i] == punkId) {
            ownerPunks[i] = ownerPunks[ownerPunks.length - 1];
            ownerPunks.pop();
            break;
        }
    }
    
    ownedPunks[to].push(punkId);
}

function offerPunkForSale(uint256 punkId, uint256 minPrice) public {
    require(punks[punkId].owner == msg.sender, "You are not the owner of this punk");
    
    punks[punkId].minPrice = minPrice;
    punks[punkId].forSale = true;
}

function offerPunkForSaleToAddress(uint256 punkId, uint256 minPrice, address to) public {
    offerPunkForSale(punkId, minPrice);
    punks[punkId].bidder = to;
}

function buyPunk(uint256 punkId) payable public {
    require(punks[punkId].forSale, "Punk is not for sale");
    require(msg.value >= punks[punkId].minPrice, "Not enough Ether sent");
    
    address owner = punks[punkId].owner;
    uint256 price = punks[punkId].minPrice;
    
    punks[punkId].owner = msg.sender;
    punks[punkId].forSale = false;
    ownedPunks[owner].push(punkId);
    
    payable(owner).transfer(price);
    
    if (msg.value > price) {
        payable(msg.sender).transfer(msg.value - price);
    }
}

function withdraw() public {
    uint256 balance = address(this).balance;
    require(balance > 0, "Contract balance is zero");
    
    payable(msg.sender).transfer(balance);
}

function enterBidForPunk(uint256 punkId) payable public {
    require(punks[punkId].owner != msg.sender, "You already own this punk");
    require(msg.value > punks[punkId].bidAmount, "Amount is less than current bid");
    
    punks[punkId].bidAmount = msg.value;
    punks[punkId].bidder = msg.sender;
}

function acceptBidForPunk(uint256 punkId) public {
    require(punks[punkId].owner == msg.sender, "You are not the owner of this punk");
    
    address bidder = punks[punkId].bidder;
    uint256 amount = punks[punkId].bidAmount;
    
    punks[punkId].owner = bidder;
    punks[punkId].forSale = false;
    ownedPunks[msg.sender].push(punkId);
    
    punks[punkId].bidAmount = 0;
    punks[punkId].bidder = address(0);
    
    payable(msg.sender).transfer(amount);
}

function withdrawBidForPunk(uint256 punkId) public {
    require(punks[punkId].bidder == msg.sender, "You are not the bidder for this punk");
    
    uint256 amount = punks[punkId].bidAmount;
    punks[punkId].bidAmount = 0;
    punks[punkId].bidder = address(0);
    
    payable(msg.sender).transfer(amount);
}
}
