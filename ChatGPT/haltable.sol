pragma solidity ^0.8.0;

contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract Haltable is Ownable {
    bool public halted;

    modifier stopInEmergency() {
        require(!halted, "Contract is halted");
        _;
    }

    modifier stopNonOwnersInEmergency() {
        require(!halted || msg.sender == owner(), "Contract is halted and you are not the owner");
        _;
    }

    modifier onlyInEmergency() {
        require(halted, "Contract is not halted");
        _;
    }

    function halt() public onlyOwner {
        halted = true;
    }

    function unhalt() public onlyOwner {
        halted = false;
    }
}
