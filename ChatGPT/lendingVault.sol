// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract MyV2CreditDelegation {
    struct Loan {
        address borrower;
        address collateralAsset;
        uint256 collateralAmount;
        uint256 borrowAmount;
        uint256 borrowRate;
        uint256 loanStartTime;
        uint256 loanDuration;
        bool active;
    }

    address public admin;
    mapping(address => uint256) public collateralBalances;
    mapping(address => Loan) public loans;

    event CollateralDeposited(address indexed user, address indexed asset, uint256 amount);
    event CreditRequested(address indexed borrower, address indexed collateralAsset, uint256 borrowAmount);
    event LoanRepaid(address indexed borrower, uint256 repaymentAmount);
    event CollateralWithdrawn(address indexed user, address indexed asset, uint256 amount);

    constructor() {
        admin = msg.sender;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can call this function");
        _;
    }

    function depositCollateral(address _asset, uint256 _amount) external {
        require(_amount > 0, "Amount must be greater than zero");
        IERC20(_asset).transferFrom(msg.sender, address(this), _amount);
        collateralBalances[_asset] += _amount;
        emit CollateralDeposited(msg.sender, _asset, _amount);
    }

    function requestCredit(address _collateralAsset, uint256 _borrowAmount) external {
        require(collateralBalances[_collateralAsset] >= _borrowAmount, "Insufficient collateral");
        
        // For demonstration, assuming borrow is approved instantly
        loans[msg.sender] = Loan({
            borrower: msg.sender,
            collateralAsset: _collateralAsset,
            collateralAmount: _borrowAmount,
            borrowAmount: _borrowAmount,
            borrowRate: 2, // Assuming fixed rate for demonstration
            loanStartTime: block.timestamp,
            loanDuration: 30 days, // Assuming a 30-day loan duration for demonstration
            active: true
        });
        
        emit CreditRequested(msg.sender, _collateralAsset, _borrowAmount);
    }

    function repayLoan() external {
        Loan storage loan = loans[msg.sender];
        require(loan.active, "No active loan");
        
        // For demonstration, assuming loan is repaid instantly
        loan.active = false;
        IERC20(loan.collateralAsset).transferFrom(msg.sender, address(this), loan.borrowAmount);
        
        emit LoanRepaid(msg.sender, loan.borrowAmount);
    }

    function checkBalance(address _user) external view returns (uint256) {
        Loan storage loan = loans[_user];
        require(loan.active, "No active loan");
        
        return loan.borrowAmount;
    }

    function withdrawCollateral(address _asset) external {
        require(!loans[msg.sender].active, "Cannot withdraw collateral while loan is active");
        
        uint256 amountToWithdraw = collateralBalances[_asset];
        require(amountToWithdraw > 0, "No collateral to withdraw");
        
        collateralBalances[_asset] = 0;
        IERC20(_asset).transfer(msg.sender, amountToWithdraw);
        
        emit CollateralWithdrawn(msg.sender, _asset, amountToWithdraw);
    }

    function setAdmin(address _admin) external onlyAdmin {
        admin = _admin;
    }
}
