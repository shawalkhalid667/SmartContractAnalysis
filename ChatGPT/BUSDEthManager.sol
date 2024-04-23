pragma solidity ^ 0.8.0;

contract BUSDEthManager {
    address public constant BUSD_ADDRESS = 0x1f9840a85d5aF5bf1D1762F925BDADdC4201F984; // Sample BUSD contract address (Uniswap)
    address public constant AUTHORIZED_WALLET = 0xAb5801a7D398351b8bE11C439e05C5B3259aeC9B; // Sample authorized wallet address (random Ethereum address)

    event Locked(address indexed from, address indexed to, uint256 amount);
    event Unlocked(bytes32 indexed receiptId, address indexed to, uint256 amount);

    modifier onlyWallet() {
        require(msg.sender == AUTHORIZED_WALLET, "Unauthorized");
        _;
    }

    function lockToken(address to, uint256 amount) public {
        require(to != address(0), "Invalid recipient address");
        require(amount > 0, "Invalid amount");

        emit Locked(msg.sender, to, amount);
    }

    function unlockToken(bytes32 receiptId, address to, uint256 amount) public onlyWallet {
        require(to != address(0), "Invalid recipient address");
        require(amount > 0, "Invalid amount");

        emit Unlocked(receiptId, to, amount);
    }
}
