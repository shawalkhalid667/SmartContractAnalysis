// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.0;

contract Comp { string public constant name = "Compound"; string public constant symbol = "COMP"; uint8 public constant decimals = 18;

uint256 public totalSupply = 10000000 * 10**uint(decimals); // 10 million COMP
mapping(address => uint256) balances;
mapping(address => mapping(address => uint256)) allowances;
mapping(address => address) delegates;
mapping(address => mapping(uint32 => uint256)) checkpoints;
mapping(address => uint32) numCheckpoints;
mapping(address => uint256) nonces;

event Transfer(address indexed from, address indexed to, uint256 amount);
event Approval(address indexed owner, address indexed spender, uint256 amount);
event DelegateChanged(address indexed delegator, address indexed delegate);
event DelegateVotesChanged(address indexed delegate, uint256 previousBalance, uint256 newBalance);

function balanceOf(address account) external view returns (uint256) {
    return balances[account];
}

function allowance(address owner, address spender) external view returns (uint256) {
    return allowances[owner][spender];
}

function approve(address spender, uint256 amount) external returns (bool) {
    allowances[msg.sender][spender] = amount;
    emit Approval(msg.sender, spender, amount);
    return true;
}

function transfer(address to, uint256 amount) external returns (bool) {
    _transfer(msg.sender, to, amount);
    return true;
}

function transferFrom(address from, address to, uint256 amount) external returns (bool) {
    uint256 currentAllowance = allowances[from][msg.sender];
    require(currentAllowance >= amount, "Insufficient allowance");
    
    _transfer(from, to, amount);
    
    allowances[from][msg.sender] = currentAllowance - amount;
    emit Approval(from, msg.sender, currentAllowance - amount);
    
    return true;
}

function delegate(address delegatee) external {
    _delegate(msg.sender, delegatee);
}

function delegateBySig(address delegatee, uint256 nonce, uint256 expiry, uint8 v, bytes32 r, bytes32 s) external {
    require(block.timestamp <= expiry, "Signature expired");
    
    bytes32 message = keccak256(abi.encodePacked(delegatee, nonce, expiry, address(this)));
    address signer = ecrecover(message, v, r, s);
    require(signer != address(0) && nonces[signer] == nonce, "Invalid signature");
    
    _delegate(signer, delegatee);
    nonces[signer]++;
}

function getCurrentVotes(address account) external view returns (uint256) {
    uint32 nCheckpoints = numCheckpoints[account];
    return nCheckpoints > 0 ? checkpoints[account][nCheckpoints - 1] : 0;
}

function getPriorVotes(address account, uint256 blockNumber) external view returns (uint256) {
    require(blockNumber < block.number, "Invalid block number");
    
    uint32 nCheckpoints = numCheckpoints[account];
    if (nCheckpoints == 0) {
        return 0;
    }
    
    if (checkpoints[account][nCheckpoints - 1] <= blockNumber) {
        return checkpoints[account][nCheckpoints - 1];
    }
    
    if (checkpoints[account][0] > blockNumber) {
        return 0;
    }
    
    uint256 lower = 0;
    uint256 upper = nCheckpoints - 1;
    while (upper > lower) {
        uint256 x = upper + lower + 1 / 2;
        if (checkpoints[account][x] <= blockNumber) {
            lower = x;
        } else {
            upper = x - 1;
        }
    }
    
    return checkpoints[account][upper];
}

function _transfer(address from, address to, uint256 amount) internal {
    require(from != address(0), "Transfer from the zero address");
    require(to != address(0), "Transfer to the zero address");
    
    balances[from] -= amount;
    balances[to] += amount;
    
    _moveDelegates(delegates[from], delegates[to], amount);
    
    emit Transfer(from, to, amount);
}

function _delegate(address delegator, address delegatee) internal {
    delegates[delegator] = delegatee;
    
    emit DelegateChanged(delegator, delegatee);
    
    _moveDelegates(address(0), delegatee, balances[delegator]);
}

function _moveDelegates(address from, address to, uint256 amount) internal {
    if (from != to && amount > 0) {
        if (from != address(0)) {
            uint32 fromNumCheckpoints = numCheckpoints[from];
            uint256 fromOld = fromNumCheckpoints > 0 ? checkpoints[from][fromNumCheckpoints - 1] : 0;
            uint256 fromNew = fromOld - amount;
            
            _writeCheckpoint(from, fromNumCheckpoints, fromOld, fromNew);
        }
        
        if (to != address(0)) {
            uint32 toNumCheckpoints = numCheckpoints[to];
            uint256 toOld = toNumCheckpoints > 0 ? checkpoints[to][toNumCheckpoints - 1] : 0;
            uint256 toNew = toOld + amount;
            
            _writeCheckpoint(to, toNumCheckpoints, toOld, toNew);
        }
    }
}

function _writeCheckpoint(address delegatee, uint32 nCheckpoints, uint256 oldVotes, uint256 newVotes) internal {
    uint32 blockNumber = uint32(block.number);
    
    if (nCheckpoints > 0 && checkpoints[delegatee][nCheckpoints - 1] == blockNumber) {
        checkpoints[delegatee][nCheckpoints - 1] = newVotes;
    } else {
        checkpoints[delegatee][nCheckpoints] = newVotes;
        numCheckpoints[delegatee] = nCheckpoints + 1;
    }
    
    emit DelegateVotesChanged(delegatee, oldVotes, newVotes);
}
}

