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
        IERC20(NANI).transfer(address(nlp), 900_000 ether);
        require(IERC20(NANI).balanceOf(address(nlp)) == 900_000 ether, "NLP not funded properly");
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

    function testContributeLowAmt() public payable {
        (uint256 price,) = ICTC(CTC).checkPriceInETH(NANI);
        uint256 expectedNANI = (0.0015 ether) / price; // ETH * 1e18 / (ETH/NANI) = NANI
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
        nlp.contribute{value: 0.0015 ether}(V, minOut);

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
    /*
    function testContributeHiAmt() public payable {
        (uint256 price,) = ICTC(CTC).checkPriceInETH(NANI);
        uint256 expectedNANI = (10 ether) / price; // ETH * 1e18 / (ETH/NANI) = NANI
        uint256 minOut = (expectedNANI * 60) / 100; // 60% of expected NANI amount - higher slippage tolerance

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
        nlp.contribute{value: 10 ether}(V, minOut);

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

    function testContributeFullRange() public payable {
        (uint256 price,) = ICTC(CTC).checkPriceInETH(NANI);
        uint256 expectedNANI = (10 ether) / price; // ETH * 1e18 / (ETH/NANI) = NANI
        uint256 minOut = (expectedNANI * 60) / 100; // 60% of expected NANI amount

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
        nlp.contribute{value: 10 ether}(V, minOut);

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

    function testContributeWithInscribe() public payable {
        // Initial state logging:
        uint256 bal = IERC20(NANI).balanceOf(V);
        console.log(bal, "/vb starting bal");
        uint256 nBal = IERC20(NANI).balanceOf(address(LP));
        uint256 wBal = IERC20(WETH).balanceOf(address(LP));
        console.log(nBal, "/lp starting nani bal");
        console.log(wBal, "/lp starting weth bal");

        // Check initial prices:
        (uint256 price, string memory strPrice) = ICTC(CTC).checkPriceInETH(NANI);
        (uint256 priceUSDC, string memory strPriceUSDC) = ICTC(CTC).checkPriceInETHToUSDC(NANI);
        console.log(price, "/starting price in raw ETH");
        console.log(strPrice, "/starting price in ETH");
        console.log(priceUSDC, "/starting price in raw USDC");
        console.log(strPriceUSDC, "/starting price in USDC");

        // Add some random inscriptions:
        address[3] memory inscribers = [address(0x1), address(0x2), address(0x3)];
        for (uint256 i; i != inscribers.length; ++i) {
            uint256 amount = (i + 1) * 1e15; // 0.001, 0.002, 0.003 ether
            vm.deal(inscribers[i], amount);
            vm.prank(inscribers[i]);
            nlp.inscribe{value: amount}();
            console.log("Inscribed", amount, "from", inscribers[i]);
        }

        console.log("Contract balance after inscriptions:", address(nlp).balance);

        // Calculate expected NANI and minOut
        uint256 expectedNANI = (0.015 ether) / price;
        uint256 minOut = (expectedNANI * 95) / 100; // 95% of expected NANI amount

        // Make contribution:
        vm.prank(V);
        nlp.contribute{value: 0.015 ether}(V, minOut);

        // Log final states:
        (price, strPrice) = ICTC(CTC).checkPriceInETH(NANI);
        (priceUSDC, strPriceUSDC) = ICTC(CTC).checkPriceInETHToUSDC(NANI);
        console.log(price, "/resulting price in raw ETH");
        console.log(strPrice, "/resulting price in ETH");
        console.log(priceUSDC, "/resulting price in raw USDC");
        console.log(strPriceUSDC, "/resulting price in USDC");

        bal = IERC20(NANI).balanceOf(V);
        console.log(bal, "/vb resulting bal");
        console.log(address(nlp).balance, "/dao ETH after contribute");
        nBal = IERC20(NANI).balanceOf(address(LP));
        wBal = IERC20(WETH).balanceOf(address(LP));
        console.log(nBal, "/lp resulting nani bal");
        console.log(wBal, "/lp resulting weth bal");
    }

    function testContributeAndCheckPrice() public payable {
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

        // Calculate expected NANI and minOut
        uint256 expectedNANI = (0.015 ether) / price;
        uint256 minOut = (expectedNANI * 95) / 100; // 95% of expected NANI amount

        vm.prank(V);
        nlp.contribute{value: 0.015 ether}(V, minOut);

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

    function testContributeWithTimestamps() public {
        uint256[] memory timestamps = new uint256[](5);
        timestamps[0] = block.timestamp;
        timestamps[1] = block.timestamp + 1 days;
        timestamps[2] = block.timestamp + 1 weeks;
        timestamps[3] = block.timestamp + 4 weeks;
        timestamps[4] = block.timestamp + 365 days;

        uint256 amount = 1 ether; // Fixed amount for consistency

        for (uint256 i = 0; i < timestamps.length; i++) {
            console.log("\n=== Test Case", i + 1, "===");
            console.log("Timestamp:", timestamps[i]);
            console.log("Amount:", amount);

            vm.warp(timestamps[i]);

            uint256 startLPNani = IERC20(NANI).balanceOf(address(LP));
            uint256 startLPWeth = IERC20(WETH).balanceOf(address(LP));
            uint256 startUserNani = IERC20(NANI).balanceOf(V);

            console.log("\nStarting Balances:");
            console.log("LP NANI Balance:", startLPNani);
            console.log("LP WETH Balance:", startLPWeth);
            console.log("User NANI Balance:", startUserNani);

            (uint256 price, string memory startPriceStr) = ICTC(CTC).checkPriceInETH(NANI);
            (, string memory startPriceUSDCStr) = ICTC(CTC).checkPriceInETHToUSDC(NANI);

            // Calculate expected NANI and minOut with higher slippage tolerance due to amount
            uint256 expectedNANI = (amount * 1 ether) / price;
            uint256 minOut = (expectedNANI * 60) / 100; // 60% of expected NANI amount

            console.log("\nStarting Prices:");
            console.log("ETH Price:", startPriceStr);
            console.log("USDC Price:", startPriceUSDCStr);

            vm.prank(V);
            nlp.contribute{value: amount}(V, minOut);

            uint256 endLPNani = IERC20(NANI).balanceOf(address(LP));
            uint256 endLPWeth = IERC20(WETH).balanceOf(address(LP));
            uint256 endUserNani = IERC20(NANI).balanceOf(V);

            console.log("\nEnding Balances:");
            console.log("LP NANI Balance:", endLPNani);
            console.log("LP WETH Balance:", endLPWeth);
            console.log("User NANI Balance:", endUserNani);

            (, string memory endPriceStr) = ICTC(CTC).checkPriceInETH(NANI);
            (, string memory endPriceUSDCStr) = ICTC(CTC).checkPriceInETHToUSDC(NANI);

            console.log("\nEnding Prices:");
            console.log("ETH Price:", endPriceStr);
            console.log("USDC Price:", endPriceUSDCStr);

            bool isLPCreated = endLPNani > startLPNani && endLPWeth > startLPWeth;

            console.log("\nTransaction Result:");
            if (isLPCreated) {
                console.log("Lottery Won - LP Position Created");
                console.log("NANI Added to LP:", endLPNani - startLPNani);
                console.log("WETH Added to LP:", endLPWeth - startLPWeth);
            } else {
                console.log("Direct Swap Performed");
                console.log("NANI Received:", endUserNani - startUserNani);
            }

            // Reset state for next test
            vm.roll(block.number + 1);
        }
    }

    function testContributeAndSellWithTimestamps() public {
        uint256[] memory timestamps = new uint256[](5);
        timestamps[0] = block.timestamp;
        for (uint256 i = 1; i < timestamps.length; i++) {
            timestamps[i] = timestamps[i] + 1 days * _hem(_random(), 1, 365);
        }

        uint256 amount = 1 ether; // Fixed ETH amount for contributions

        for (uint256 i = 0; i < timestamps.length; i++) {
            console.log("\n=== Test Case", i + 1, "===");
            console.log("Timestamp:", timestamps[i]);

            vm.warp(timestamps[i]);

            // First do a contribution
            console.log("\n--- Contributing ETH ---");
            console.log("Amount:", amount);

            uint256 startLPNani = IERC20(NANI).balanceOf(address(LP));
            uint256 startLPWeth = IERC20(WETH).balanceOf(address(LP));
            uint256 startUserNani = IERC20(NANI).balanceOf(V);

            console.log("\nStarting Balances:");
            console.log("LP NANI Balance:", startLPNani);
            console.log("LP WETH Balance:", startLPWeth);
            console.log("User NANI Balance:", startUserNani);

            (uint256 price, string memory startPriceStr) = ICTC(CTC).checkPriceInETH(NANI);
            (, string memory startPriceUSDCStr) = ICTC(CTC).checkPriceInETHToUSDC(NANI);

            // Calculate expected NANI and minOut with higher slippage tolerance
            uint256 expectedNANI = (amount * 1 ether) / price;
            uint256 minOut = (expectedNANI * 60) / 100; // 60% of expected NANI amount

            console.log("\nStarting Prices:");
            console.log("ETH Price:", startPriceStr);
            console.log("USDC Price:", startPriceUSDCStr);

            vm.prank(V);
            nlp.contribute{value: amount}(V, minOut);

            uint256 midLPNani = IERC20(NANI).balanceOf(address(LP));
            uint256 midLPWeth = IERC20(WETH).balanceOf(address(LP));
            uint256 midUserNani = IERC20(NANI).balanceOf(V);

            bool isLPCreated = midLPNani > startLPNani && midLPWeth > startLPWeth;

            console.log("\nContribution Result:");
            if (isLPCreated) {
                console.log("Lottery Won - LP Position Created");
                console.log("NANI Added to LP:", midLPNani - startLPNani);
                console.log("WETH Added to LP:", midLPWeth - startLPWeth);
            } else {
                console.log("Direct Swap Performed");
                console.log("NANI Received:", midUserNani - startUserNani);
            }

            // Then do a sell if user has NANI
            if (midUserNani > 0) {
                console.log("\n--- Selling NANI ---");
                uint256 naniToSell = _hem(_random(), 1, midUserNani / 100);
                console.log("NANI Amount to Sell:", naniToSell);

                vm.startPrank(V);
                IERC20(NANI).approve(address(nans), naniToSell);
                nans.sell(V, naniToSell, 0);
                vm.stopPrank();

                uint256 endLPNani = IERC20(NANI).balanceOf(address(LP));
                uint256 endLPWeth = IERC20(WETH).balanceOf(address(LP));
                uint256 endUserNani = IERC20(NANI).balanceOf(V);

                (, string memory endPriceStr) = ICTC(CTC).checkPriceInETH(NANI);
                (, string memory endPriceUSDCStr) = ICTC(CTC).checkPriceInETHToUSDC(NANI);

                console.log("\nFinal Balances After Sell:");
                console.log("LP NANI Balance:", endLPNani);
                console.log("LP WETH Balance:", endLPWeth);
                console.log("User NANI Balance:", endUserNani);

                console.log("\nFinal Prices:");
                console.log("ETH Price:", endPriceStr);
                console.log("USDC Price:", endPriceUSDCStr);

                console.log("\nSell Impact:");
                console.log("NANI Sold:", naniToSell);
                console.log("LP NANI Change:", endLPNani - midLPNani);
                console.log("LP WETH Change:", midLPWeth - endLPWeth);
            }

            // Reset state for next test
            vm.roll(block.number + 1);
        }
    }

    function testTribute() public {
        vm.deal(address(0x1), 1 ether);
        vm.prank(address(0x1));
        nlp.inscribe{value: 1 ether}();

        uint256 daoBefore = address(DAO).balance;

        // Call tribute with explicit high gas limit
        nlp.tribute{gas: 1000000}();

        assertEq(address(nlp).balance, 0);
        assertEq(address(DAO).balance - daoBefore, 1 ether);
    }

    function testWithdraw() public {
        // Setup: Send some NANI to the contract first:
        uint256 amount = 1000e18;
        vm.prank(address(0x1d8a2e7bf6bc369525A2654aa298)); // NANI whale
        IERC20(NANI).transfer(address(nlp), amount);

        // Record initial balances:
        uint256 contractBefore = IERC20(NANI).balanceOf(address(nlp));
        uint256 daoBefore = IERC20(NANI).balanceOf(DAO);

        // Test withdraw as DAO:
        vm.prank(DAO);
        nlp.withdraw(amount);

        // Verify balances:
        assertEq(IERC20(NANI).balanceOf(address(nlp)), contractBefore - amount);
        assertEq(IERC20(NANI).balanceOf(DAO), daoBefore + amount);
    }

    function testWithdrawRevert() public {
        // Try to withdraw as non-DAO address - should revert:
        vm.expectRevert();
        nlp.withdraw(1000e18);
    }

    function _random() internal returns (uint256 r) {
        assembly ("memory-safe") {
            // This is the keccak256 of some very long string keccak256s we randomly mashed.
            let sSlot := 0x18de83236e9b49e26bc9803c1f0b42bb0da27310a263a87d5bf5935678dbd8ad
            let sValue := sload(sSlot)

            mstore(0x20, sValue)
            r := keccak256(0x20, 0x40)
            r := xor(r, selfbalance()) // sstore4 entropy.

            if iszero(sValue) {
                sValue := sSlot
                let m := mload(0x40)
                calldatacopy(m, 0, calldatasize())
                r := keccak256(m, calldatasize())
            }
            sstore(sSlot, add(r, 1))

            // prettier-ignore
            for {} 1 {} {
                let d := byte(0, r)

                if iszero(d) {
                    r := and(r, 3)
                    break
                }

                if iszero(and(2, d)) {
                    let t := xor(not(0), mul(iszero(and(4, d)), not(xor(sValue, r))))
                    switch and(8, d)
                    case 0 {
                        if iszero(and(16, d)) { t := 1 }
                        r := add(shl(shl(3, and(byte(3, r), 0x1f)), t), sub(and(r, 7), 3))
                    }
                    default {
                        if iszero(and(16, d)) { t := shl(255, 1) }
                        r := add(shr(shl(3, and(byte(3, r), 0x1f)), t), sub(and(r, 7), 3))
                    }
                    if iszero(and(0x20, d)) { r := not(r) }
                    break
                }
                r := xor(sValue, r)
                break
            }
        }
    }

    function _hem(uint256 x, uint256 min, uint256 max) internal pure returns (uint256 result) {
        require(min <= max, "Max is less than min.");

        /// @solidity memory-safe-assembly
        assembly {
            // prettier-ignore
            for {} 1 {} {
                // If `x` is between `min` and `max`, return `x` directly.
                // This is to ensure that dictionary values
                // do not get shifted if the min is nonzero.
                // More info: https://github.com/foundry-rs/forge-std/issues/188
                if iszero(or(lt(x, min), gt(x, max))) {
                    result := x
                    break
                }

                let size := add(sub(max, min), 1)
                if and(iszero(gt(x, 3)), gt(size, x)) {
                    result := add(min, x)
                    break
                }

                let w := not(0)
                if and(iszero(lt(x, sub(0, 4))), gt(size, sub(w, x))) {
                    result := sub(max, sub(w, x))
                    break
                }

                // Otherwise, wrap x into the range [min, max],
                // i.e. the range is inclusive.
                if iszero(lt(x, max)) {
                    let d := sub(x, max)
                    let r := mod(d, size)
                    if iszero(r) {
                        result := max
                        break
                    }
                    result := add(add(min, r), w)
                    break
                }
                let d := sub(min, x)
                let r := mod(d, size)
                if iszero(r) {
                    result := min
                    break
                }
                result := add(sub(max, r), 1)
                break
            }
        }
    }*/
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
