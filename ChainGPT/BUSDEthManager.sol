
// SPDX-License-Identifier: MIT

pragma solidity ^ 0.8.0;

// SafeMath library for safe arithmetic operations
library SafeMath {
    function add(uint a, uint b) internal pure returns (uint) {
        uint c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint a, uint b) internal pure returns (uint) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint c = a - b;

        return c;
    }

    function mul(uint a, uint b) internal pure returns (uint) {
        if (a == 0) {
            return 0;
        }

        uint c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint a, uint b) internal pure returns (uint) {
        require(b > 0, "SafeMath: division by zero");
        uint c = a / b;

        return c;
    }

    function mod(uint a, uint b) internal pure returns (uint) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

// IBUSD interface declaration
interface IBUSD {
    function balanceOf(address account) external view returns (uint);
    function transferFrom(address sender, address recipient, uint amount) external returns (bool);
    function transfer(address recipient, uint amount) external returns (bool);
    function increaseSupply(uint value) external;
    function decreaseSupply(uint value) external;
}

// Main contract
contract BUSDEthManager {
    using SafeMath for uint;

    IBUSD public token;
    address public wallet;
    mapping(bytes32 => bool) public usedEvents_;

    event Locked(address indexed _from, bytes32 indexed _id, uint _amount);
    event Unlocked(address indexed _to, bytes32 indexed _id, uint _amount);

    modifier onlyWallet {
        require(msg.sender == wallet, "Not authorized");
        _;
    }

    constructor(IBUSD _token, address _wallet) public {
        token = _token;
        wallet = _wallet;
    }

    function lockToken(uint _amount, bytes32 _id) external {
        lockTokenFor(msg.sender, _amount, _id);
    }

    function lockTokenFor(address _beneficiary, uint _amount, bytes32 _id) public {
        require(_beneficiary != address(0), "Invalid address");
        require(_amount > 0, "Amount must be greater than 0");
        require(token.transferFrom(msg.sender, address(this), _amount), "Transfer failed");

        emit Locked(_beneficiary, _id, _amount);
    }

    function unlockToken(bytes32 _id, uint _amount, address _beneficiary) external onlyWallet {
        require(!usedEvents_[_id], "Event already used");
        usedEvents_[_id] = true;

        require(token.transfer(_beneficiary, _amount), "Transfer failed");
        emit Unlocked(_beneficiary, _id, _amount);
    }
}
