
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Importing OpenZeppelin's SafeMath & ERC20 contracts
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract ROSCA {
    using SafeMath for uint256;

    // Variables
    address public foreperson;
    uint256 public roundPeriod;
    uint256 public serviceFee;
    uint256 public currentRound;
    ERC20 public token;
    uint256 public contributionSize;
    bool public contributionsFrozen = false;

    struct Participant {
        uint256 balance;
        bool hasContributed;
    }

    struct Round {
        uint256 lowestBid;
        address winner;
        bool finalized;
    }

    mapping(address => Participant) public participants;
    Round[] public rounds;

    // Events
    event ContributionMade(address indexed participant, uint256 amount);
    event RoundStarted(uint256 roundIndex);
    event BidUpdated(uint256 roundIndex, uint256 newLowestBid, address indexed newWinner);
    event RoundFinalized(uint256 roundIndex, address indexed winner, uint256 winningBid);
    event WithdrawalMade(address indexed participant, uint256 amount);

    // Modifiers
    modifier onlyForeperson() {
        require(msg.sender == foreperson, "Only foreperson can call this function.");
        _;
    }

    modifier onlyParticipant() {
        require(participants[msg.sender].balance > 0, "Only participants can call this function.");
        _;
    }

    modifier contributionsNotFrozen() {
        require(!contributionsFrozen, "Contributions are currently frozen.");
        _;
    }

    // Constructor
    constructor(address _foreperson, uint256 _roundPeriod, uint256 _serviceFee, ERC20 _token, uint256 _contributionSize) {
        foreperson = _foreperson;
        roundPeriod = _roundPeriod;
        serviceFee = _serviceFee;
        token = _token;
        contributionSize = _contributionSize;
    }

    // Functions
    function contribute() external onlyParticipant contributionsNotFrozen {
        // Transfer tokens from participant to contract
        token.transferFrom(msg.sender, address(this), contributionSize);
        // Update participant's contribution status
        participants[msg.sender].hasContributed = true;
        emit ContributionMade(msg.sender, contributionSize);
    }

    function startRound() external onlyForeperson {
        // Ensure all participants have contributed
        for (uint i = 0; i < rounds.length; i++) {
            require(participants[rounds[i].winner].hasContributed, "All participants must contribute before a new round can begin.");
        }
        // Create new round
        rounds.push(Round(0, address(0), false));
        emit RoundStarted(rounds.length - 1);
    }

    function bid(uint256 _bid) external onlyParticipant {
        Round storage round = rounds[currentRound];
        require(!round.finalized, "This round has already been finalized.");
        require(_bid < round.lowestBid || round.lowestBid == 0, "Your bid must be lower than the current lowest bid.");
        round.lowestBid = _bid;
        round.winner = msg.sender;
        emit BidUpdated(currentRound, _bid, msg.sender);
    }

    function finalizeRound() external onlyForeperson {
        Round storage round = rounds[currentRound];
        require(!round.finalized, "This round has already been finalized.");
        // Update winner's balance
        participants[round.winner].balance = participants[round.winner].balance.add(round.lowestBid);
        round.finalized = true;
        emit RoundFinalized(currentRound, round.winner, round.lowestBid);
        // Start next round
        currentRound = currentRound.add(1);
    }

    function withdraw(uint256 _amount) external onlyParticipant {
        require(participants[msg.sender].balance >= _amount, "Insufficient balance.");
        // Update participant's balance
        participants[msg.sender].balance = participants[msg.sender].balance.sub(_amount);
        // Transfer tokens from contract to participant
        token.transfer(msg.sender, _amount);
        emit WithdrawalMade(msg.sender, _amount);
    }

    function freezeContributions() external onlyForeperson {
        contributionsFrozen = true;
    }

    function unfreezeContributions() external onlyForeperson {
        contributionsFrozen = false;
    }
}
