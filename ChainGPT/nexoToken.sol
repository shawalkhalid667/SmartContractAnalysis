pragma solidity 0.8.25;

contract Token { mapping(address => uint) balances; mapping(address => mapping(address => uint)) allowed;

function transferERC20Token(address _to, uint _value) public {
    require(_to != address(0));
    require(balances[msg.sender] >= _value);
    balances[msg.sender] -= _value;
    balances[_to] += _value;
}

function increaseApproval(address _spender, uint _addedValue) public {
    allowed[msg.sender][_spender] += _addedValue;
}

function decreaseApproval(address _spender, uint _subtractedValue) public {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue >= oldValue) {
        allowed[msg.sender][_spender] = 0;
    } else {
        allowed[msg.sender][_spender] = oldValue - _subtractedValue;
    }
}
}

contract NexoToken is Token { string public name = 'Nexo'; string public symbol = 'NEXO'; uint public decimals = 18;

uint public constant INITIAL_INVESTORS_ALLOCATION = 525000000 * 10**uint(decimals);
uint public constant OVERDRAFT_RESERVES_ALLOCATION = 250000000 * 10**uint(decimals);
uint public constant FOUNDERS_TEAM_ALLOCATION = 112500000 * 10**uint(decimals);
uint public constant COMMUNITY_AIRDROP_ALLOCATION = 60000000 * 10**uint(decimals);
uint public constant ADVISORS_LEGAL_PR_ALLOCATION = 52500000 * 10**uint(decimals);

uint public constant CLIFF_PERIOD = 6 * 30 days; // 6 months
uint public constant VESTING_PERIOD = 3 * 30 days; // 3 months
uint public constant TEAM_VESTING_PERIODS = 16; // 4 years
uint public constant COMMUNITY_VESTING_PERIODS = 18;
uint public constant ADVISORS_VESTING_PERIODS = 12;

struct Allocation {
    uint amount;
    uint claimedTokens;
    uint startTime;
    uint cliffTime;
    uint vestingPeriod;
}

mapping(address => Allocation) public overdraftReservesAllocations;
mapping(address => Allocation) public foundersTeamAllocations;
mapping(address => Allocation) public communityAirdropAllocations;
mapping(address => Allocation) public advisorsLegalPRAllocations;

address public owner;

modifier onlyOwner() {
    require(msg.sender == owner);
    _;
}

constructor() public {
    owner = msg.sender;

    balances[owner] = INITIAL_INVESTORS_ALLOCATION;
    emit Transfer(address(0), owner, INITIAL_INVESTORS_ALLOCATION);

    overdraftReservesAllocations[0x1] = Allocation(OVERDRAFT_RESERVES_ALLOCATION, 0, now, now + CLIFF_PERIOD, VESTING_PERIOD);
    foundersTeamAllocations[0x2] = Allocation(FOUNDERS_TEAM_ALLOCATION, 0, now, now + VESTING_PERIOD, TEAM_VESTING_PERIODS * VESTING_PERIOD);
    communityAirdropAllocations[0x3] = Allocation(COMMUNITY_AIRDROP_ALLOCATION, 0, now, now + VESTING_PERIOD, COMMUNITY_VESTING_PERIODS * VESTING_PERIOD);
    advisorsLegalPRAllocations[0x4] = Allocation(ADVISORS_LEGAL_PR_ALLOCATION, 0, now, now + VESTING_PERIOD, ADVISORS_VESTING_PERIODS * VESTING_PERIOD);
}

function distributeTokensToInitialInvestors(address _investor, uint _amount) public onlyOwner {
    require(balances[owner] >= _amount);
    balances[owner] -= _amount;
    balances[_investor] += _amount;
    emit Transfer(owner, _investor, _amount);
}

function withdrawTokensFromOverdraftReserves() public {
    Allocation storage allocation = overdraftReservesAllocations[msg.sender];
    require(allocation.amount > 0);
    require(now >= allocation.cliffTime);

    uint unreleased = unlockedTokens(allocation);
    require(unreleased > 0);

    uint releasable = allocation.amount - allocation.claimedTokens;
    uint amount = releasable < unreleased ? releasable : unreleased;

    allocation.claimedTokens += amount;
    balances[msg.sender] += amount;
    emit Transfer(address(0), msg.sender, amount);
}

function withdrawTokensFromFoundersTeam() public {
    Allocation storage allocation = foundersTeamAllocations[msg.sender];
    require(allocation.amount > 0);
    require(now >= allocation.cliffTime);

    uint unreleased = unlockedTokens(allocation);
    require(unreleased > 0);

    uint releasable = allocation.amount - allocation.claimedTokens;
    uint amount = releasable < unreleased ? releasable : unreleased;

    allocation.claimedTokens += amount;
    balances[msg.sender] += amount;
    emit Transfer(address(0), msg.sender, amount);
}

function withdrawTokensFromCommunityAirdrop() public {
    Allocation storage allocation = communityAirdropAllocations[msg.sender];
    require(allocation.amount > 0);
    require(now >= allocation.cliffTime);

    uint unreleased = unlockedTokens(allocation);
    require(unreleased > 0);

    uint releasable = allocation.amount - allocation.claimedTokens;
    uint amount = releasable < unreleased ? releasable : unreleased;

    allocation.claimedTokens += amount;
    balances[msg.sender] += amount;
    emit Transfer(address(0), msg.sender, amount);
}

function withdrawTokensFromAdvisorsLegalPR() public {
    Allocation storage allocation = advisorsLegalPRAllocations[msg.sender];
    require(allocation.amount > 0);
    require(now >= allocation.cliffTime);

    uint unreleased = unlockedTokens(allocation);
    require(unreleased > 0);

    uint releasable = allocation.amount - allocation.claimedTokens;
    uint amount = releasable < unreleased ? releasable : unreleased;

    allocation.claimedTokens += amount;
    balances[msg.sender] += amount;
    emit Transfer(address(0), msg.sender, amount);
}

function unlockedTokens(Allocation memory allocation) internal view returns (uint) {
    if (now < allocation.cliffTime) {
        return 0;
    } else if (now >= allocation.startTime + allocation.vestingPeriod) {
        return allocation.amount;
    } else {
        uint elapsedPeriods = (now - allocation.startTime) / allocation.vestingPeriod;
        uint vested = allocation.amount * elapsedPeriods / allocation.vestingPeriods;
        return vested - allocation.claimedTokens;
    }
}

function ownerConfirmation(address _address) public onlyOwner {
    overdraftReservesAllocations[_address].startTime = now;
    foundersTeamAllocations[_address].startTime = now;
    communityAirdropAllocations[_address].startTime = now;
    advisorsLegalPRAllocations[_address].startTime = now;
}

event Transfer(address indexed from, address indexed to, uint value);
}
