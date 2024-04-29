
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Importing OpenZeppelin's Crowdsale and FinalizableCrowdsale contracts
import "@openzeppelin/contracts/crowdsale/Crowdsale.sol";
import "@openzeppelin/contracts/crowdsale/FinalizableCrowdsale.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/ownership/Ownable.sol";

contract SirinCrowdsale is FinalizableCrowdsale, Ownable {
    using SafeMath for uint256;

    uint256 public constant MAX_TOKEN_GRANTEES = 1000;
    uint256 public constant EXCHANGE_RATE = 1000;
    uint256 public constant REFUND_DIVISION_RATE = 2;
    
    // Storage for wallet addresses for different allocations
    address[] public walletAddresses;

    // Total funds raised outside the crowdsale in wei
    uint256 public fiatRaisedConverted;

    // Mapping of presale grantees' addresses to token amounts
    mapping(address => uint256) public presaleGranteesMap;

    // Instance of the RefundVault contract
    RefundVault public refundVault;

    // Events
    event GrantAdded(address indexed _grantee, uint256 _amount);
    event GrantUpdated(address indexed _grantee, uint256 _amount);
    event GrantDeleted(address indexed _grantee);
    event FiatRaisedUpdated(uint256 _fiatRaisedConverted);
    event TokenPurchaseWithGuarantee(address indexed _beneficiary, uint256 _amount);

    constructor(
        uint256 _openingTime,
        uint256 _closingTime,
        address _wallet,
        ERC20 _token,
        RefundVault _refundVault
    )
        FinalizableCrowdsale()
        Crowdsale(EXCHANGE_RATE, _wallet, _token)
        TimedCrowdsale(_openingTime, _closingTime)
        public
    {
        refundVault = _refundVault;
    }

    // Calculates the rate in SRN per 1 ETH based on the current time
    function getRate() public view returns (uint256) {
        return rate;
    }

    // Finalizes the crowdsale
    function finalization() internal override {
        super.finalization();

        // additional finalization logic
    }

    // Checks if the crowdsale is active
    function isActive() public view returns (bool) {
        return (now >= openingTime && now <= closingTime);
    }

    // Returns the total funds raised in wei
    function getTotalFundsRaised() public view returns (uint256) {
        return weiRaised.add(fiatRaisedConverted);
    }

    // Adds or updates token grants for presale grantees
    function addUpdateGrantee(address _grantee, uint256 _amount) public onlyOwner {
        require(_grantee != address(0), "Invalid grantee address");
        require(_amount > 0, "Amount must be greater than 0");

        presaleGranteesMap[_grantee] = _amount;

        emit GrantUpdated(_grantee, _amount);
    }

    // Deletes token grants for a grantee
    function deleteGrantee(address _grantee) public onlyOwner {
        require(_grantee != address(0), "Invalid grantee address");

        delete presaleGranteesMap[_grantee];

        emit GrantDeleted(_grantee);
    }

    // Sets the funds raised outside crowdsale in wei
    function setFiatRaisedConvertedToWei(uint256 _amount) public onlyOwner {
        fiatRaisedConverted = _amount;

        emit FiatRaisedUpdated(_amount);
    }

    // Buys tokens with a guarantee
    function buyTokensWithGuarantee(address _beneficiary) public payable {
        uint256 weiAmount = msg.value;
        _preValidatePurchase(_beneficiary, weiAmount);

        // calculate token amount to be created
        uint256 tokens = _getTokenAmount(weiAmount);

        // update state
        weiRaised = weiRaised.add(weiAmount);

        _processPurchase(_beneficiary, tokens);
        emit TokenPurchaseWithGuarantee(msg.sender, _beneficiary, weiAmount, tokens);

        _updatePurchasingState(_beneficiary, weiAmount);

        _forwardFunds();
        _postValidatePurchase(_beneficiary, weiAmount);
    }

    // Override to extend the way in which ether is converted to tokens
    function _getTokenAmount(uint256 weiAmount) internal view override returns (uint256) {
        return weiAmount.mul(getRate());
    }

    // Determines how ETH is stored/forwarded on purchases
    function _forwardFunds() internal override {
        refundVault.deposit.value(msg.value)(msg.sender);
    }
}
