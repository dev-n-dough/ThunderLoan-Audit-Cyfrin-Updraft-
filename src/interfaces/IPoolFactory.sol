// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.20;

// e this is prolly the interface to work with PoolFactory.sol from t-swap
// q-a why are we using t-swap?
// a we need it to calculate the value of the token to get the fees
interface IPoolFactory {
    function getPool(address tokenAddress) external view returns (address);
}

// ✅
