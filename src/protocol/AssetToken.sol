// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.20;

import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

// e this is the token you get when you deposit tokens into the protocol
// this token you get back is also an ERC20

contract AssetToken is ERC20 {
    error AssetToken__onlyThunderLoan();
    error AssetToken__ExhangeRateCanOnlyIncrease(uint256 oldExchangeRate, uint256 newExchangeRate);
    error AssetToken__ZeroAddress();

    using SafeERC20 for IERC20;

    /*//////////////////////////////////////////////////////////////
                            STATE VARIABLES
    //////////////////////////////////////////////////////////////*/
    IERC20 private immutable i_underlying; // e the underlying token
    address private immutable i_thunderLoan; // e address of the thunder loan contract

    // The underlying per asset exchange rate
    // ie: s_exchangeRate = 2
    // means 1 asset token is worth 2 underlying tokens

    // e underlying == token deposited by whales
    // assetToken == shares recd by the whales in return
    // how to many shares to give based on number of tokens deposited == s_exchangeRate
    uint256 private s_exchangeRate;
    uint256 public constant EXCHANGE_RATE_PRECISION = 1e18; // q means 18 DP?
    uint256 private constant STARTING_EXCHANGE_RATE = 1e18; // e 1 assetToken for 1 underlying in the very start

    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/
    event ExchangeRateUpdated(uint256 newExchangeRate);

    /*//////////////////////////////////////////////////////////////
                               MODIFIERS
    //////////////////////////////////////////////////////////////*/

    // e only the `ThunderLoan` contract can access
    modifier onlyThunderLoan() {
        if (msg.sender != i_thunderLoan) {
            revert AssetToken__onlyThunderLoan();
        }
        _;
    }

    modifier revertIfZeroAddress(address someAddress) {
        if (someAddress == address(0)) {
            revert AssetToken__ZeroAddress();
        }
        _;
    }

    /*//////////////////////////////////////////////////////////////
                               FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    constructor(
        address thunderLoan,
        IERC20 underlying, 
        // q-a where are the tokens stored?
        // a in the asset token contract
        string memory assetName,
        string memory assetSymbol
    )
        ERC20(assetName, assetSymbol)
        revertIfZeroAddress(thunderLoan)
        revertIfZeroAddress(address(underlying))
    {
        i_thunderLoan = thunderLoan;
        i_underlying = underlying;
        s_exchangeRate = STARTING_EXCHANGE_RATE;
    }
    // q-a ok , so only the thunder loan can mint tokens? (same for "burn")
    // a yeah 
    function mint(address to, uint256 amount) external onlyThunderLoan {
        _mint(to, amount);
    }

    function burn(address account, uint256 amount) external onlyThunderLoan {
        _burn(account, amount);
    }

    function transferUnderlyingTo(address to, uint256 amount) external onlyThunderLoan {
        // @audit weird ERC20s (only USDC is weird here(look at list of tokens to be used in this protocol in Readme) , which is a proxy itself wtf)
        // q-a what if USDC denylists the thunder loan contract or the asset token contract?
        // a protocol will be frozen
        // @audit-med weird ERC20 may denylist thunder loan contract or the asset token contract
        i_underlying.safeTransfer(to, amount);
    }

    function updateExchangeRate(uint256 fee) external onlyThunderLoan {
        // 1. Get the current exchange rate
        // 2. How big the fee is should be divided by the total supply
        // 3. So if the fee is 1e18, and the total supply is 2e18, the exchange rate be multiplied by 1.5
        // if the fee is 0.5 ETH, and the total supply is 4, the exchange rate should be multiplied by 1.125
        // it should always go up, never down 
        // INVARIANT !!!!!

        // let 5 USDC
        // 5 assetToken 
        // fee = 1
        // old exchange rate = 1
        // new exchange rate = 1*(5+1)/5 = 1.2

        // so if the LP wants to withdraw USDC via his assetTokens
        // # USDC == 5 assetToken * 1.2 = 6 USDC (which is the total USDC in the pool == 5 USDC + 1(fee) USDC)

        // @audit-gas cache s_exchangeRate
        
        // what if totalSupply is 0?
        // it breaks!! is that an issue?
        uint256 newExchangeRate = s_exchangeRate * (totalSupply() + fee) / totalSupply();

        if (newExchangeRate <= s_exchangeRate) {
            revert AssetToken__ExhangeRateCanOnlyIncrease(s_exchangeRate, newExchangeRate);
        }
        s_exchangeRate = newExchangeRate;
        emit ExchangeRateUpdated(s_exchangeRate);
    }

    function getExchangeRate() external view returns (uint256) {
        return s_exchangeRate;
    }

    function getUnderlying() external view returns (IERC20) {
        return i_underlying;
    }
}
