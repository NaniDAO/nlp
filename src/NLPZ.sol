// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.19;

/// @notice NANI LP ZAP
contract NLPZ {
    address constant NANI = 0x00000000000007C8612bA63Df8DdEfD9E6077c97;
    address constant WETH = 0x4200000000000000000000000000000000000006;
    address constant DAO = 0xDa000000000000d2885F108500803dfBAaB2f2aA;
    address constant LP = 0xB1CcEa7c214F8848B5Ae7F86218E25563f557bB3;
    address constant POS_MNGR = 0x03a520b32C04BF3bEEf7BEb72E919cf822Ed34f1;

    int24 constant TICK_SPACING = 60; // 0.3% pool.
    uint256 constant TWO_192 = 2 ** 192;

    error InsufficientOutput();

    constructor() payable {
        IERC20(NANI).approve(POS_MNGR, type(uint256).max);
        IERC20(WETH).approve(POS_MNGR, type(uint256).max);
    }

    function contribute(address to) public payable {
        unchecked {
            assembly ("memory-safe") {
                pop(call(gas(), WETH, callvalue(), codesize(), 0x00, codesize(), 0x00))
            }

            (uint160 sqrtPriceX96, int24 currentTick,,,,,) = IUniswapV3Pool(LP).slot0();

            uint256 liquidityPortion = msg.value;

            // Calculate NANI amount for LP based on price:
            uint256 naniForLP =
                (liquidityPortion * TWO_192) / (uint256(sqrtPriceX96) * uint256(sqrtPriceX96));

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
            if ((liquidityPortion = IERC20(WETH).balanceOf(address(this))) != 0) {
                IERC20(WETH).transfer(msg.sender, liquidityPortion);
            }
        }
    }

    function contributeFullRange(address to) public payable {
        unchecked {
            assembly ("memory-safe") {
                pop(call(gas(), WETH, callvalue(), codesize(), 0x00, codesize(), 0x00))
            }

            (uint160 sqrtPriceX96,,,,,,) = IUniswapV3Pool(LP).slot0();

            uint256 liquidityPortion = msg.value;

            // Calculate NANI amount for LP based on price:
            uint256 naniForLP =
                (liquidityPortion * TWO_192) / (uint256(sqrtPriceX96) * uint256(sqrtPriceX96));

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
            if ((liquidityPortion = IERC20(WETH).balanceOf(address(this))) != 0) {
                IERC20(WETH).transfer(msg.sender, liquidityPortion);
            }
        }
    }

    function withdraw(uint256 amount) public payable {
        require(msg.sender == DAO);
        IERC20(NANI).transfer(DAO, amount);
    }

    receive() external payable {
        contribute(msg.sender);
    }
}

interface IERC20 {
    function balanceOf(address) external view returns (uint256);
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
}
