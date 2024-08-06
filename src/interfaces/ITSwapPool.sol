// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.20;

// q-a why are we only using pool token?
// a we shouldnt be , its a bug

interface ITSwapPool {
    function getPriceOfOnePoolTokenInWeth() external view returns (uint256);
}

// ✅
