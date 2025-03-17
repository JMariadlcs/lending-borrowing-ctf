// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.27;

interface IOracle {
    function getPrice(address tokenAddress) external returns(uint256);
}