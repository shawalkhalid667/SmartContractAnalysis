// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

// NYToken is an ERC20 token with token distribution strategies and additional functionalities.
contract NYToken is ERC20, Ownable, Pausable {

    // Token distribution percentages
    uint256 public constant PRESALE_PERCENT = 10;
    uint256 public constant CROWDSALE_PERCENT = 10;
    uint256 public constant BOUNTY_PERCENT = 10;
    uint256 public constant SEED_PERCENT = 10;
    uint256 public constant RESERVE_PERCENT = 10;
    uint256 public constant TEAM_PERCENT = 10;
    uint256 public constant FUTURE_PERCENT = 40;

    // Finalization state of the contract
    bool private _finalized;

    // Event emitted when the contract is finalized
    event IsFinalized(address indexed owner);

    constructor(
        address presale,
        address crowdsale,
        address bounty,
        address seed,
        address reserve,
        address team,
        address future
    ) ERC20("YUP", "YUP") {
        require(presale != address(0) && crowdsale != address(0) && bounty != address(0) && seed != address(0) && reserve != address(0) && team != address(0) && future != address(0), "NYToken: addresses cannot be zero");

        // Total token supply is 1 billion
        uint256 totalSupply = 1e9 * (10 ** uint256(decimals()));

        // Distribute tokens based on defined percentages
        _mint(presale, totalSupply * PRESALE_PERCENT / 100);
        _mint(crowdsale, totalSupply * CROWDSALE_PERCENT / 100);
        _mint(bounty, totalSupply * BOUNTY_PERCENT / 100);
        _mint(seed, totalSupply * SEED_PERCENT / 100);
        _mint(reserve, totalSupply * RESERVE_PERCENT / 100);
        _mint(team, totalSupply * TEAM_PERCENT / 100);
        _mint(future, totalSupply * FUTURE_PERCENT / 100);
    }

    // Modifier to make a function callable only when the contract is not finalized.
    modifier notFinalized() {
        require(!_finalized, "NYToken: contract is already finalized");
        _;
    }

    // Modifier to make a function callable only when the contract is finalized.
    modifier isFinalized() {
        require(_finalized, "NYToken: contract is not finalized");
        _;
    }

    // Finalize the contract. Can only be called by the contract owner and when the contract is not paused.
    function finalize() public onlyOwner whenNotPaused notFinalized {
        _finalized = true;
        emit IsFinalized(_msgSender());
    }

    // Override ERC20 transfer function. Adds additional restrictions.
    function transfer(address recipient, uint256 amount) public override whenNotPaused notFinalized returns (bool) {
        return super.transfer(recipient, amount);
    }

    // Override ERC20 transferFrom function. Adds additional restrictions.
    function transferFrom(address sender, address recipient, uint256 amount) public override whenNotPaused notFinalized returns (bool) {
        return super.transferFrom(sender, recipient, amount);
    }
}
