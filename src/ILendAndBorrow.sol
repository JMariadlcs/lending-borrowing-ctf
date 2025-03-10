// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.27;

contract ILendAndBorrow {

    uint256 public constant MIN_LEND = 10 * 1e18;
    uint256 public constant MAX_LEND = 10_000 * 1e18;

    struct Pool {
        uint256 minLend;
        uint256 maxLend;
        uint256 maxTotalAmount;
        uint256 totalLend;
        uint256 totalBorrow;
        address collateralToken;
        bool isActive;
    }


}