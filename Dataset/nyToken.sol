pragma solidity 0.8.25;

import "../node_modules/zeppelin-solidity/contracts/ownership/Ownable.sol";
import "../node_modules/zeppelin-solidity/contracts/token/ERC20/StandardToken.sol";
import "../node_modules/zeppelin-solidity/contracts/math/SafeMath.sol";
import "../node_modules/zeppelin-solidity/contracts/ownership/CanReclaimToken.sol";
import "../node_modules/zeppelin-solidity/contracts/lifecycle/Pausable.sol";


contract NYToken is Ownable, StandardToken, CanReclaimToken, Pausable {
    using SafeMath for uint256;
    
    /** State variables **/
    string public constant name = "YUP";
    string public constant symbol = "YUP";
    uint256 public constant decimals = 18;
    address public presaleFund;
    address public crowdsaleFund;
    address public bountyFund;
    address public seedFund;
    address public reserveFund;
    address public teamFund;
    address public futureFund;
    bool public finalized;
    
    event IsFinalized(uint256 _time);   //Event to signal that contract is closed for balance loading
    
    /** Modifiers **/
    modifier isFinalized() {
        require(finalized == true);
        _;
    }
    
    modifier notFinalized() {
        require(finalized == false);
        _;
    }
    
    /** Constructor **/
    function NYToken(
        address _presaleFund,
        address _crowdsaleFund,
        address _bountyFund,
        address _seedFund,
        address _reserveFund,
        address _teamFund,
        address _futureFund
    ) public {
        totalSupply_ = 445 * (10**6) * (10**decimals);  //445 million tokens (with 18 decimals)
        presaleFund = _presaleFund;
        crowdsaleFund = _crowdsaleFund;
        bountyFund = _bountyFund;
        seedFund = _seedFund;
        reserveFund = _reserveFund;
        teamFund = _teamFund;
        futureFund = _futureFund;
        finalized = false;
        
        /*********************************************************************
        
        presaleShare            =>   109441916283952000000000000      //24.59%
        crowdsaleShare          =>   90808083716048200000000000       //20.41%
        bountyShare             =>   totalSupply_.div(100);           // 1%
        seedShare               =>   totalSupply_.div(100).mul(5);    // 5%
        reserveShare            =>   totalSupply_.div(100).mul(10);   //10%
        futureUseShare          =>   totalSupply_.div(100).mul(19);   //19%
        teamAndAdvisorsShare    =>   totalSupply_.div(100).mul(20);   //20%
        
        *********************************************************************/
        
        balances[presaleFund] = 109441916283952000000000000;        //presaleShare
        Transfer(0x0, address(presaleFund), 109441916283952000000000000);

        balances[crowdsaleFund] = 90808083716048200000000000;       //crowdsaleShare
        Transfer(0x0, address(crowdsaleFund), 90808083716048200000000000);
        
        balances[bountyFund] = totalSupply_.div(100);               //bountyShare
        Transfer(0x0, address(bountyFund), totalSupply_.div(100));
        
        balances[seedFund] = totalSupply_.div(100).mul(5);          //seedShare
        Transfer(0x0, address(seedFund), totalSupply_.div(100).mul(5));
        
        balances[reserveFund] = totalSupply_.div(100).mul(10);      //reserveShare
        Transfer(0x0, address(reserveFund), totalSupply_.div(100).mul(10));

        balances[futureFund] = totalSupply_.div(100).mul(19);       //futureUseShare
        Transfer(0x0, address(futureFund), totalSupply_.div(100).mul(19));
        
        balances[teamFund] = totalSupply_.div(100).mul(20);         //teamAndAdvisorsShare
        Transfer(0x0, address(teamFund), totalSupply_.div(100).mul(20));
    }
    
    /** Overridden transfer method to facilitate emergency pausing **/
    function transfer(address _to, uint256 _value) public whenNotPaused isFinalized returns (bool) {
        return super.transfer(_to, _value);
    }
    
    /** Overridden transferFrom method to facilitate emergency pausing **/
    function transferFrom(address _from, address _to, uint256 _value) public whenNotPaused isFinalized returns (bool) {
        return super.transferFrom(_from, _to, _value);
    }
    
    /** Allows owner to finalize contract **/
    function finalize() public notFinalized onlyOwner {
        finalized = true;
        IsFinalized(now);
    }
}
