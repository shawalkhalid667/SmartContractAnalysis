pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address _to, uint256 _value) external returns (bool);
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool);
    function balanceOf(address _owner) external view returns (uint256);
    function approve(address _spender, uint256 _value) external returns (bool);
    function allowance(address _owner, address _spender) external view returns (uint256);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

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

contract NYToken is IERC20, Ownable {
    string public name = "YUP";
    string public symbol = "YUP";
    uint8 public decimals = 18;
    uint256 public totalSupply;

    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowed;
    mapping(address => bool) public paused;

    mapping(address => uint256) public presaleTokens;
    mapping(address => uint256) public crowdsaleTokens;
    mapping(address => uint256) public bountyTokens;
    mapping(address => uint256) public seedTokens;
    mapping(address => uint256) public reserveTokens;
    mapping(address => uint256) public teamTokens;
    mapping(address => uint256) public futureTokens;

    bool public finalized;

    modifier isFinalized() {
        require(finalized, "Contract is not finalized");
        _;
    }

    modifier notFinalized() {
        require(!finalized, "Contract is already finalized");
        _;
    }

    modifier whenNotPaused() {
        require(!paused[msg.sender], "Paused");
        _;
    }

    function pause() external onlyOwner {
        paused[msg.sender] = true;
    }

    function unpause() external onlyOwner {
        paused[msg.sender] = false;
    }

    function transfer(address _to, uint256 _value) external override whenNotPaused returns (bool) {
        _transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) external override whenNotPaused returns (bool) {
        require(_value <= allowed[_from][msg.sender], "Insufficient allowance");
        allowed[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }

    function _transfer(address _from, address _to, uint256 _value) internal {
        require(_to != address(0), "Invalid address");
        require(balances[_from] >= _value, "Insufficient balance");
        balances[_from] -= _value;
        balances[_to] += _value;
        emit Transfer(_from, _to, _value);
    }

    function balanceOf(address _owner) external view override returns (uint256) {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) external override whenNotPaused returns (bool) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) external view override returns (uint256) {
        return allowed[_owner][_spender];
    }

    function finalize() external onlyOwner notFinalized {
        finalized = true;
        emit IsFinalized();
    }

    constructor(uint256 _totalSupply) {
        totalSupply = _totalSupply * (10 ** uint256(decimals));

        uint256 presalePercentage = 20;
        uint256 crowdsalePercentage = 30;
        uint256 bountyPercentage = 5;
        uint256 seedPercentage = 10;
        uint256 reservePercentage = 10;
        uint256 teamPercentage = 10;
        uint256 futurePercentage = 15;

        presaleTokens[msg.sender] = totalSupply * presalePercentage / 100;
        crowdsaleTokens[msg.sender] = totalSupply * crowdsalePercentage / 100;
        bountyTokens[msg.sender] = totalSupply * bountyPercentage / 100;
        seedTokens[msg.sender] = totalSupply * seedPercentage / 100;
        reserveTokens[msg.sender] = totalSupply * reservePercentage / 100;
        teamTokens[msg.sender] = totalSupply * teamPercentage / 100;
        futureTokens[msg.sender] = totalSupply * futurePercentage / 100;

        balances[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);
    }

    event IsFinalized();
}
