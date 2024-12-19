// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.19;

/// @notice Seller contract.
contract NaNs {
    address constant NANI = 0x00000000000007C8612bA63Df8DdEfD9E6077c97; // token0
    address constant WETH = 0x4200000000000000000000000000000000000006; // token1
    address constant LP = 0xB1CcEa7c214F8848B5Ae7F86218E25563f557bB3; // nanilp

    uint160 internal constant MIN_SQRT_RATIO_PLUS_ONE = 4295128740;

    constructor() payable {}

    error InsufficientOut();

    function sell(address to, uint256 amountIn, uint256 minOut) public payable {
        IERC20(NANI).transferFrom(msg.sender, address(this), amountIn);
        (, int256 amount1) = ISwap(LP).swap(to, true, int256(amountIn), MIN_SQRT_RATIO_PLUS_ONE, "");
        if (uint256(amount1) < minOut) revert InsufficientOut();
    }

    fallback() external payable {
        int256 amount0Delta;
        assembly {
            amount0Delta := calldataload(4)
        }
        if (amount0Delta > 0) {
            IERC20(NANI).transfer(LP, uint256(amount0Delta));
        }
    }

    receive() external payable {
        ISwap(LP).swap(msg.sender, false, int256(msg.value), MIN_SQRT_RATIO_PLUS_ONE, "");
    }
}

interface IERC20 {
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function transfer(address to, uint256 amount) external returns (bool);
}

interface ISwap {
    function swap(address, bool, int256, uint160, bytes calldata)
        external
        returns (int256, int256);
}
