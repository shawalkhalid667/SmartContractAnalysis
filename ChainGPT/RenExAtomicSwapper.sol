
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

contract RenExAtomicSwapper is Context, AccessControl, Pausable {
    // Define roles for access control
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant SUPER_ADMIN_ROLE = keccak256("SUPER_ADMIN_ROLE");

    // Define swap states
    enum States {INVALID, OPEN, CLOSED, EXPIRED}

    // Version of the contract
    string public constant VERSION = "1.0.0";

    // Struct to store swap details
    struct Swap {
        uint256 timelock;
        uint256 value;
        address payable sender;
        address payable recipient;
        bytes32 secretLock;
        bytes32 secretKey;
    }

    // Mappings to store swaps, their states and redemption timestamps
    mapping(bytes32 => Swap) public swaps;
    mapping(bytes32 => States) public swapStates;
    mapping(bytes32 => uint256) public redeemedAt;

    // Events
    event LogOpen(bytes32 indexed swapID, address indexed sender, address indexed recipient, bytes32 secretLock);
    event LogClose(bytes32 indexed swapID, bytes32 secretKey);
    event LogExpire(bytes32 indexed swapID);

    // Modifiers
    modifier onlyInvalidSwaps(bytes32 _swapID) {
        require(swapStates[_swapID] == States.INVALID, "Swap is not invalid");
        _;
    }

    modifier onlyOpenSwaps(bytes32 _swapID) {
        require(swapStates[_swapID] == States.OPEN, "Swap is not open");
        _;
    }

    modifier onlyClosedSwaps(bytes32 _swapID) {
        require(swapStates[_swapID] == States.CLOSED, "Swap is not closed");
        _;
    }

    modifier onlyExpirableSwaps(bytes32 _swapID) {
        require(block.timestamp >= swaps[_swapID].timelock, "Swap is not expirable");
        _;
    }

    modifier onlyWithSecretKey(bytes32 _swapID, bytes32 _secretKey) {
        require(swaps[_swapID].secretLock == keccak256(abi.encodePacked(_secretKey)), "Invalid secret key");
        _;
    }

    constructor(address _admin) {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(ADMIN_ROLE, _admin);
        _setupRole(SUPER_ADMIN_ROLE, _msgSender());
    }

    // Contract functions
    function initiate(bytes32 _swapID, address payable _recipient, bytes32 _secretLock, uint256 _timelock)
        external
        payable
        onlyInvalidSwaps(_swapID)
        onlyRole(ADMIN_ROLE)
    {
        swaps[_swapID] = Swap({
            timelock: _timelock,
            value: msg.value,
            sender: _msgSender(),
            recipient: _recipient,
            secretLock: _secretLock,
            secretKey: 0x0
        });
        swapStates[_swapID] = States.OPEN;
        emit LogOpen(_swapID, msg.sender, _recipient, _secretLock);
    }

    function redeem(bytes32 _swapID, bytes32 _secretKey)
        external
        onlyOpenSwaps(_swapID)
        onlyWithSecretKey(_swapID, _secretKey)
        onlyRole(ADMIN_ROLE)
    {
        swaps[_swapID].secretKey = _secretKey;
        swapStates[_swapID] = States.CLOSED;
        redeemedAt[_swapID] = block.timestamp;
        swaps[_swapID].recipient.transfer(swaps[_swapID].value);
        emit LogClose(_swapID, _secretKey);
    }

    function refund(bytes32 _swapID)
        external
        onlyOpenSwaps(_swapID)
        onlyExpirableSwaps(_swapID)
        onlyRole(ADMIN_ROLE)
    {
        swapStates[_swapID] = States.EXPIRED;
        swaps[_swapID].sender.transfer(swaps[_swapID].value);
        emit LogExpire(_swapID);
    }

    // Helper functions
    function pause() external onlyRole(SUPER_ADMIN_ROLE) {
        _pause();
    }

    function resume() external onlyRole(SUPER_ADMIN_ROLE) {
        _unpause();
    }

    function withdrawal(uint256 _amount) external onlyRole(SUPER_ADMIN_ROLE) {
        payable(_msgSender()).transfer(_amount);
    }
}
