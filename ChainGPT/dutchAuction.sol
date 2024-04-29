
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract DutchAuction {
    using SafeMath for uint256;

    // The token we are selling
    ERC20 public token;

    // Parameters of the auction. Times are either
    uint public minSharesToSell; // Minimum number of shares to sell
    uint public maxSharesToSell; // Maximum number of shares to sell
    uint public availableShares; // Total number of shares available

    // Enum for auction status
    enum State {Pending, Active, Ended, Decrypted, Success, Failure}
    State public state;

    // Struct for bid data
    struct BidData {
        uint value;
        bool isDecrypted;
        bool isBurned;
        bool isIgnored;
    }

    // Mapping for bids
    mapping(address => BidData) public bids;

    // Events
    event AuctionStarted();
    event AuctionEnded();
    event BidDecrypted(address indexed bidder, uint value);
    event FundraiseDefined(uint minSharesToSell, uint maxSharesToSell);
    event Execution(address indexed to, uint value);
    event ExecutionFailure(address indexed to, uint value);

    // Modifier to allow actions only when the auction is active
    modifier whenActive {
        require(state == State.Active, "Auction not active");
        _;
    }

    // Modifier to allow actions only when the auction is ended
    modifier whenEnded {
        require(state == State.Ended, "Auction not ended");
        _;
    }

    // Initialize the auction
    constructor(address _token, uint _minSharesToSell, uint _maxSharesToSell, uint _availableShares) {
        token = ERC20(_token);
        minSharesToSell = _minSharesToSell;
        maxSharesToSell = _maxSharesToSell;
        availableShares = _availableShares;
        state = State.Pending;
    }

    // Start the auction
    function startAuction() public {
        state = State.Active;
        emit AuctionStarted();
    }

    // End the auction
    function endAuction() public whenActive {
        state = State.Ended;
        emit AuctionEnded();
    }

    // Place a bid
    function placeBid(uint _value) public whenActive {
        bids[msg.sender] = BidData(_value, false, false, false);
    }

    // Decrypt a bid
    function decryptBid(address _bidder, uint _value) public whenEnded {
        BidData storage bid = bids[_bidder];
        require(bid.value == _value, "Bid value does not match");
        bid.isDecrypted = true;
        emit BidDecrypted(_bidder, _value);
    }

    // Burn a bid
    function burnBid(address _bidder) public whenEnded {
        BidData storage bid = bids[_bidder];
        bid.isBurned = true;
    }

    // Ignore a bid
    function ignoreBid(address _bidder) public whenEnded {
        BidData storage bid = bids[_bidder];
        bid.isIgnored = true;
    }

    // Set fundraise limits
    function setFundraiseLimits(uint _minSharesToSell, uint _maxSharesToSell) public {
        minSharesToSell = _minSharesToSell;
        maxSharesToSell = _maxSharesToSell;
        emit FundraiseDefined(_minSharesToSell, _maxSharesToSell);
    }

    // Reclaim tokens
    function reclaimTokens() public whenEnded {
        uint balance = token.balanceOf(address(this));
        require(token.transfer(msg.sender, balance), "Transfer failed");
    }
}
