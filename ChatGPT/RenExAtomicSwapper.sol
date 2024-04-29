// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract RenExAtomicSwapper {
    string public VERSION;
    address public admin;
    address public superAdmin;
    bool public paused;

    enum SwapState { INVALID, OPEN, CLOSED, EXPIRED }

    struct Swap {
        address initiator;
        address participant;
        uint256 value;
        bytes32 secretLock;
        uint256 timelock;
    }

    mapping(bytes32 => Swap) public swaps;
    mapping(bytes32 => SwapState) public swapStates;
    mapping(bytes32 => uint256) public redeemedAt;

    event LogOpen(bytes32 indexed swapID, address indexed initiator, address indexed participant, uint256 value, bytes32 secretLock, uint256 timelock);
    event LogClose(bytes32 indexed swapID);
    event LogExpire(bytes32 indexed swapID);

    modifier onlyAdmin() {
        require(msg.sender == admin || msg.sender == superAdmin, "Caller is not an admin");
        _;
    }

    modifier onlyInvalidSwaps(bytes32 _swapID) {
        require(swapStates[_swapID] == SwapState.INVALID, "Swap is not in INVALID state");
        _;
    }

    modifier onlyOpenSwaps(bytes32 _swapID) {
        require(swapStates[_swapID] == SwapState.OPEN, "Swap is not in OPEN state");
        _;
    }

    modifier onlyClosedSwaps(bytes32 _swapID) {
        require(swapStates[_swapID] == SwapState.CLOSED, "Swap is not in CLOSED state");
        _;
    }

    modifier onlyExpirableSwaps(bytes32 _swapID) {
        require(swapStates[_swapID] == SwapState.OPEN && block.timestamp >= swaps[_swapID].timelock, "Swap is not expirable");
        _;
    }

    modifier onlyWithSecretKey(bytes32 _swapID, bytes32 _secretKey) {
        require(sha256(abi.encodePacked(_secretKey)) == swaps[_swapID].secretLock, "Invalid secret key");
        _;
    }

    modifier whenNotPaused() {
        require(!paused, "Contract functionality is paused");
        _;
    }

    constructor(string memory _version) {
        VERSION = _version;
        admin = msg.sender;
        superAdmin = msg.sender;
    }

    function initiate(address _participant, uint256 _value, bytes32 _secretLock, uint256 _timelock) external onlyAdmin whenNotPaused {
        bytes32 swapID = swapID(msg.sender, _participant, _value, _secretLock, _timelock);
        swaps[swapID] = Swap(msg.sender, _participant, _value, _secretLock, _timelock);
        swapStates[swapID] = SwapState.OPEN;
        emit LogOpen(swapID, msg.sender, _participant, _value, _secretLock, _timelock);
    }

    function redeem(bytes32 _swapID, bytes32 _secretKey) external onlyOpenSwaps(_swapID) onlyWithSecretKey(_swapID, _secretKey) whenNotPaused {
        swapStates[_swapID] = SwapState.CLOSED;
        redeemedAt[_swapID] = block.timestamp;
        emit LogClose(_swapID);
    }

    function refund(bytes32 _swapID) external onlyOpenSwaps(_swapID) onlyExpirableSwaps(_swapID) whenNotPaused {
        swapStates[_swapID] = SwapState.EXPIRED;
        emit LogExpire(_swapID);
    }

    function audit(bytes32 _swapID) external view returns (address, address, uint256, bytes32, uint256) {
        Swap memory swap = swaps[_swapID];
        return (swap.initiator, swap.participant, swap.value, swap.secretLock, swap.timelock);
    }

    function auditSecret(bytes32 _swapID) external view onlyClosedSwaps(_swapID) returns (bytes32) {
        require(redeemedAt[_swapID] > 0, "Swap not yet redeemed");
        return swaps[_swapID].secretLock;
    }

    function refundable(bytes32 _swapID) external view returns (bool) {
        return (swapStates[_swapID] == SwapState.OPEN && block.timestamp >= swaps[_swapID].timelock);
    }

    function initiatable(bytes32 _swapID) external view returns (bool) {
        return (swapStates[_swapID] == SwapState.INVALID);
    }

    function redeemable(bytes32 _swapID) external view returns (bool) {
        return (swapStates[_swapID] == SwapState.OPEN);
    }

    function swapID(address _initiator, address _participant, uint256 _value, bytes32 _secretLock, uint256 _timelock) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(_initiator, _participant, _value, _secretLock, _timelock));
    }

    function withdrawal(address payable _to, uint256 _amount) external onlyAdmin {
        require(_to != address(0), "Invalid address");
        require(_amount > 0 && _amount <= address(this).balance, "Invalid amount");
        _to.transfer(_amount);
    }

    function pause() external onlyAdmin {
        paused = true;
    }

    function resume() external onlyAdmin {
        paused = false;
    }

    function isPaused() external view returns (bool) {
        return paused;
    }

    function transferAdmin(address _newAdmin) external onlyAdmin {
        require(_newAdmin != address(0), "Invalid address");
        admin = _newAdmin;
    }

    function transferSuperAdmin(address _newSuperAdmin) external {
        require(msg.sender == superAdmin, "Caller is not the super admin");
        require(_newSuperAdmin != address(0), "Invalid address");
        superAdmin = _newSuperAdmin;
    }
}
