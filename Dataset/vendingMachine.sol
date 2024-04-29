pragma solidity ^0.8.0;

library Roles {
    struct Role {
        mapping(address => bool) bearer;
    }

    function add(Role storage role, address account) internal {
        require(!has(role, account), "Roles: account already has role");
        role.bearer[account] = true;
    }

    function remove(Role storage role, address account) internal {
        require(has(role, account), "Roles: account does not have role");
        role.bearer[account] = false;
    }

    function has(Role storage role, address account) internal view returns (bool) {
        return role.bearer[account];
    }
}

contract AdminRole {
    using Roles for Roles.Role;

    event AdminAdded(address indexed account);
    event AdminRemoved(address indexed account);

    Roles.Role private admins;
    address public superAdmin;

    constructor() {
        _addAdmin(msg.sender);
        superAdmin = msg.sender;
    }

    modifier onlyAdmin() {
        require(isAdmin(msg.sender), "Restricted to admins");
        _;
    }

    modifier onlySuperAdmin() {
        require(isSuperAdmin(msg.sender), "Restricted to super admin");
        _;
    }

    function isAdmin(address account) public view returns (bool) {
        return admins.has(account);
    }

    function isSuperAdmin(address account) public view returns (bool) {
        return account == superAdmin;
    }

    function addAdmin(address account) public onlySuperAdmin {
        _addAdmin(account);
    }

    function removeAdmin(address account) public onlySuperAdmin {
        _removeAdmin(account);
    }

    function renounceAdmin() public {
        _removeAdmin(msg.sender);
    }

    function _addAdmin(address account) internal {
        admins.add(account);
        emit AdminAdded(account);
    }

    function _removeAdmin(address account) internal {
        admins.remove(account);
        emit AdminRemoved(account);
    }
}

contract WhitelistedRole is AdminRole {
    using Roles for Roles.Role;

    event WhitelistedAdded(address indexed account);
    event WhitelistedRemoved(address indexed account);

    Roles.Role private _whitelisteds;

    modifier onlyWhitelisted() {
        require(isWhitelisted(msg.sender), "Restricted to whitelisted");
        _;
    }

    function isWhitelisted(address account) public view returns (bool) {
        return _whitelisteds.has(account);
    }

    function addWhitelisted(address account) public onlyAdmin {
        _addWhitelisted(account);
    }

    function removeWhitelisted(address account) public onlyAdmin {
        _removeWhitelisted(account);
    }

    function renounceWhitelisted() public {
        _removeWhitelisted(msg.sender);
    }

    function _addWhitelisted(address account) internal {
        _whitelisteds.add(account);
        emit WhitelistedAdded(account);
    }

    function _removeWhitelisted(address account) internal {
        _whitelisteds.remove(account);
        emit WhitelistedRemoved(account);
    }
}

interface ERC20Vendable {
    function mint(address account, uint256 amount) external;
    function burn(address account, uint256 amount) external;
}

contract VendingMachine is AdminRole, WhitelistedRole {
    using SafeMath for uint256;

    ERC20Vendable public tokenContract;
    mapping (address => uint256) public allowance;

    event Deposit(address indexed depositor, uint amount);
    event Withdraw(address indexed withdrawer, uint amount);

    constructor(address _tokenContract) {
        tokenContract = ERC20Vendable(_tokenContract);
    }

    // Fallback. Just send currency here to deposit
    receive() external payable {
        deposit();
    }

    /**
    * @dev Deposit currency in order to buy tokens from the ERC20Contract
    * Will buy tokens at a 1-to-1 ratio. User will also be given an allowance to withdraw the same amount.
    */
    function deposit() public payable {
        _addAllowance(msg.sender, msg.value);

        tokenContract.mint(msg.sender, msg.value);
        emit Deposit(msg.sender, msg.value);
    }

    /**
    * @dev Admin hook to increment an account's withdraw allowance.
    * Could be useful if they don't want to give the user unlimited withdraw by whitelisting them
    * @param account The address to receive the increased allowance.
    * @param amount The amount to increase the allowance
    */
    function addAllowance(address account, uint256 amount) public onlyAdmin {
        _addAllowance(account, amount);
    }

    function _addAllowance(address account, uint256 amount) private {
        allowance[account] = allowance[account].add(amount);
    }

    function withdraw(uint256 amount) public {
        if(isWhitelisted(msg.sender)) {
            _withdraw(amount);
        } else {
            require(amount <= allowance[msg.sender], "Insufficient allowance");
            allowance[msg.sender] = allowance[msg.sender].sub(amount);
            _withdraw(amount);
        }
    }

    function _withdraw(uint256 amount) private {
        tokenContract.burn(msg.sender, amount);
        payable(msg.sender).transfer(amount);
        emit Withdraw(msg.sender, amount);
    }

    function adminMint(address to, uint256 amount) public onlyAdmin {
        tokenContract.mint(to, amount);
    }

    function sweep(uint256 amount) public onlySuperAdmin {
        payable(msg.sender).transfer(amount);
    }

    //*****************  Product/Vendor related code *******************//

    mapping (address => Vendor) public vendors;
    mapping (address => mapping (uint256 => Product)) public products;

    event UpdateVendor(address indexed vendor, bytes32 name, bool isActive, bool isAllowed, address sender);
    event AddProduct(address indexed vendor, uint256 id, uint256 cost, bytes32 name, bool isAvailable);

    struct Vendor {
        bytes32 name;
        bool isActive; // Let's vendor indicate if they are open at the time
        bool isAllowed; // Let's admin turn them off,
        bool exists;
    }

    struct Product {
        uint256 id;
        uint256 cost;
        bytes32 name;
        bool exists;
        bool isAvailable;
    }

    function addProduct(uint256 id, bytes32 name, uint256 cost, bool isAvailable) public {
        require(vendors[msg.sender].isAllowed, "Vendor is not allowed by admin");
        products[msg.sender][id] = Product({
            id: id,
            cost: cost,
            name: name,
            exists: true,
            isAvailable: isAvailable
        });

        emit AddProduct(msg.sender, id, cost, name, isAvailable);
    }

    function addVendor(address _vendorAddress, bytes32 _name) public onlyAdmin {
        require(!vendors[_vendorAddress].exists, "This address is already a vendor.");

        vendors[_vendorAddress] = Vendor({
            name: _name,
            isActive: false,
            isAllowed: true,
            exists: true
        });

        _emitUpdateVendor(_vendorAddress);
    }

    function activateVendor(bool _isActive) public {
        _updateVendor(
            msg.sender,
            vendors[msg.sender].name,
            _isActive,
            vendors[msg.sender].isAllowed
        );
    }

    function updateVendor(address _vendorAddress, bytes32 _name, bool _isActive, bool _isAllowed) public onlyAdmin {
        _updateVendor(_vendorAddress, _name, _isActive, _isAllowed);
    }

    function _updateVendor(address _vendorAddress, bytes32 _name, bool _isActive, bool _isAllowed) private {
        require(vendors[_vendorAddress].exists, "Cannot update a non-existent vendor");

        vendors[_vendorAddress].name = _name;
        vendors[_vendorAddress].isActive = _isActive;
        vendors[_vendorAddress].isAllowed = _isAllowed;

        _emitUpdateVendor(_vendorAddress);
    }

    function _emitUpdateVendor(address _vendorAddress) private {
        emit UpdateVendor(
            _vendorAddress,
            vendors[_vendorAddress].name,
            vendors[_vendorAddress].isActive,
            vendors[_vendorAddress].isAllowed,
            msg.sender
        );
    }
}

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
}
