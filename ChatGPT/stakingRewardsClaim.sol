// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
}

interface ITokenGovernance {
    function incrementSignatureIndex(uint256 index) external;
    function cancelSignature(uint256 index) external;
}

interface IBancorNetworkV3 {
    function deposit(uint256 amount) external;
}

contract Ownable {
    address public owner;

    modifier onlyOwner() {
        require(msg.sender == owner, "Ownable: caller is not the owner");
        _;
    }

    constructor() {
        owner = msg.sender;
    }
}

contract Pausable is Ownable {
    bool public paused;

    modifier whenNotPaused() {
        require(!paused, "Pausable: paused");
        _;
    }

    function pause() external onlyOwner {
        paused = true;
    }

    function unpause() external onlyOwner {
        paused = false;
    }
}

library MerkleProof {
    function verify(bytes32[] memory proof, bytes32 root, bytes32 leaf) internal pure returns (bool) {
        bytes32 computedHash = leaf;
        for (uint256 i = 0; i < proof.length; i++) {
            bytes32 proofElement = proof[i];

            if (computedHash < proofElement) {
                computedHash = keccak256(abi.encodePacked(computedHash, proofElement));
            } else {
                computedHash = keccak256(abi.encodePacked(proofElement, computedHash));
            }
        }
        return computedHash == root;
    }
}

contract RewardsClaimAndStake is Ownable, Pausable {
    using MerkleProof for bytes32[];

    IERC20 public token;
    ITokenGovernance public tokenGovernance;
    IBancorNetworkV3 public bancorNetworkV3;
    bytes32 public merkleRoot;
    mapping(address => mapping(bytes32 => bool)) public claimed;

     bytes32 private constant EIP712_DOMAIN_TYPEHASH = keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");

    // Returns the domain separator to use EIP712 signatures
    function getDomainSeparator() private view returns (bytes32) {
        return keccak256(
            abi.encode(
                EIP712_DOMAIN_TYPEHASH,
                keccak256(bytes("RewardsClaimAndStake")),
                keccak256(bytes("1")),
                block.chainid,
                address(this)
            )
        );
    }

    // Recovers the signer of a message
    function recover(bytes32 digest, bytes memory signature) private pure returns (address) {
        require(signature.length == 65, "Invalid signature length");

        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
            v := byte(0, mload(add(signature, 0x60)))
        }

        if (v < 27) {
            v += 27;
        }

        require(v == 27 || v == 28, "Invalid signature v value");

        return ecrecover(digest, v, r, s);
    }

    bool private _notEntered;

    modifier nonReentrant() {
        require(_notEntered, "ReentrancyGuard: reentrant call");
        _notEntered = false;
        _;
        _notEntered = true;
    }

    event RewardClaimed(address indexed recipient, uint256 amount);
    event RewardStaked(address indexed staker, uint256 amount);
    event AdminAction(address indexed admin, string action);

    constructor(
        address _tokenAddress,
        address _tokenGovernanceAddress,
        address _bancorNetworkV3Address,
        bytes32 _merkleRoot
    ) {
        token = IERC20(_tokenAddress);
        tokenGovernance = ITokenGovernance(_tokenGovernanceAddress);
        bancorNetworkV3 = IBancorNetworkV3(_bancorNetworkV3Address);
        merkleRoot = _merkleRoot;
        _notEntered = true;
    }

    function claim(bytes32[] memory proof, uint256 amount, bytes memory signature) external nonReentrant whenNotPaused {
        bytes32 claimHash = keccak256(abi.encode(msg.sender, amount));
        bytes32 domainSeparator = getDomainSeparator();
        bytes32 digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                domainSeparator,
                claimHash
            )
        );
        address recoveredAddress = recover(digest, signature);

        require(recoveredAddress == msg.sender, "Invalid signature");
        require(!claimed[msg.sender][claimHash], "Reward already claimed");
        require(MerkleProof.verify(proof, merkleRoot, claimHash), "Invalid Merkle proof");

        claimed[msg.sender][claimHash] = true;

        require(token.transfer(msg.sender, amount), "Reward transfer failed");

        emit RewardClaimed(msg.sender, amount);
    }

    function stake(uint256 amount) external nonReentrant whenNotPaused {
        require(token.allowance(msg.sender, address(this)) >= amount, "Allowance not set");
        require(token.transferFrom(msg.sender, address(this), amount), "Stake transfer failed");

        token.approve(address(bancorNetworkV3), amount);
        bancorNetworkV3.deposit(amount);

        emit RewardStaked(msg.sender, amount);
    }

    function updateMerkleRoot(bytes32 _newMerkleRoot) external onlyOwner {
        merkleRoot = _newMerkleRoot;
        emit AdminAction(msg.sender, "Updated Merkle Root");
    }

    function incrementSignatureIndices(uint256[] memory indices) external onlyOwner {
        for (uint256 i = 0; i < indices.length; i++) {
            tokenGovernance.incrementSignatureIndex(indices[i]);
        }
        emit AdminAction(msg.sender, "Incremented Signature Indices");
    }

    function cancelSignatures(uint256[] memory indices) external onlyOwner {
        for (uint256 i = 0; i < indices.length; i++) {
            tokenGovernance.cancelSignature(indices[i]);
        }
        emit AdminAction(msg.sender, "Cancelled Signatures");
    }

    function withdrawTokens(address _token, uint256 _amount) external onlyOwner {
        token.transfer(owner, _amount);
        emit AdminAction(msg.sender, "Withdrawn Tokens");
    }

    receive() external payable {
        revert("Contract does not accept Ether");
    }
}
