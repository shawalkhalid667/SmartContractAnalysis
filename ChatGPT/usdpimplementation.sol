// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract PAXImplementation {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _frozenAccounts;

    string private _name;
    string private _symbol;
    uint8 private _decimals;
    uint256 private _totalSupply;
    address private _supplyController;
    address private _lawEnforcement;

    event SupplyIncreased(address indexed to, uint256 amount);
    event SupplyDecreased(address indexed from, uint256 amount);
    event TokensFrozen(address indexed account);
    event TokensUnfrozen(address indexed account);
    event LawEnforcementRoleSet(address indexed oldLawEnforcement, address indexed newLawEnforcement);
    event TokensSeized(address indexed from, address indexed to, uint256 amount);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Paused(address account);
    event Unpaused(address account);

    constructor(
        string memory name_,
        string memory symbol_,
        uint8 decimals_,
        uint256 initialSupply_,
        address owner_,
        address supplyController_
    ) {
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
        _totalSupply = initialSupply_;
        _balances[owner_] = initialSupply_;
        _supplyController = supplyController_;
        _lawEnforcement = owner_;

        emit Transfer(address(0), owner_, initialSupply_);
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        uint256 currentAllowance = _allowances[msg.sender][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        _approve(msg.sender, spender, currentAllowance - subtractedValue);
        return true;
    }

    function pause() public {
        require(msg.sender == _supplyController || msg.sender == owner(), "Not authorized to pause");
        _pause();
    }

    function unpause() public {
        require(msg.sender == _supplyController || msg.sender == owner(), "Not authorized to unpause");
        _unpause();
    }

    function freezeAccount(address account) public {
        require(msg.sender == _lawEnforcement || msg.sender == owner(), "Not authorized to freeze");
        _frozenAccounts[account] = true;
        emit TokensFrozen(account);
    }

    function unfreezeAccount(address account) public {
        require(msg.sender == _lawEnforcement || msg.sender == owner(), "Not authorized to unfreeze");
        _frozenAccounts[account] = false;
        emit TokensUnfrozen(account);
    }

    function setLawEnforcementRole(address newLawEnforcement) public {
        require(msg.sender == owner(), "Not authorized to set law enforcement role");
        address oldLawEnforcement = _lawEnforcement;
        _lawEnforcement = newLawEnforcement;
        emit LawEnforcementRoleSet(oldLawEnforcement, newLawEnforcement);
    }

    function seizeTokens(address from, address to, uint256 amount) public {
        require(msg.sender == _lawEnforcement, "Not authorized to seize tokens");
        require(_frozenAccounts[from], "Account not frozen");
        _transfer(from, to, amount);
        emit TokensSeized(from, to, amount);
    }

    function mint(address account, uint256 amount) public {
        require(msg.sender == _supplyController, "Not authorized to mint tokens");
        require(account != address(0), "ERC20: mint to the zero address");
        _totalSupply += amount;
        _balances[account] += amount;
        emit SupplyIncreased(account, amount);
        emit Transfer(address(0), account, amount);
    }

    function burn(uint256 amount) public {
        require(msg.sender == _supplyController, "Not authorized to burn tokens");
        _burn(msg.sender, amount);
    }

    function burnFrom(address account, uint256 amount) public {
        require(msg.sender == _supplyController, "Not authorized to burn tokens");
        uint256 decreasedAllowance = _allowances[account][msg.sender] - amount;
        _approve(account, msg.sender, decreasedAllowance);
        _burn(account, amount);
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(!_frozenAccounts[sender], "Sender account is frozen");
        require(!_frozenAccounts[recipient], "Recipient account is frozen");
        require(!paused(), "ERC20Pausable: token transfer while paused");
        
        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        _balances[sender] = senderBalance - amount;
        _balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: burn from the zero address");
        require(_balances[account] >= amount, "ERC20: burn amount exceeds balance");

        _balances[account] -= amount;
        _totalSupply -= amount;
        emit SupplyDecreased(account, amount);
        emit Transfer(account, address(0), amount);
    }
}
