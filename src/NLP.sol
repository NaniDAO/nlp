// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.19;

/// @notice NANI LP
/// @author z0r0z.eth (liquid swap accoutrement)
/// @custom:coauthor tabish.eth (lottery magick)
contract NLP {
    address constant NANI = 0x00000000000007C8612bA63Df8DdEfD9E6077c97;
    address constant WETH = 0x4200000000000000000000000000000000000006;
    address constant DAO = 0xDa000000000000d2885F108500803dfBAaB2f2aA;
    address constant LP = 0xB1CcEa7c214F8848B5Ae7F86218E25563f557bB3;
    address constant POS_MNGR = 0x03a520b32C04BF3bEEf7BEb72E919cf822Ed34f1;

    uint160 constant MAX_SQRT_RATIO_MINUS_ONE = 1461446703485210103287273052203988822378723970341;
    int24 constant TICK_SPACING = 60; // 0.3% pool.

    uint256 constant MIN_DISCOUNT = 66;
    uint256 constant MAX_DISCOUNT = 95;
    uint256 constant TWO_192 = 2 ** 192;

    error InsufficientOutput();

    constructor() payable {
        IERC20(NANI).approve(POS_MNGR, type(uint256).max);
        IERC20(WETH).approve(POS_MNGR, type(uint256).max);
    }

    function contribute(address to, uint256 minOut) public payable {
        unchecked {
            assembly ("memory-safe") {
                pop(call(gas(), WETH, callvalue(), codesize(), 0x00, codesize(), 0x00))
            }

            (uint160 sqrtPriceX96, int24 currentTick,,,,,) = IUniswapV3Pool(LP).slot0();
            uint256 random = _randomish(sqrtPriceX96, currentTick);

            if (random % 2 == 0) {
                uint256 liquidityPortion = (msg.value * 4) / 5;

                // Calculate discounted NANI amount for LP position:
                uint256 naniForLP = (liquidityPortion * TWO_192)
                    / (uint256(sqrtPriceX96) * uint256(sqrtPriceX96)) * 100
                    / (MIN_DISCOUNT + (random % (MAX_DISCOUNT - MIN_DISCOUNT + 1)));

                INonfungiblePositionManager.MintParams memory params = INonfungiblePositionManager
                    .MintParams({
                    token0: NANI,
                    token1: WETH,
                    fee: 3000,
                    tickLower: (currentTick - 600) / 60 * 60,
                    tickUpper: (currentTick + 600) / 60 * 60,
                    amount0Desired: naniForLP,
                    amount1Desired: liquidityPortion,
                    amount0Min: 0,
                    amount1Min: 0,
                    recipient: to,
                    deadline: block.timestamp
                });

                INonfungiblePositionManager(POS_MNGR).mint(params);

                (int256 swapNANI,) = IUniswapV3Pool(LP).swap(
                    to, false, int256(msg.value - liquidityPortion), MAX_SQRT_RATIO_MINUS_ONE, ""
                );
                if (naniForLP + uint256(-(swapNANI)) < minOut) revert InsufficientOutput();
            } else {
                (int256 amount0,) = IUniswapV3Pool(LP).swap(
                    to, false, int256(msg.value), MAX_SQRT_RATIO_MINUS_ONE, ""
                );
                if (uint256(-(amount0)) < minOut) revert InsufficientOutput();
            }
        }
    }

    function contributeFullRange(address to, uint256 minOut) public payable {
        unchecked {
            assembly ("memory-safe") {
                pop(call(gas(), WETH, callvalue(), codesize(), 0x00, codesize(), 0x00))
            }

            (uint160 sqrtPriceX96, int24 currentTick,,,,,) = IUniswapV3Pool(LP).slot0();
            uint256 random = _randomish(sqrtPriceX96, currentTick);

            if (random % 2 == 0) {
                uint256 liquidityPortion = (msg.value * 4) / 5;

                // Calculate discounted NANI amount for LP position:
                uint256 naniForLP = (liquidityPortion * TWO_192)
                    / (uint256(sqrtPriceX96) * uint256(sqrtPriceX96)) * 100
                    / (MIN_DISCOUNT + (random % (MAX_DISCOUNT - MIN_DISCOUNT + 1)));

                INonfungiblePositionManager.MintParams memory params = INonfungiblePositionManager
                    .MintParams({
                    token0: NANI,
                    token1: WETH,
                    fee: 3000,
                    tickLower: -887220,
                    tickUpper: 887220,
                    amount0Desired: naniForLP,
                    amount1Desired: liquidityPortion,
                    amount0Min: 0,
                    amount1Min: 0,
                    recipient: to,
                    deadline: block.timestamp
                });

                INonfungiblePositionManager(POS_MNGR).mint(params);

                (int256 swapNANI,) = IUniswapV3Pool(LP).swap(
                    to, false, int256(msg.value - liquidityPortion), MAX_SQRT_RATIO_MINUS_ONE, ""
                );
                if (naniForLP + uint256(-(swapNANI)) < minOut) revert InsufficientOutput();
            } else {
                (int256 amount0,) = IUniswapV3Pool(LP).swap(
                    to, false, int256(msg.value), MAX_SQRT_RATIO_MINUS_ONE, ""
                );
                if (uint256(-(amount0)) < minOut) revert InsufficientOutput();
            }
        }
    }

    function inscribe() public payable {}

    function tribute() public payable {
        assembly ("memory-safe") {
            pop(call(gas(), DAO, selfbalance(), codesize(), 0x00, codesize(), 0x00))
        }
    }

    function withdraw(uint256 amount) public payable {
        require(msg.sender == DAO);
        IERC20(NANI).transfer(DAO, amount);
    }

    function _randomish(uint160 sqrtPriceX96, int24 tick) internal view returns (uint256 r) {
        assembly ("memory-safe") {
            let m := mload(0x40)
            mstore(m, sqrtPriceX96)
            mstore(add(m, 0x20), tick)
            mstore(add(m, 0x40), caller())
            mstore(add(m, 0x60), selfbalance())
            mstore(add(m, 0x80), blockhash(sub(number(), 1)))
            mstore(add(m, 0xA0), timestamp())
            mstore(add(m, 0xC0), balance(DAO))
            mstore(add(m, 0xE0), gas())
            r := keccak256(m, 0x100)
        }
    }

    fallback() external payable {
        assembly ("memory-safe") {
            let amount1Delta := calldataload(0x24)
            mstore(0x00, 0xa9059cbb000000000000000000000000)
            mstore(0x14, LP)
            mstore(0x34, amount1Delta)
            pop(call(gas(), WETH, 0, 0x10, 0x44, codesize(), 0x00))
        }
    }

    receive() external payable {
        contribute(msg.sender, 0);
    }
}

interface IERC20 {
    function transfer(address, uint256) external returns (bool);
    function approve(address, uint256) external returns (bool);
}

interface INonfungiblePositionManager {
    struct MintParams {
        address token0;
        address token1;
        uint24 fee;
        int24 tickLower;
        int24 tickUpper;
        uint256 amount0Desired;
        uint256 amount1Desired;
        uint256 amount0Min;
        uint256 amount1Min;
        address recipient;
        uint256 deadline;
    }

    function mint(MintParams calldata)
        external
        payable
        returns (uint256, uint128, uint256, uint256);
}

interface IUniswapV3Pool {
    function slot0() external view returns (uint160, int24, uint16, uint16, uint16, uint8, bool);

    function swap(address, bool, int256, uint160, bytes calldata)
        external
        returns (int256, int256);
}
