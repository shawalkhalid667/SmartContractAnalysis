solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract StoxSmartToken is ERC20 {
    constructor() ERC20("Stox Smart Token", "STX") {}
}

contract Trustee {
    using SafeMath for uint256;
    StoxSmartToken public stoxSmartToken;
    
    constructor(address _stoxSmartToken) {
        stoxSmartToken = StoxSmartToken(_stoxSmartToken);
    }
    
    function distributeTokens(address _to, uint256 _amount) external {
        stoxSmartToken.transfer(_to, _amount);
    }
}

contract StoxSmartTokenSale is Ownable {
    using SafeMath for uint256;

    enum SaleState { NotStarted, Ongoing, Ended }
    SaleState public saleState = SaleState.NotStarted;

    StoxSmartToken public stoxSmartToken;
    Trustee public trustee;
    uint256 public startTime;
    uint256 public endTime;
    address payable public fundingRecipient;
    uint256 public tokenRate;

    event TokensIssued(address indexed recipient, uint256 amount);

    modifier onlyDuringSale {
        require(saleState == SaleState.Ongoing, "Sale must be ongoing");
        _;
    }

    modifier onlyAfterSale {
        require(saleState == SaleState.Ended, "Sale must have ended");
        _;
    }

    constructor(
        address _stoxSmartToken,
        address _trustee,
        uint256 _startTime,
        uint256 _endTime,
        address payable _fundingRecipient,
        uint256 _tokenRate
    ) {
        stoxSmartToken = StoxSmartToken(_stoxSmartToken);
        trustee = Trustee(_trustee);
        startTime = _startTime;
        endTime = _endTime;
        fundingRecipient = _fundingRecipient;
        tokenRate = _tokenRate;
    }

    function startSale() external onlyOwner {
        saleState = SaleState.Ongoing;
    }

    function endSale() external onlyOwner onlyDuringSale {
        saleState = SaleState.Ended;
    }

    function distributePartnerTokens(address _partner, uint256 _amount) external onlyOwner onlyAfterSale {
        trustee.distributeTokens(_partner, _amount);
    }

    function finalize() external onlyOwner onlyAfterSale {
        stoxSmartToken.transferOwnership(owner());
        trustee.transferOwnership(owner());
    }

    function create(address _recipient) external payable onlyDuringSale {
        uint256 tokenAmount = msg.value.mul(tokenRate);
        stoxSmartToken.transfer(_recipient, tokenAmount);
        fundingRecipient.transfer(msg.value);
        emit TokensIssued(_recipient, tokenAmount);
    }
}
