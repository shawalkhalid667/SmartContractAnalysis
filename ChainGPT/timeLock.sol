
// SPDX-License-Identifier: MIT

pragma solidity ^ 0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable (msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _owner = _msgSender();
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
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
        return a - b;
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
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

interface IMasterChef {
    function add(uint256 _allocPoint, address _lpToken, uint16 _depositFeeBP, bool _withUpdate) external;
    function set(uint256 _pid, uint256 _allocPoint, uint16 _depositFeeBP, bool _withUpdate) external;
    function updateEmissionRate(uint256 _perBlock) external;
}

contract Timelock is Ownable {
    using SafeMath for uint256;

    uint256 private constant GRACE_PERIOD = 14 days;
    uint256 private constant MINIMUM_DELAY = 1 hours;
    uint256 private constant MAXIMUM_DELAY = 30 days;

    IMasterChef private _masterChef;
    address private _admin;
    uint256 private _delay;

    struct Transaction {
        address target;
        uint value;
        string signature;
        bytes data;
        bool executed;
    }

    mapping(bytes32 => Transaction) private _queuedTransactions;

    event QueueTransaction(bytes32 indexed txHash, address indexed target, uint value, string signature, bytes data, uint eta);
    event CancelTransaction(bytes32 indexed txHash, address indexed target, uint value, string signature, bytes data);
    event ExecuteTransaction(bytes32 indexed txHash, address indexed target, uint value, string signature, bytes data);

    modifier onlyAdmin() {
        require(_admin == _msgSender(), "Timelock: caller is not the admin");
        _;
    }

    constructor(address masterChef, address admin, uint256 delay) {
        _masterChef = IMasterChef(masterChef);
        _admin = admin;
        _delay = delay;
    }

    receive() external payable {}

    function queueTransaction(address target, uint value, string memory signature, bytes memory data, uint eta) external onlyAdmin {
        require(eta >= block.timestamp.add(MINIMUM_DELAY), "Timelock: insufficient delay");
        require(eta <= block.timestamp.add(MAXIMUM_DELAY), "Timelock: excessive delay");

        bytes32 txHash = keccak256(abi.encodePacked(target, value, signature, data, eta));
        _queuedTransactions[txHash] = Transaction(target, value, signature, data, false);

        emit QueueTransaction(txHash, target, value, signature, data, eta);
    }

    function cancelTransaction(address target, uint value, string memory signature, bytes memory data, uint eta) external onlyAdmin {
        bytes32 txHash = keccak256(abi.encodePacked(target, value, signature, data, eta));
        _queuedTransactions[txHash] = Transaction(address(0), 0, "", "", false);

        emit CancelTransaction(txHash, target, value, signature, data);
    }

    function executeTransaction(address target, uint value, string memory signature, bytes memory data, uint eta) external onlyAdmin {
        bytes32 txHash = keccak256(abi.encodePacked(target, value, signature, data, eta));
        Transaction storage txData = _queuedTransactions[txHash];
        require(txData.target != address(0), "Timelock: transaction not queued");
        require(!txData.executed, "Timelock: transaction already executed");
        require(block.timestamp >= eta, "Timelock: transaction not yet executable");

        txData.executed = true;
        (bool success, ) = address(txData.target).call{value: txData.value}(abi.encodePacked(bytes4(keccak256(bytes(signature))), txData.data));
        require(success, "Timelock: transaction execution failed");

        emit ExecuteTransaction(txHash, target, value, signature, data);
    }

    function updateAdmin(address newAdmin) external onlyOwner {
        _admin = newAdmin;
    }

    function updateDelay(uint256 newDelay) external onlyOwner {
        _delay = newDelay;
    }

    function addPool(uint256 allocPoint, address lpToken, uint16 depositFeeBP, bool withUpdate) external onlyOwner {
        _masterChef.add(allocPoint, lpToken, depositFeeBP, withUpdate);
    }

    function setPool(uint256 pid, uint256 allocPoint, uint16 depositFeeBP, bool withUpdate) external onlyOwner {
        _masterChef.set(pid, allocPoint, depositFeeBP, withUpdate);
    }

    function updateEmissionRate(uint256 perBlock) external onlyOwner {
        _masterChef.updateEmissionRate(perBlock);
    }
}
