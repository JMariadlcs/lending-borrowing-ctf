// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.27;

import "./ILendAndBorrow.sol";

import "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";

contract LendAndBorrow is Ownable, ILendAndBorrow {
    using SafeERC20 for IERC20;

    uint256 public poolCounter;
    address public borrowToken;
    mapping(uint256 => Pool) public activePools;

    event CreatePool(uint256 poolId);

    constructor(address borrowToken_) Ownable(msg.sender) {
        borrowToken = borrowToken_;
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
            maxTotalAmount: poolDetails.maxTotalAmount,
            totalLend: 0,
            totalBorrow: 0,
            isActive: true
        });

        poolCounter++;

        emit CreatePool(poolCounter - 1);
    }

    /**
    * @notice User can deposit lendingToken and earn intereset
    */
    function lend() public {

    }

    /**
    * @notice User can get borrowingToken and deposit collateral
    */
    function borrow() public {

    }

    /**
    * @notice Borrow can repay debt
    */
    function repay() public {

    }
}