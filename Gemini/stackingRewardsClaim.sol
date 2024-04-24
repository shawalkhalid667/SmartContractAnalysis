pragma solidity ^0.8.20;

// Minimal ERC20 Interface
interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
}

// Interface for Token Governance (minimal minting functionality)
interface ITokenGovernance {
    function mint(address recipient, uint256 amount) external;
}

// Interface for Network V3 (staking functionality)
interface IBancorNetworkV3 {
    function depositERC20(address token, address from, address to, uint256 amount) external;
}

// Custom error types for claim failures
error InvalidClaimProof();
error ClaimAlreadyClaimed();
error UnauthorizedClaim();

struct Claim {
    address beneficiary;
    uint256 amount;
}

contract RewardClaimAndStake {

    // EIP-712 Domain Separator
    bytes32 private constant DOMAIN_SEPARATOR = keccak256(
        abi.encodePacked(
            bytes32(uint256(keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"))),
            bytes32(keccak256("RewardClaimAndStake")),
            bytes32("1"),
            block.chainid,
            address(this)
        )
    );

    // Merkle Root for Valid Claims
    bytes32 public merkleRoot;

    // Owner of the Contract
    address public owner;

    // Non-reentrancy guard
    uint256 private locked = 1;
    modifier nonReentrant() {  // No changes required here
        require(locked == 1, "Reentrant call");
        locked = 2;
        _;
        locked = 1;
    }

    // Signature Index for Off-chain Signing
    uint256 public signatureIndex;

    // Mapping to track claimed rewards
    mapping(bytes32 => bool) public claimed;

    // Reward Token Address
    address public rewardToken;

    // Network V3 Staking Pool Address (optional)
    address public stakingPool;

    // Token Governance Contract Address (optional)
    address public governance;

    // Events for Claiming and Staking
    event Claimed(address indexed beneficiary, uint256 amount);
    event Staked(address indexed beneficiary, uint256 amount);

    constructor(address _rewardToken, address _governance, address _stakingPool) {
        owner = msg.sender;
        rewardToken = _rewardToken;
        governance = _governance;
        stakingPool = _stakingPool;
    }

    // Update Merkle Root
    function setMerkleRoot(bytes32 _merkleRoot) public onlyOwner {
        merkleRoot = _merkleRoot;
    }

    // Function to verify Merkle proofs and claim rewards
    function claim(bytes32[] calldata proof, Claim calldata claim, bytes calldata signature) public nonReentrant {
        bytes32 leaf = keccak256(abi.encodePacked(claim.beneficiary, claim.amount, signatureIndex));
        require(!claimed[leaf], "Claim already claimed");
        require(verifyProof(proof, leaf), "Invalid claim proof");
        require(recoverSigner(leaf, signature) == claim.beneficiary, "Unauthorized claim");

        claimed[leaf] = true;
        if (governance != address(0)) {
            ITokenGovernance(governance).mint(claim.beneficiary, claim.amount);
        }
        emit Claimed(claim.beneficiary, claim.amount);
    }

    // Verify Merkle Proof (no changes required here)
    function verifyProof(bytes32[] calldata proof, bytes32 leaf) internal view returns (bool) {
        bytes32 computedHash = leaf;
        for (uint256 i = 0; i < proof.length; i++) {
            bytes32 proofElement = proof[i];
            if (computedHash < proofElement) {
                computedHash = keccak256(abi.encodePacked(computedHash, proofElement));
            } else {
                computedHash = keccak256(abi.encodePacked(proofElement, computedHash));
            }
        }
        return computedHash == merkleRoot;
    }

    // Recover signer address
