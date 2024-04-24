pragma solidity ^0.8.25;

// SPDX-License-Identifier: Apache-2.0

contract Token {
    uint256 public totalSupply;
    mapping(address => uint256) public balances;
    mapping(address => mapping(address => uint256)) public allowed;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function transfer(address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        require(_value <= balances[msg.sender]);

        balances[msg.sender] -= _value;
        balances[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        require(_value <= balances[_from]);
        require(_value <= allowed[_from][msg.sender]);

        balances[_from] -= _value;
        balances[_to] += _value;
        allowed[_from][msg.sender] -= _value;
        emit Transfer(_from, _to, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public view returns (uint256) {
        return allowed[_owner][_spender];
    }

    function increaseApproval(address _spender, uint256 _addedValue) public returns (bool) {
        allowed[msg.sender][_spender] += _addedValue;
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    function decreaseApproval(address _spender, uint256 _subtractedValue) public returns (bool) {
        uint256 oldValue = allowed[msg.sender][_spender];
        if (_subtractedValue > oldValue) {
            allowed[msg.sender][_spender] = 0;
        } else {
            allowed[msg.sender][_spender] -= _subtractedValue;
        }
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }
}

contract NexoToken is Token {
    string public name = "Nexo";
    string public symbol = "NEXO";
    uint8 public decimals = 18;

    address public owner;
    mapping(address => uint256) public initialInvestors;
    mapping(address => uint256) public overdraftReserves;
    mapping(address => uint256) public foundersAndTeam;
    mapping(address => uint256) public communityBuilding;
    mapping(address => uint256) public advisorsLegalPR;

    uint256 public constant INITIAL_INVESTORS_TOKENS = 525_000_000 * (10 ** uint256(decimals));
    uint256 public constant OVERDRAFT_RESERVES_TOKENS_PER_MONTH = 250_000_000 * (10 ** uint256(decimals)) / 12;
    uint256 public constant FOUNDERS_TEAM_TOKENS_PER_QUARTER = 112_500_000 * (10 ** uint256(decimals)) / 16;
    uint256 public constant COMMUNITY_BUILDING_TOKENS_PER_MONTH = 60_000_000 * (10 ** uint256(decimals)) / 18;
    uint256 public constant ADVISORS_LEGAL_PR_TOKENS_PER_MONTH = 52_500_000 * (10 ** uint256(decimals)) / 12;

    uint256 public constant CLIFF_PERIOD = 6 * 30 days;
    uint256 public constant VESTING_PERIOD = 3 * 30 days;
    uint256 public constant TOTAL_VESTING_PERIODS = 16;

    uint256 public cliffStartTime;
    uint256 public foundersTeamStartTime;
    uint256 public communityBuildingStartTime;
    uint256 public advisorsLegalPRStartTime;

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    constructor() {
        owner = msg.sender;
        totalSupply = INITIAL_INVESTORS_TOKENS;
        balances[msg.sender] = INITIAL_INVESTORS_TOKENS;
        emit Transfer(address(0), msg.sender, INITIAL_INVESTORS_TOKENS);

        cliffStartTime = block.timestamp;
        foundersTeamStartTime = block.timestamp;
        communityBuildingStartTime = block.timestamp;
        advisorsLegalPRStartTime = block.timestamp;
    }

    function distributeOverdraftReserves() public onlyOwner {
        require(block.timestamp >= cliffStartTime + CLIFF_PERIOD);
        uint256 vestedTokens = ((block.timestamp - cliffStartTime) / VESTING_PERIOD) * OVERDRAFT_RESERVES_TOKENS_PER_MONTH;
        require(vestedTokens > overdraftReserves[msg.sender]);
        uint256 tokensToTransfer = vestedTokens - overdraftReserves[msg.sender];
        overdraftReserves[msg.sender] = vestedTokens;
        totalSupply += tokensToTransfer;
        balances[msg.sender] += tokensToTransfer;
        emit Transfer(address(0), msg.sender, tokensToTransfer);
    }

    function withdrawFromFoundersAndTeam() public onlyOwner {
        require(block.timestamp >= foundersTeamStartTime);
        uint256 periodsPassed = (block.timestamp - foundersTeamStartTime) / (VESTING_PERIOD * 4);
        if (periodsPassed >= TOTAL_VESTING_PERIODS) {
            periodsPassed = TOTAL_VESTING_PERIODS;
        }
        uint256 vestedTokens = periodsPassed * FOUNDERS_TEAM_TOKENS_PER_QUARTER;
        require(vestedTokens > foundersAndTeam[msg.sender]);
        uint256 tokensToTransfer = vestedTokens - foundersAndTeam[msg.sender];
        foundersAndTeam[msg.sender] = vestedTokens;
        totalSupply += tokensToTransfer;
        balances[msg.sender] += tokensToTransfer;
        emit Transfer(address(0), msg.sender, tokensToTransfer);
    }

    function withdrawFromCommunityBuilding() public onlyOwner {
        require(block.timestamp >= communityBuildingStartTime);
        uint256 periodsPassed = (block.timestamp - communityBuildingStartTime) / (VESTING_PERIOD * 18);
        if (periodsPassed >= 18) {
            periodsPassed = 18;
        }
        uint256 vestedTokens = periodsPassed * COMMUNITY_BUILDING_TOKENS_PER_MONTH;
        require(vestedTokens > communityBuilding[msg.sender]);
        uint256 tokensToTransfer = vestedTokens - communityBuilding[msg.sender];
        communityBuilding[msg.sender] = vestedTokens;
        totalSupply += tokensToTransfer;
        balances[msg.sender] += tokensToTransfer;
        emit Transfer(address(0), msg.sender, tokensToTransfer);
    }

    function withdrawFromAdvisorsLegalPR() public onlyOwner {
        require(block.timestamp >= advisorsLegalPRStartTime);
        uint256 periodsPassed = (block.timestamp - advisorsLegalPRStartTime) / (VESTING_PERIOD * 12);
        if (periodsPassed >= 12) {
            periodsPassed = 12;
        }
        uint256 vestedTokens = periodsPassed * ADVISORS_LEGAL_PR_TOKENS_PER_MONTH;
        require(vestedTokens > advisorsLegalPR[msg.sender]);
        uint256 tokensToTransfer = vestedTokens - advisorsLegalPR[msg.sender];
        advisorsLegalPR[msg.sender] = vestedTokens;
        totalSupply += tokensToTransfer;
        balances[msg.sender] += tokensToTransfer;
        emit Transfer(address(0), msg.sender, tokensToTransfer);
    }

    function transferERC20Token(address _token, address _to, uint256 _value) public onlyOwner {
        Token(_token).transfer(_to, _value);
    }

        function increaseApproval(address _spender, uint256 _addedValue) public override returns (bool) {
        super.increaseApproval(_spender, _addedValue);
        return true;
    }

    function decreaseApproval(address _spender, uint256 _subtractedValue) public override returns (bool) {
        super.decreaseApproval(_spender, _subtractedValue);
        return true;
    }

}
