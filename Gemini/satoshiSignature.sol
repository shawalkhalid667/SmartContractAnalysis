pragma solidity ^0.8.0;

// Import the IBEP20 interface
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract SatoshiSignature is IERC20, Ownable {
    // Define token properties
    string public constant name = "SatoshiSignature";
    string public constant symbol = "SATOSHI";
    uint8 public constant decimals = 18;
    uint256 public totalSupply;

    // Reflection fee variables
    uint256 public reflectionFee;
    bool public reflectFees;

    // Uniswap router address for transfer checks
    address public uniswapRouter;
    bool public reverseSwap;

    // Mapping for token balances and allowances
    mapping(address => uint256) private balances;
    mapping(address => mapping(address => uint256)) private allowances;

    // Sale state variable
    bool public saleActive = false;

    // Emitted on token transfer
    event Transfer(address indexed from, address indexed to, uint256 value);
    // Emitted on token approval
    event Approval(address indexed owner, address indexed spender, uint256 value);
    // Emitted on token reflection distribution
    event Reflection(uint256 amountReflected);
    // Emitted on token burning
    event Burn(address indexed burner, uint256 value);
    // Emitted on token minting
    event Mint(address indexed minter, uint256 value);

    // Constructor sets initial supply
    constructor(uint256 _totalSupply) {
        totalSupply = _totalSupply;
        balances[msg.sender] = totalSupply; // Allocate total supply to contract deployer
    }

    // Modifier to restrict functions to contract owner
    modifier onlyOwner() {
        require(msg.sender == owner(), "Only owner can call this function");
        _;
    }

    // Implements IERC20.balanceOf
    function balanceOf(address account) public view override returns (uint256) {
        return balances[account];
    }

    // Implements IERC20.transfer
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    // Implements IERC20.allowance
    function allowance(address owner, address spender) public view override returns (uint256) {
        return allowances[owner][spender];
    }

    // Implements IERC20.approve
    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    // Implements IERC20.transferFrom
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, allowances[sender][msg.sender] - amount);
        return true;
    }

    // Internal transfer function with reflection handling
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal {
        require(balances[from] >= amount, "Insufficient balance for transfer");
        balances[from] -= amount;

        // Distribute reflection fees if enabled
        if (reflectFees) {
            uint256 reflectionAmount = amount * reflectionFee / 100;
            balances[address(this)] += reflectionAmount;
            emit Reflection(reflectionAmount);
            amount -= reflectionAmount;
        }

        // Check for Uniswap router transfer restriction
        if (!reverseSwap && to == uniswapRouter) {
            revert("Transfer to Uniswap router not allowed");
        }

        balances[to] += amount;
        emit Transfer(from, to, amount);
    }

    // Allows burning tokens by the owner
    function burn(uint256 amount) public onlyOwner {
        require(balances[msg.sender] >= amount, "Insufficient balance for burn");
        balances[msg.sender] -= amount;
        totalSupply -= amount;
        emit Burn(msg.sender, amount);
    }

    // Approve spender for a specific amount
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal {
        allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount)}
