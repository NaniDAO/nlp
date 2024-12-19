// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.19;

import {NLP, IUniswapV3Pool} from "../src/NLP.sol";
import {NSFW} from "../src/NSFW.sol";
import {NaNs} from "../src/NaNs.sol";
import {Test} from "../lib/forge-std/src/Test.sol";
import {console} from "forge-std/console.sol";

contract NLPTest is Test {
    NLP internal nlp;
    NSFW internal nsfw;
    NaNs internal nans;

    address constant NANI = 0x00000000000007C8612bA63Df8DdEfD9E6077c97;
    address constant WETH = 0x4200000000000000000000000000000000000006;
    address constant DAO = 0xDa000000000000d2885F108500803dfBAaB2f2aA;
    address constant LP = 0xB1CcEa7c214F8848B5Ae7F86218E25563f557bB3;

    address constant V = 0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045;
    address constant A = 0x999657A41753b8E69C66e7b1A8E37d513CB44E1C;
    address constant CTC = 0x0000000000cDC1F8d393415455E382c30FBc0a84;

    uint160 constant MAX_SQRT_RATIO_MINUS_ONE = 1461446703485210103287273052203988822378723970341;

    uint160 internal constant MIN_SQRT_RATIO_PLUS_ONE = 4295128740;

    address deployer;

    function setUp() public payable {
        uint256 deployerPrivateKey =
            0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;
        deployer = vm.addr(deployerPrivateKey);

        vm.startPrank(deployer);
        vm.createSelectFork(vm.rpcUrl("base"));
        nlp = new NLP();
        nsfw = new NSFW();
        nans = new NaNs();
        vm.stopPrank();

        vm.prank(A);
    }

    function testNormalSwapLowAmt() public payable {
        uint256 bal = IERC20(NANI).balanceOf(V);
        console.log(bal, "/vb starting bal");
        uint256 nBal = IERC20(NANI).balanceOf(address(LP));
        uint256 wBal = IERC20(WETH).balanceOf(address(LP));
        console.log(nBal, "/lp starting nani bal");
        console.log(wBal, "/lp starting weth bal");
        (uint256 price, string memory strPrice) = ICTC(CTC).checkPriceInETH(NANI);
        (uint256 priceUSDC, string memory strPriceUSDC) = ICTC(CTC).checkPriceInETHToUSDC(NANI);
        console.log(price, "/starting price in raw ETH");
        console.log(strPrice, "/starting price in ETH");
        console.log(priceUSDC, "/starting price in raw USDC");
        console.log(strPriceUSDC, "/starting price in USDC");

        vm.prank(V);
        nsfw.swap{value: 0.0015 ether}(V, 0);

        (price, strPrice) = ICTC(CTC).checkPriceInETH(NANI);
        (priceUSDC, strPriceUSDC) = ICTC(CTC).checkPriceInETHToUSDC(NANI);
        console.log(price, "/resulting price in raw ETH");
        console.log(strPrice, "/resulting price in ETH");
        console.log(priceUSDC, "/resulting price in raw USDC");
        console.log(strPriceUSDC, "/resulting price in USDC");
        bal = IERC20(NANI).balanceOf(V);
        console.log(bal, "/vb resulting bal");
        nBal = IERC20(NANI).balanceOf(address(LP));
        wBal = IERC20(WETH).balanceOf(address(LP));
        console.log(nBal, "/lp resulting nani bal");
        console.log(wBal, "/lp resulting weth bal");
    }

    function testNormalSwapHiAmt() public payable {
        uint256 bal = IERC20(NANI).balanceOf(V);
        console.log(bal, "/vb starting bal");
        uint256 nBal = IERC20(NANI).balanceOf(address(LP));
        uint256 wBal = IERC20(WETH).balanceOf(address(LP));
        console.log(nBal, "/lp starting nani bal");
        console.log(wBal, "/lp starting weth bal");
        (uint256 price, string memory strPrice) = ICTC(CTC).checkPriceInETH(NANI);
        (uint256 priceUSDC, string memory strPriceUSDC) = ICTC(CTC).checkPriceInETHToUSDC(NANI);
        console.log(price, "/starting price in raw ETH");
        console.log(strPrice, "/starting price in ETH");
        console.log(priceUSDC, "/starting price in raw USDC");
        console.log(strPriceUSDC, "/starting price in USDC");

        vm.prank(V);
        nsfw.swap{value: 0.001 ether}(V, 0);

        (price, strPrice) = ICTC(CTC).checkPriceInETH(NANI);
        (priceUSDC, strPriceUSDC) = ICTC(CTC).checkPriceInETHToUSDC(NANI);
        console.log(price, "/resulting price in raw ETH");
        console.log(strPrice, "/resulting price in ETH");
        console.log(priceUSDC, "/resulting price in raw USDC");
        console.log(strPriceUSDC, "/resulting price in USDC");
        bal = IERC20(NANI).balanceOf(V);
        console.log(bal, "/vb resulting bal");
        nBal = IERC20(NANI).balanceOf(address(LP));
        wBal = IERC20(WETH).balanceOf(address(LP));
        console.log(nBal, "/lp resulting nani bal");
        console.log(wBal, "/lp resulting weth bal");
    }

    function testSwapWithMinOut() public payable {
        // Retrieve the current price in ETH for NANI from the price checker
        (uint256 currentPrice,) = ICTC(CTC).checkPriceInETH(NANI);

        // ETH sent for the swap
        uint256 ethValue = 0.0015 ether;

        // Calculate expected NANI output based on the current price
        uint256 expectedNANI = (ethValue * 1e18) / currentPrice;

        // Apply a 5% buffer on minOut
        uint256 minOutWithBuffer = (expectedNANI * 95) / 100;

        // Log initial balances
        uint256 initialNaniBalance = IERC20(NANI).balanceOf(V);
        console.log("Initial NANI Balance:", initialNaniBalance);

        // Conduct swap with minOut
        vm.prank(V);
        nsfw.swap{value: ethValue}(V, minOutWithBuffer);

        // Log resulting balances
        uint256 finalNaniBalance = IERC20(NANI).balanceOf(V);
        console.log("Final NANI Balance:", finalNaniBalance);

        // Assert that the swap resulted in at least minOutWithBuffer amount of NANI
        assertTrue(
            finalNaniBalance - initialNaniBalance >= minOutWithBuffer,
            "Swap did not meet the minOut requirement"
        );
    }

    function testSwapBelowMinOut() public payable {
        // Retrieve the current price in ETH for NANI from the price checker
        (uint256 currentPrice,) = ICTC(CTC).checkPriceInETH(NANI);

        // ETH sent for the swap
        uint256 ethValue = 0.001 ether;

        // Calculate expected NANI output but set minOut higher than it should be
        uint256 expectedNANI = (ethValue * 1e18) / currentPrice;

        // Apply a 10% increase on minOut to force failure
        uint256 impossibleMinOut = (expectedNANI * 110) / 100;

        // Expect the InsufficientOut error
        vm.expectRevert(NSFW.InsufficientOut.selector);
        vm.prank(V);
        nsfw.swap{value: ethValue}(V, impossibleMinOut);
    }

    function testContributeLowAmt() public payable {
        (uint256 price,) = ICTC(CTC).checkPriceInETH(NANI);
        uint256 expectedNANI = (0.001 ether) / price; // ETH * 1e18 / (ETH/NANI) = NANI
        uint256 minOut = (expectedNANI * 95) / 100; // 95% of expected NANI amount

        uint256 bal = IERC20(NANI).balanceOf(V);
        console.log(bal, "/vb starting bal");
        uint256 nBal = IERC20(NANI).balanceOf(address(LP));
        uint256 wBal = IERC20(WETH).balanceOf(address(LP));
        console.log(nBal, "/lp starting nani bal");
        console.log(wBal, "/lp starting weth bal");
        (uint256 price0, string memory strPrice) = ICTC(CTC).checkPriceInETH(NANI);
        (uint256 priceUSDC, string memory strPriceUSDC) = ICTC(CTC).checkPriceInETHToUSDC(NANI);
        console.log(price0, "/starting price in raw ETH");
        console.log(strPrice, "/starting price in ETH");
        console.log(priceUSDC, "/starting price in raw USDC");
        console.log(strPriceUSDC, "/starting price in USDC");

        vm.prank(V);
        nlp.contribute{value: 0.001 ether}(V, minOut);

        (price, strPrice) = ICTC(CTC).checkPriceInETH(NANI);
        (priceUSDC, strPriceUSDC) = ICTC(CTC).checkPriceInETHToUSDC(NANI);
        console.log(price, "/resulting price in raw ETH");
        console.log(strPrice, "/resulting price in ETH");
        console.log(priceUSDC, "/resulting price in raw USDC");
        console.log(strPriceUSDC, "/resulting price in USDC");
        bal = IERC20(NANI).balanceOf(V);
        console.log(bal, "/vb resulting bal");
        console.log(address(nlp).balance, "/dao ETH");
        nBal = IERC20(NANI).balanceOf(address(LP));
        wBal = IERC20(WETH).balanceOf(address(LP));
        console.log(nBal, "/lp resulting nani bal");
        console.log(wBal, "/lp resulting weth bal");
    }
}

interface IERC20 {
    function balanceOf(address) external view returns (uint256);
    function transfer(address, uint256) external returns (bool);
    function approve(address, uint256) external returns (bool);
}

interface ICTC {
    function checkPriceInETH(address) external returns (uint256, string memory);
    function checkPriceInETHToUSDC(address) external returns (uint256, string memory);
}
