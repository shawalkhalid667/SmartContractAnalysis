pragma solidity ^0.8.20;

// Import for ReentrancyGuard from OpenZeppelin (example)
// import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

// Contract for ownership management (Ownable)
contract Ownable {
    address public owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Ownable: caller is not the owner");
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}

// Contract for pausing functionality (Pausable)
contract Pausable is Ownable {
    bool public paused;

    event Paused(address account);
    event Unpaused(address account);

    modifier whenNotPaused() {
        require(!paused, "Pausable: contract is paused");
        _;
    }

    modifier whenPaused() {
        require(paused, "Pausable: contract is not paused");
        _;
    }

    function pause() public onlyOwner whenNotPaused {
        paused = true;
        emit Paused(msg.sender);
    }

    function unpause() public onlyOwner whenPaused {
        paused = false;
        emit Unpaused(msg.sender);
    }
}

// Interfaces for ERC-20 and ERC-721 tokens
interface IERC20 {
    function transfer(address recipient, uint256 amount) external;
    function approve(address spender, uint256 amount) external;
    function transferFrom(address sender, address recipient, uint256 amount) external;
    function balanceOf(address account) external view returns (uint256);
}

interface IERC721 {
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
}

// Struct for representing assets
struct Asset {
    address contractAddress; // ERC-20 or ERC-721 contract address
    uint256 tokenId;        // Token ID (0 for ERC-20)
    uint256 value;          // Asset value/amount
}

// Struct for representing trades
struct Trade {
    address seller;
    address buyer;
    Asset[] assets;  // Assets offered by seller
    Asset[] payments; // Assets offered by buyer (payment)
    uint256 deadline;  // Trade expiration deadline
}

bytes32 constant DOMAIN_SEPARATOR_TYPEHASH = keccak256(abi.encodePacked(
    "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
));

contract DecentralizedMarketplace is Pausable {
    bytes32 public DOMAIN_SEPARATOR;

    constructor() {
        DOMAIN_SEPARATOR = keccak256(abi.encodePacked(
            DOMAIN_SEPARATOR_TYPEHASH,
            keccak256("DecentralizedMarketplace"),
            keccak256("1"),
            block.chainid,
            address(this)
        ));
    }

    function hashTrade(Trade memory trade) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(
            keccak256("Trade(address seller,address buyer,Asset[] assets,Asset[] payments,uint256 deadline)"),
            trade.seller,
            trade.buyer,
            hashAssetArray(trade.assets),
            hashAssetArray(trade.payments),
            trade.deadline
        ));
    }

    function getTypedDataHash(Trade memory trade) public view returns (bytes32) {
        return keccak256(abi.encodePacked(
            "\x19\x01",
            DOMAIN_SEPARATOR,
            hashTrade(trade)
        ));
    }

    function verifySignature(Trade memory trade, bytes memory signature, address signer) public view returns (bool) {
        bytes32 messageHash = getTypedDataHash(trade);
        return recoverSigner(messageHash, signature) == signer;
    }

    function recoverSigner(bytes32 messageHash, bytes memory signature) internal pure returns (address) {
        bytes32 r;
        bytes32 s;
        uint8 v;

        
