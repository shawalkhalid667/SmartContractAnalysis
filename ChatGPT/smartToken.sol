pragma solidity ^0.8.0;

// SaferMath library for safe mathematical operations
library SaferMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        return c;
    }
}

// Ownable library for managing ownership functions
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

// StoxSmartToken contract for handling token functionality
contract StoxSmartToken {
    function transfer(address recipient, uint256 amount) external returns (bool) {}
}

// Trustee contract for managing allocation and distribution of tokens during sale
contract Trustee {
    // Additional functions for Trustee contract can be added here
}

contract StoxSmartTokenSale is Ownable {
    using SaferMath for uint256;

    // Token sale parameters
    uint256 public constant TOKEN_EXCHANGE_RATE = 1000; // 1 ETH = 1000 STX
    uint256 public constant MIN_CONTRIBUTION = 0.1 ether; // Minimum contribution is 0.1 ETH
    uint256 public constant MAX_CONTRIBUTION = 10 ether; // Maximum contribution is 10 ETH

    // Sale state
    enum SaleState {Inactive, Active, Finalized, Distributed}
    SaleState public saleState;
    
    // Sale parameters
    address public fundingRecipient;
    uint256 public startTime;
    uint256 public endTime;
    StoxSmartToken public token;
    Trustee public trustee;

    // Events
    event TokensIssued(address indexed recipient, uint256 amount);

    // Modifiers
    modifier onlyDuringSale() {
        require(block.timestamp >= startTime && block.timestamp <= endTime, "Sale not active");
        _;
    }

    modifier onlyAfterSale() {
        require(block.timestamp > endTime, "Sale not ended");
        _;
    }

    // Constructor
    constructor(
        address _fundingRecipient,
        uint256 _startTime,
        uint256 _endTime,
        address _tokenAddress,
        address _trusteeAddress
    ) {
        fundingRecipient = _fundingRecipient;
        startTime = _startTime;
        endTime = _endTime;
        token = StoxSmartToken(_tokenAddress);
        trustee = Trustee(_trusteeAddress);
        saleState = SaleState.Inactive;
    }

    // Function to start the token sale
    function startSale() external onlyOwner {
        require(saleState == SaleState.Inactive, "Sale already started");
        saleState = SaleState.Active;
    }

    // Function to pause the token sale
    function pauseSale() external onlyOwner {
        require(saleState == SaleState.Active, "Sale not active");
        saleState = SaleState.Inactive;
    }

    // Function to finalize the token sale
    function finalize() external onlyOwner onlyAfterSale {
        require(saleState == SaleState.Active, "Sale not active");
        // Additional logic for finalizing the sale, granting vesting grants, etc.
        saleState = SaleState.Finalized;
    }

    // Function to distribute partner tokens
    function distributePartnerTokens() external onlyOwner onlyAfterSale {
        require(saleState == SaleState.Finalized, "Sale not finalized");
        // Additional logic for distributing partner tokens
        saleState = SaleState.Distributed;
    }

    // Function to allow users to purchase tokens during the sale by sending ETH
    function create() external payable onlyDuringSale {
        require(msg.value >= MIN_CONTRIBUTION && msg.value <= MAX_CONTRIBUTION, "Invalid contribution amount");
        uint256 tokenAmount = msg.value * TOKEN_EXCHANGE_RATE;
        token.transfer(msg.sender, tokenAmount);
        emit TokensIssued(msg.sender, tokenAmount);
    }

    // Fallback function to receive ETH
    receive() external payable {
        create();
    }
}
