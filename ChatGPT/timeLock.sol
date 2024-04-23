// SPDX-License-Identifier: MIT
pragma solidity ^ 0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
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
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function renounceOwnership() public virtual onlyOwner {
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

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

interface IMasterChef {
    function add(uint256 _allocPoint, address _lpToken, bool _withUpdate) external;
    function set(uint256 _pid, uint256 _allocPoint, bool _withUpdate) external;
    function updateEmissionRate(uint256 _cakePerBlock) external;
}

contract Timelock is Ownable {
    using SafeMath for uint256;

    uint256 public constant GRACE_PERIOD = 14 days;
    uint256 public constant MINIMUM_DELAY = 1 hours;
    uint256 public constant MAXIMUM_DELAY = 30 days;

    uint256 public delay;
    bool public paused;

    mapping(bytes32 => bool) public queuedTransactions;

    event QueueTransaction(bytes32 indexed txHash, address indexed target, uint256 value, string signature, bytes data, uint256 eta);
    event CancelTransaction(bytes32 indexed txHash, address indexed target, uint256 value, string signature, bytes data);
    event ExecuteTransaction(bytes32 indexed txHash, address indexed target, uint256 value, string signature, bytes data);

    constructor(uint256 _delay) {
        require(_delay >= MINIMUM_DELAY, "Timelock: Delay must exceed minimum delay");
        require(_delay <= MAXIMUM_DELAY, "Timelock: Delay must not exceed maximum delay");
        delay = _delay;
    }

    receive() external payable {}

    function setDelay(uint256 _delay) external onlyOwner {
        require(_delay >= MINIMUM_DELAY, "Timelock: Delay must exceed minimum delay");
        require(_delay <= MAXIMUM_DELAY, "Timelock: Delay must not exceed maximum delay");
        delay = _delay;
    }

    function pause() external onlyOwner {
        paused = true;
    }

    function unpause() external onlyOwner {
        paused = false;
    }

    function queueTransaction(address target, uint256 value, string memory signature, bytes memory data, uint256 eta) external onlyOwner returns (bytes32) {
        require(!paused, "Timelock: Contract is paused");
        require(eta >= block.timestamp.add(delay), "Timelock: Estimated execution block must satisfy delay");
        bytes32 txHash = keccak256(abi.encode(target, value, signature, data, eta));
        queuedTransactions[txHash] = true;
        emit QueueTransaction(txHash, target, value, signature, data, eta);
        return txHash;
    }

    function cancelTransaction(address target, uint256 value, string memory signature, bytes memory data, uint256 eta) external onlyOwner {
        require(!paused, "Timelock: Contract is paused");
        bytes32 txHash = keccak256(abi.encode(target, value, signature, data, eta));
        queuedTransactions[txHash] = false;
        emit CancelTransaction(txHash, target, value, signature, data);
    }

    function executeTransaction(address target, uint256 value, string memory signature, bytes memory data, uint256 eta) external onlyOwner payable returns (bytes memory) {
        require(!paused, "Timelock: Contract is paused");
        bytes32 txHash = keccak256(abi.encode(target, value, signature, data, eta));
        require(queuedTransactions[txHash], "Timelock: Transaction hasn't been queued");
        require(block.timestamp >= eta, "Timelock: Transaction hasn't surpassed time lock");
        require(block.timestamp <= eta.add(GRACE_PERIOD), "Timelock: Transaction is stale");

        queuedTransactions[txHash] = false;

        (bool success, bytes memory returnData) = target.call{value: value}(abi.encodePacked(bytes4(keccak256(bytes(signature))), data));
        require(success, "Timelock: Transaction execution reverted");

        emit ExecuteTransaction(txHash, target, value, signature, data);

        return returnData;
    }

    function addPool(IMasterChef masterChef, uint256 allocPoint, address lpToken, bool withUpdate) external onlyOwner {
        masterChef.add(allocPoint, lpToken, withUpdate);
    }

    function setPool(IMasterChef masterChef, uint256 pid, uint256 allocPoint, bool withUpdate) external onlyOwner {
        masterChef.set(pid, allocPoint, withUpdate);
    }

    function updateEmissionRate(IMasterChef masterChef, uint256 cakePerBlock) external onlyOwner {
        masterChef.updateEmissionRate(cakePerBlock);
    }
}
