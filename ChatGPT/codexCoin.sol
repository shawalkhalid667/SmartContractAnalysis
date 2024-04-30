pragma solidity ^0.8.0;

// Interface for ERC20 Standard
interface ERC20Interface {
    function totalSupply() external view returns (uint);
    function balanceOf(address tokenOwner) external view returns (uint balance);
    function allowance(address tokenOwner, address spender) external view returns (uint remaining);
    function transfer(address to, uint tokens) external returns (bool success);
    function approve(address spender, uint tokens) external returns (bool success);
    function transferFrom(address from, address to, uint tokens) external returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

// PausableToken contract
contract PausableToken {
    bool public paused = false;
    address public owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event Pause();
    event Unpause();

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    modifier whenNotPaused() {
        require(!paused);
        _;
    }

    modifier whenPaused() {
        require(paused);
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    function pause() public onlyOwner whenNotPaused {
        paused = true;
        emit Pause();
    }

    function unpause() public onlyOwner whenPaused {
        paused = false;
        emit Unpause();
    }
}

// CodexCoin contract
contract CodexCoin is ERC20Interface, PausableToken {
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public _totalSupply;

    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;

    constructor(uint256 initialSupply) {
        name = "CodexCoin";
        symbol = "CODX";
        decimals = 18;
        owner = msg.sender;
        _totalSupply = initialSupply * 10 ** uint256(decimals);
        balances[msg.sender] = _totalSupply;
    }

    function totalSupply() public view override returns (uint) {
        return _totalSupply - balances[address(0)];
    }

    function balanceOf(address tokenOwner) public view override returns (uint balance) {
        return balances[tokenOwner];
    }

    function transfer(address to, uint tokens) public override whenNotPaused returns (bool success) {
        require(to != address(0));
        require(tokens <= balances[msg.sender]);
        balances[msg.sender] -= tokens;
        balances[to] += tokens;
        emit Transfer(msg.sender, to, tokens);
        return true;
    }

    function approve(address spender, uint tokens) public override whenNotPaused returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }

    function transferFrom(address from, address to, uint tokens) public override whenNotPaused returns (bool success) {
        require(to != address(0));
        require(tokens <= balances[from]);
        require(tokens <= allowed[from][msg.sender]);
        balances[from] -= tokens;
        balances[to] += tokens;
        allowed[from][msg.sender] -= tokens;
        emit Transfer(from, to, tokens);
        return true;
    }

    function allowance(address tokenOwner, address spender) public view override returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }

    function reclaimToken(address tokenAddress) public onlyOwner {
        require(tokenAddress != address(0));
        ERC20Interface token = ERC20Interface(tokenAddress);
        uint balance = token.balanceOf(address(this));
        token.transfer(owner, balance);
    }
}
