
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract BURN is ERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowed;
    uint256 private _totalSupply;
    uint256 private constant basePercent = 1;

    constructor() ERC20("BURN", "") {
        _totalSupply = 10000000 * (10 ** uint256(decimals()));
        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address owner) public view override returns (uint256) {
        return _balances[owner];
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowed[owner][spender];
    }

    function transfer(address to, uint256 value) public override returns (bool) {
        require(value <= _balances[msg.sender]);
        require(to != address(0));

        uint256 tokensToBurn = findOnePercent(value);
        uint256 tokensToTransfer = value.sub(tokensToBurn);

        _balances[msg.sender] = _balances[msg.sender].sub(value);
        _balances[to] = _balances[to].add(tokensToTransfer);

        _totalSupply = _totalSupply.sub(tokensToBurn);

        emit Transfer(msg.sender, to, tokensToTransfer);
        emit Transfer(msg.sender, address(0), tokensToBurn);

        return true;
    }

    function approve(address spender, uint256 value) public override returns (bool) {
        _allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) public override returns (bool) {
        require(value <= _balances[from]);
        require(value <= _allowed[from][msg.sender]);
        require(to != address(0));

        _balances[from] = _balances[from].sub(value);

        uint256 tokensToBurn = findOnePercent(value);
        uint256 tokensToTransfer = value.sub(tokensToBurn);

        _balances[to] = _balances[to].add(tokensToTransfer);
        _totalSupply = _totalSupply.sub(tokensToBurn);

        _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);

        emit Transfer(from, to, tokensToTransfer);
        emit Transfer(from, address(0), tokensToBurn);

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _allowed[msg.sender][spender] = _allowed[msg.sender][spender].add(addedValue);
        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        uint256 oldValue = _allowed[msg.sender][spender];
        if (subtractedValue >= oldValue) {
            _allowed[msg.sender][spender] = 0;
        } else {
            _allowed[msg.sender][spender] = oldValue.sub(subtractedValue);
        }
        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
        return true;
    }

   function findOnePercent(uint256 value) public view returns (uint256)  {
    uint256 roundValue = ceil(value, basePercent);
    uint256 onePercent = roundValue.mul(basePercent).div(100);
    return onePercent;
    }
}
