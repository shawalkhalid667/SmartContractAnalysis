pragma solidity ^0.8.0;

contract CryptoPunksMarket {
    struct Punk {
        address owner;
        uint256 price;
        address bidder;
        uint256 bid;
    }

    mapping(uint256 => Punk) public punks;
    mapping(address => uint256[]) public ownedPunks;
    mapping(address => uint256) public balances;

    event PunkTransfer(uint256 indexed punkIndex, address indexed from, address indexed to, uint256 price);
    event PunkOffered(uint256 indexed punkIndex, uint256 price, address indexed toAddress);
    event PunkBidEntered(uint256 indexed punkIndex, uint256 value, address indexed from);
    event BidWithdrawn(uint256 indexed punkIndex, uint256 value, address indexed from);
    event PunkBought(uint256 indexed punkIndex, uint256 price, address indexed from, address indexed to);
    event BidAccepted(uint256 indexed punkIndex, uint256 price, address indexed from, address indexed to);

    function setInitialOwner(uint256 punkIndex, address to) external {
        require(msg.sender == address(this), "Only contract owner can assign initial owners");
        _transfer(address(0), to, punkIndex);
    }

    function setInitialOwners(uint256[] memory punkIndices, address[] memory toAddresses) external {
        require(msg.sender == address(this), "Only contract owner can assign initial owners");
        require(punkIndices.length == toAddresses.length, "Array lengths must match");
        for (uint256 i = 0; i < punkIndices.length; i++) {
            _transfer(address(0), toAddresses[i], punkIndices[i]);
        }
    }

    function getPunk(uint256 punkIndex) external {
        require(punks[punkIndex].owner == address(0), "Punk already owned");
        _transfer(address(0), msg.sender, punkIndex);
    }

    function transferPunk(address to, uint256 punkIndex) external {
        require(punks[punkIndex].owner == msg.sender, "You don't own this punk");
        _transfer(msg.sender, to, punkIndex);
    }

    function offerPunkForSale(uint256 punkIndex, uint256 minPrice) external {
        require(punks[punkIndex].owner == msg.sender, "You don't own this punk");
        punks[punkIndex].price = minPrice;
        emit PunkOffered(punkIndex, minPrice, address(0));
    }

    function offerPunkForSaleToAddress(uint256 punkIndex, uint256 minPrice, address to) external {
        require(punks[punkIndex].owner == msg.sender, "You don't own this punk");
        punks[punkIndex].price = minPrice;
        emit PunkOffered(punkIndex, minPrice, to);
    }

    function buyPunk(uint256 punkIndex) external payable {
        Punk memory punk = punks[punkIndex];
        require(punk.price > 0, "Punk not for sale");
        require(msg.value >= punk.price, "Insufficient funds");
        _transfer(punk.owner, msg.sender, punkIndex);
        punk.owner.transfer(punk.price);
        emit PunkBought(punkIndex, punk.price, punk.owner, msg.sender);
    }

    function withdraw() external {
        uint256 amount = balances[msg.sender];
        require(amount > 0, "No balance to withdraw");
        balances[msg.sender] = 0;
        payable(msg.sender).transfer(amount);
    }

    function enterBidForPunk(uint256 punkIndex) external payable {
        Punk storage punk = punks[punkIndex];
        require(punk.owner != address(0), "Punk not available for bidding");
        require(msg.value > punk.bid, "Bid must be higher than current bid");
        if (punk.bidder != address(0)) {
            punk.bidder.transfer(punk.bid);
        }
        punk.bidder = msg.sender;
        punk.bid = msg.value;
        emit PunkBidEntered(punkIndex, msg.value, msg.sender);
    }

    function acceptBidForPunk(uint256 punkIndex) external {
        Punk storage punk = punks[punkIndex];
        require(punk.owner == msg.sender, "You don't own this punk");
        require(punk.bid > 0, "No bid for this punk");
        address bidder = punk.bidder;
        uint256 bidAmount = punk.bid;
        punk.bidder = address(0);
        punk.bid = 0;
        _transfer(msg.sender, bidder, punkIndex);
        msg.sender.transfer(bidAmount);
        emit BidAccepted(punkIndex, bidAmount, msg.sender, bidder);
    }

    function withdrawBidForPunk(uint256 punkIndex) external {
        Punk storage punk = punks[punkIndex];
        require(punk.bidder == msg.sender, "You haven't placed a bid for this punk");
        uint256 bidAmount = punk.bid;
        punk.bidder = address(0);
        punk.bid = 0;
        msg.sender.transfer(bidAmount);
        emit BidWithdrawn(punkIndex, bidAmount, msg.sender);
    }

    function _transfer(address from, address to, uint256 punkIndex) internal {
        if (from != address(0)) {
            uint256[] storage fromPunks = ownedPunks[from];
            for (uint256 i = 0; i < fromPunks.length; i++) {
                if (fromPunks[i] == punkIndex) {
                    fromPunks[i] = fromPunks[fromPunks.length - 1];
                    fromPunks.pop();
                    break;
                }
            }
        }
        punks[punkIndex].owner = to;
        ownedPunks[to].push(punkIndex);
        emit PunkTransfer(punkIndex, from, to, punks[punkIndex].price);
    }
}
