pragma solidity ^0.8.8;

// SPDX-License-Identifier: UNLICENSED

/**
 * @title VIDT Token Contract
 * @dev ERC20 token with extended functionalities for VIDT Datalink platform
 */
contract VIDT is ERC20, Ownable, Pausable {
    using SafeMath for uint256;

    // Token details
    string public constant name = "VIDT Datalink Token";
    string public constant symbol = "VIDT";
    uint8 public constant decimals = 18;
    uint256 public totalSupply;

    // Access control & Fees
    mapping(address => bool) public frozenAccounts;
    uint256 public validationFee = 10 * 10**decimals; // 10 VIDT
    uint256 public tokenPrice = 1 ether / 100 * 10**decimals; // 1 ETH = 100 VIDT

    // External NFT Contract (replace with actual address)
    address public nftContract;

    // Public Validation Interface
    event DocumentValidated(bytes32 hash, address validator);
    event DocumentRetracted(bytes32 hash, address validator);
    event NFTCollaboration(address nftContract);

    // Modifiers
    modifier onlyNotFrozen(address account) {
        require(!frozenAccounts[account], "Account is frozen");
        _;
    }

    modifier onlyOwnerOrVerified() {
        require(isOwner() || isVerified(msg.sender), "Not owner or verified");
        _;
    }

    /**
     * @dev Constructor - Initializes token with total supply
     * @param _totalSupply Total supply of VIDT tokens
     * @param _nftContract Address of the external NFT contract
     */
    constructor(uint256 _totalSupply, address _nftContract) public Ownable() Pausable() {
        totalSupply = _totalSupply;
        _mint(msg.sender, totalSupply);
        nftContract = _nftContract;
    }

    // ERC20 Interface Implementation (basic functions)

    function balanceOf(address account) public view override returns (uint256) {
        return super.balanceOf(account);
    }

    function transfer(address recipient, uint256 amount) public virtual override onlyNotFrozen(msg.sender) whenNotPaused returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return super.allowance(owner, spender);
    }

    function approve(address spender, uint256 amount) public virtual override onlyNotFrozen(msg.sender) returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override onlyNotFrozen(sender) whenNotPaused returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), allowance(sender, _msgSender()).sub(amount, "Transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual override returns (bool) {
        _approve(_msgSender(), spender, allowance(_msgSender(), spender).add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual override returns (bool) {
        _approve(_msgSender(), spender, allowance(_msgSender(), spender).sub(subtractedValue, "Decreased allowance below zero"));
        return true;
    }

    // Extended Functionalities

    /**
     * @dev Freeze an account, preventing transfers
     * @param account Address to freeze
     */
    function freezeAccount(address account) public onlyOwner {
        frozenAccounts[account] = true;
    }

    /**
     * @dev Unfreeze an account
     * @param account Address to unfreeze
     */
    function unfreezeAccount(address account) public onlyOwner {
        frozenAccounts[account] = false;
    }

    /**
     * @dev Set validation fee for validating documents
     * @param newFee New validation fee in VIDT tokens
     */
    function setValidationFee(uint256 newFee) public onlyOwner {
        validationFee = newFee;
    }

}
