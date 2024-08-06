// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

// @audit-low this isn't implemented in the ThunderLoan contract

interface IThunderLoan {
    // @audit-low/info
    function repay(address token, uint256 amount) external;
}

