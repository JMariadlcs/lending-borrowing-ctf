// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.27;

import "./interfaces/ILendAndBorrow.sol";
import "./interfaces/IOracle.sol";

import "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "../lib/openzeppelin-contracts/contracts/utils/Pausable.sol";
import "../lib/openzeppelin-contracts/contracts/utils/ReentrancyGuard.sol";
import "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";

contract LendAndBorrow is Ownable, ILendAndBorrow, Pausable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    uint256 public poolCounter;
    address public lendingBorrowToken;
    address public oracle;
    uint256 public borrowRatePerSecond = 0.001 * 1e18; 

    mapping(uint256 => Pool) public activePools;
    mapping(address => uint256) public lendings;
    mapping(address => uint256) public borrows;
    mapping(address => uint256) public borrowTimestamps; 
    mapping(address => mapping(uint256 => uint256)) collateralAmountInPool;

    event CreatePool(uint256 poolId);
    event Lended(uint256 pool, address user, uint256 amount);
    event Borrowed(uint256 pool, uint256 borrowAmount, uint256 collateralAmount, address collateralToken);
    event Liquidated(address borrower, uint256 pool, uint256 totalSeizableCollateral, address liquidator);
    event DebtRepaid(address borrower, uint256 pool, uint256 principalRepaid, uint256 feeRepaid);

    constructor(address lendingBorrowToken_, address oracle_) Ownable(msg.sender) {
        lendingBorrowToken = lendingBorrowToken_;
        oracle = oracle_;
    }

     /**
    * @notice Allows admin to add new pool
    * @param poolDetails pool to be added
    */
    function createPool(Pool memory poolDetails) public onlyOwner {
        require(poolDetails.minLend >= MIN_LEND, "Incorrect minimum lend");
        require(poolDetails.maxLend <= MAX_LEND, "Incorrect maximum lend");

        activePools[poolCounter] = Pool({
            minLend: poolDetails.minLend,
            maxLend: poolDetails.maxLend,
            maxTotalLendingAmount: poolDetails.maxTotalLendingAmount,
            totalLend: 0,
            totalBorrow: 0,
            collateralToken: poolDetails.collateralToken,
            collateralizationRatio: poolDetails.collateralizationRatio,
            isActive: true
        });

        poolCounter++;

        emit CreatePool(poolCounter - 1);
    }

     /**
    * @notice User can deposit lendingToken and earn intereset
    */
    function lend(uint256 amount, uint256 pool) public whenNotPaused nonReentrant {
        Pool storage requestedPool = activePools[pool];
        require(requestedPool.totalLend + amount <= requestedPool.maxTotalLendingAmount, "Pool is full");
        require(amount >= requestedPool.minLend, "Incorrect minimum lend");
        require(amount <= requestedPool.maxLend, "Incorrect maximum lend");

        IERC20(lendingBorrowToken).safeTransferFrom(msg.sender, address(this), amount);
        lendings[msg.sender] = amount;
        requestedPool.totalLend += amount;

        emit Lended(pool, msg.sender, amount);
    }

    function borrow(uint256 pool, uint256 borrowAmount, uint256 collateralAmount, address collateralToken) public whenNotPaused nonReentrant {
        uint256 neededCollateralAmount = getNeededCollateralAmount(borrowAmount, pool); 

        require(collateralAmount >= neededCollateralAmount, "Insufficient collateral amount");
        IERC20(collateralToken).safeTransferFrom(msg.sender, address(this), collateralAmount);

        borrows[msg.sender] = borrowAmount;
        borrowTimestamps[msg.sender] = block.timestamp; 
        collateralAmountInPool[msg.sender][pool] = collateralAmount;
        IERC20(lendingBorrowToken).safeTransfer(msg.sender, borrowAmount);

        emit Borrowed(pool, borrowAmount, collateralAmount, collateralToken);
    }

    function getAccruedFee(address borrower) public view returns (uint256) {
        if (borrows[borrower] == 0) return 0;
        
        uint256 timeElapsed = block.timestamp - borrowTimestamps[borrower];
        return (borrows[borrower] * borrowRatePerSecond * timeElapsed) / 1e18;
    }

    function getNeededCollateralAmount(uint256 borrowAmount, uint256 pool) public returns (uint256) {
        Pool memory requestedPool = activePools[pool];
        address poolCollateralToken = requestedPool.collateralToken;
        
        uint256 collateralTokenPrice = IOracle(oracle).getPrice(poolCollateralToken);
        require(collateralTokenPrice > 0, "Invalid collateral price");

        uint256 accruedFee = getAccruedFee(msg.sender);
        uint256 totalDebt = borrowAmount + accruedFee;

        return (totalDebt * requestedPool.collateralizationRatio * 1e18) / collateralTokenPrice;
    }

    function repay(uint256 amount, uint256 pool) public whenNotPaused nonReentrant {
        require(amount > 0, "Repayment amount must be greater than zero");
        
        Pool storage requestedPool = activePools[pool];
        require(requestedPool.isActive, "Pool is not active");

        uint256 borrowedAmount = borrows[msg.sender];
        require(borrowedAmount > 0, "No active loan");

        uint256 accruedFee = getAccruedFee(msg.sender);
        uint256 totalDebt = borrowedAmount + accruedFee;

        require(amount <= totalDebt, "Repayment exceeds total debt");

        // Transfer repayment amount from user to contract
        IERC20(lendingBorrowToken).safeTransferFrom(msg.sender, address(this), amount);

        // Repay the accrued fee first
        if (amount >= accruedFee) {
            amount -= accruedFee;
            accruedFee = 0; // Fully paid off fees
        } else {
            accruedFee -= amount;
            amount = 0; // Full repayment used for fees
        }

        // Reduce the principal if there's remaining repayment amount
        if (amount > 0) {
            borrowedAmount -= amount;
        }

        // Update state variables
        borrows[msg.sender] = borrowedAmount;
        borrowTimestamps[msg.sender] = block.timestamp; // Reset timestamp to avoid extra fees

        // Ensure the borrower's position is still healthy
        uint256 newRequiredCollateral = getNeededCollateralAmount(borrowedAmount, pool);
        require(collateralAmountInPool[msg.sender][pool] >= newRequiredCollateral, "Not enough collateral after repayment");

        emit DebtRepaid(msg.sender, pool, amount, accruedFee);
    }

    function liquidate(address borrower, uint256 pool) public whenNotPaused nonReentrant {
        Pool storage requestedPool = activePools[pool];
        require(requestedPool.isActive, "Pool is not active");

        uint256 borrowedAmount = borrows[borrower];
        require(borrowedAmount > 0, "No active loan");

        uint256 accruedFee = getAccruedFee(borrower);
        uint256 totalDebt = borrowedAmount + accruedFee;
        uint256 collateralAmount = collateralAmountInPool[borrower][pool];
        address collateralToken = requestedPool.collateralToken;
        
        uint256 collateralPrice = IOracle(oracle).getPrice(collateralToken);
        require(collateralPrice > 0, "Invalid collateral price");

        uint256 requiredCollateral = (totalDebt * requestedPool.collateralizationRatio * 1e18) / collateralPrice;
        require(collateralAmount < requiredCollateral, "Collateral is sufficient");

        uint256 totalSeizableCollateral = collateralAmount;

        IERC20(collateralToken).safeTransfer(msg.sender, totalSeizableCollateral);

        borrows[borrower] = 0;
        borrowTimestamps[borrower] = 0;
        collateralAmountInPool[borrower][pool] = 0;

        emit Liquidated(borrower, pool, totalSeizableCollateral, msg.sender);
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unPause() external onlyOwner {
        _unpause();
    }
}
