pragma solidity ^0.8.0;

library SafeMath {
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

contract ROSCA {
    using SafeMath for uint256;

    // State variables
    address public foreperson;
    address public tokenContract;
    uint256 public roundPeriod;
    uint256 public serviceFee;
    uint256 public maxFee;
    uint256 public currentRound;
    uint256 public contributionSize;

    // Mapping to store participant details
    mapping(address => uint256) public participants;
    
    // Mapping to store winners' bid amounts
    mapping(uint256 => uint256) public winners;
    
    // Event logging
    event Contribution(address indexed participant, uint256 amount);
    event RoundStart(uint256 roundNumber);
    event BidUpdate(uint256 roundNumber, uint256 lowestBid);
    event Win(address indexed winner, uint256 amountWon);
    event Withdrawal(address indexed recipient, uint256 amount);
    event ROSCAEnd();

    // Constructor
    constructor(
        address _foreperson,
        address _tokenContract,
        uint256 _roundPeriod,
        uint256 _serviceFee,
        uint256 _maxFee,
        uint256 _contributionSize
    ) {
        foreperson = _foreperson;
        tokenContract = _tokenContract;
        roundPeriod = _roundPeriod;
        serviceFee = _serviceFee;
        maxFee = _maxFee;
        contributionSize = _contributionSize;
    }

    // Modifier to ensure only foreperson can access certain functions
    modifier onlyForeperson() {
        require(msg.sender == foreperson, "Only foreperson can call this function");
        _;
    }

    // Modifier to prevent reentrancy attacks
    bool private locked;
    modifier noReentrancy() {
        require(!locked, "Reentrant call");
        locked = true;
        _;
        locked = false;
    }

    // Function for participants to contribute funds
    function contribute(uint256 _amount) external {
        require(_amount > 0, "Contribution amount must be greater than zero");
        require(ERC20(tokenContract).transferFrom(msg.sender, address(this), _amount), "Transfer failed");
        
        participants[msg.sender] = participants[msg.sender].add(_amount);
        emit Contribution(msg.sender, _amount);
    }

    // Function to start a new round
    function startRound() external onlyForeperson {
        currentRound++;
        emit RoundStart(currentRound);
    }

    // Function to update the lowest bid
    function updateBid(uint256 _lowestBid) external onlyForeperson {
        winners[currentRound] = _lowestBid;
        emit BidUpdate(currentRound, _lowestBid);
    }

    // Function for the winner to claim their prize
    function claimPrize() external {
        require(winners[currentRound] > 0, "No winner for the current round");
        require(participants[msg.sender] > 0, "You are not a participant");
        
        uint256 prizeAmount = winners[currentRound];
        participants[msg.sender] = participants[msg.sender].add(prizeAmount);
        emit Win(msg.sender, prizeAmount);
    }

    // Function for participants to withdraw their funds
    function withdraw(uint256 _amount) external noReentrancy {
        require(_amount > 0, "Withdrawal amount must be greater than zero");
        require(_amount <= participants[msg.sender], "Insufficient balance");
        
        participants[msg.sender] = participants[msg.sender].sub(_amount);
        require(ERC20(tokenContract).transfer(msg.sender, _amount), "Transfer failed");
        emit Withdrawal(msg.sender, _amount);
    }

    // Function for the foreperson to withdraw surplus funds
    function withdrawSurplus(uint256 _amount) external onlyForeperson noReentrancy {
        require(_amount <= address(this).balance, "Insufficient balance");
        require(_amount <= maxFee, "Exceeds maximum fee limit");
        
        payable(foreperson).transfer(_amount);
        emit Withdrawal(foreperson, _amount);
    }

    // Function to end the ROSCA
    function endROSCA() external onlyForeperson {
        // Additional logic to finalize and distribute remaining funds (if any)
        emit ROSCAEnd();
    }
}
