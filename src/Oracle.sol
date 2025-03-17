// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.27;

contract Oracle {

    function getPrice(address token) external pure returns(uint256 price) {
        if (token == address(0)) revert();
        return 2000 * 1e18; // A fix price is returned for simplicity. Assume that this function works like a real Oracle
    }
}