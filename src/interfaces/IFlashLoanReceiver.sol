// SPDX-License-Identifier: AGPL-3.0
pragma solidity 0.8.20;

// @audit-info : unused import --> Comment it and try `forge build` -> do this to check where `IThunderLoan` is used THROUGH `IFlashLoanReceiver` 
// it is used in `MockFlashLoanReceiver.sol`
// it is bad practice to use live code in mocks
// also , in `MockFlashLoanReceiver.sol` we should import `IThunderLoan` directly and not via `IFlashLoanReceiver`
import { IThunderLoan } from "./IThunderLoan.sol"; 

/**
 * @dev Inspired by Aave:
 * https://github.com/aave/aave-v3-core/blob/master/contracts/flashloan/interfaces/IFlashLoanReceiver.sol
 */
interface IFlashLoanReceiver {
    function executeOperation(
        // @audit where the natspec at bruh
        address token,
        uint256 amount,
        uint256 fee,
        address initiator,
        bytes calldata params
    )
        external
        returns (bool);
}
