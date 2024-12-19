// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.19;

contract NSFW {
    address constant NANI = 0x00000000000007C8612bA63Df8DdEfD9E6077c97; // token0
    address constant WETH = 0x4200000000000000000000000000000000000006; // token1
    address constant LP = 0xB1CcEa7c214F8848B5Ae7F86218E25563f557bB3; // nanilp

    uint160 internal constant MAX_SQRT_RATIO_MINUS_ONE =
        1461446703485210103287273052203988822378723970341;

    constructor() payable {}

    error InsufficientOut();

    function swap(address to, uint256 minOut) public payable {
        (int256 amount0,) =
            ISwap(LP).swap(to, false, int256(msg.value), MAX_SQRT_RATIO_MINUS_ONE, "");
        if (uint256(amount0) < minOut) revert InsufficientOut();
    }

    fallback() external payable {
        assembly ("memory-safe") {
            let amount1Delta := calldataload(0x24)
            pop(call(gas(), WETH, amount1Delta, codesize(), 0x00, codesize(), 0x00))
            mstore(0x00, 0xa9059cbb000000000000000000000000)
            mstore(0x14, LP)
            mstore(0x34, amount1Delta)
            pop(call(gas(), WETH, 0, 0x10, 0x44, codesize(), 0x00))
        }
    }

    receive() external payable {
        ISwap(LP).swap(msg.sender, false, int256(msg.value), MAX_SQRT_RATIO_MINUS_ONE, "");
    }
}

interface ISwap {
    function swap(address, bool, int256, uint160, bytes calldata)
        external
        returns (int256, int256);
}
