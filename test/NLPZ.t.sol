// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.19;

import {NLPZ} from "../src/NLPZ.sol";
import {Test} from "../lib/forge-std/src/Test.sol";
import {console} from "forge-std/console.sol";

contract NLPTest is Test {
    NLPZ internal nlp;

    address constant NANI = 0x00000000000007C8612bA63Df8DdEfD9E6077c97;
    address constant WETH = 0x4200000000000000000000000000000000000006;
    address constant DAO = 0xDa000000000000d2885F108500803dfBAaB2f2aA;
    address constant LP = 0xB1CcEa7c214F8848B5Ae7F86218E25563f557bB3;

    address constant USER = 0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045;

    function setUp() public payable {
        vm.createSelectFork(vm.rpcUrl("base"));

        nlp = new NLPZ();

        // Assume DAO funds the contract with NANI initially; simplify for test
        vm.prank(DAO);
        IERC20(NANI).transfer(address(nlp), 3_000_000 ether);
        require(IERC20(NANI).balanceOf(address(nlp)) == 3_000_000 ether, "NLP not funded properly");
    }

    function testContributeLowAmt() public payable {
        console.log("Test: Contribute Low Amount");

        // Log initial balances
        uint256 initialContractETHBalance = address(nlp).balance;
        uint256 initialContractWETHBalance = IERC20(WETH).balanceOf(address(nlp));
        uint256 initialNaniBalance = IERC20(NANI).balanceOf(address(LP));
        uint256 initialWethBalance = IERC20(WETH).balanceOf(address(LP));

        console.log(initialContractETHBalance, "/contract initial ETH balance");
        console.log(initialContractWETHBalance, "/contract initial WETH balance");
        console.log(initialNaniBalance, "/lp initial Nani balance");
        console.log(initialWethBalance, "/lp initial Weth balance");

        uint256 contribution = 0.015 ether;
        vm.prank(USER);
        nlp.contribute{value: contribution}(USER);

        // Log final balances
        uint256 finalContractETHBalance = address(nlp).balance;
        uint256 finalContractWETHBalance = IERC20(WETH).balanceOf(address(nlp));
        uint256 finalNaniBalance = IERC20(NANI).balanceOf(address(LP));
        uint256 finalWethBalance = IERC20(WETH).balanceOf(address(LP));

        console.log(finalContractETHBalance, "/contract final ETH balance");
        console.log(finalContractWETHBalance, "/contract final WETH balance");
        console.log(finalNaniBalance, "/lp final Nani balance");
        console.log(finalWethBalance, "/lp final Weth balance");

        // Verify LP has increased
        assertGt(finalNaniBalance, initialNaniBalance);
        assertGt(finalWethBalance, initialWethBalance);
    }

    function testContributeHiAmt() public payable {
        console.log("Test: Contribute High Amount");

        // Log initial balances
        uint256 initialContractETHBalance = address(nlp).balance;
        uint256 initialContractWETHBalance = IERC20(WETH).balanceOf(address(nlp));
        uint256 initialNaniBalance = IERC20(NANI).balanceOf(address(LP));
        uint256 initialWethBalance = IERC20(WETH).balanceOf(address(LP));

        console.log(initialContractETHBalance, "/contract initial ETH balance");
        console.log(initialContractWETHBalance, "/contract initial WETH balance");
        console.log(initialNaniBalance, "/lp initial Nani balance");
        console.log(initialWethBalance, "/lp initial Weth balance");

        uint256 contribution = 10 ether;
        vm.prank(USER);
        nlp.contribute{value: contribution}(USER);

        // Log final balances
        uint256 finalContractETHBalance = address(nlp).balance;
        uint256 finalContractWETHBalance = IERC20(WETH).balanceOf(address(nlp));
        uint256 finalNaniBalance = IERC20(NANI).balanceOf(address(LP));
        uint256 finalWethBalance = IERC20(WETH).balanceOf(address(LP));

        console.log(finalContractETHBalance, "/contract final ETH balance");
        console.log(finalContractWETHBalance, "/contract final WETH balance");
        console.log(finalNaniBalance, "/lp final Nani balance");
        console.log(finalWethBalance, "/lp final Weth balance");

        // Verify LP has increased
        assertGt(finalNaniBalance, initialNaniBalance);
        assertGt(finalWethBalance, initialWethBalance);
    }

    function testContributeFullRange() public payable {
        console.log("Test: Contribute Full Range");

        // Log initial balances
        uint256 initialContractETHBalance = address(nlp).balance;
        uint256 initialContractWETHBalance = IERC20(WETH).balanceOf(address(nlp));
        uint256 initialNaniBalance = IERC20(NANI).balanceOf(address(LP));
        uint256 initialWethBalance = IERC20(WETH).balanceOf(address(LP));

        console.log(initialContractETHBalance, "/contract initial ETH balance");
        console.log(initialContractWETHBalance, "/contract initial WETH balance");
        console.log(initialNaniBalance, "/lp initial Nani balance");
        console.log(initialWethBalance, "/lp initial Weth balance");

        uint256 contribution = 10 ether;
        vm.prank(USER);
        nlp.contributeFullRange{value: contribution}(USER);

        // Log final balances
        uint256 finalContractETHBalance = address(nlp).balance;
        uint256 finalContractWETHBalance = IERC20(WETH).balanceOf(address(nlp));
        uint256 finalNaniBalance = IERC20(NANI).balanceOf(address(LP));
        uint256 finalWethBalance = IERC20(WETH).balanceOf(address(LP));

        console.log(finalContractETHBalance, "/contract final ETH balance");
        console.log(finalContractWETHBalance, "/contract final WETH balance");
        console.log(finalNaniBalance, "/lp final Nani balance");
        console.log(finalWethBalance, "/lp final Weth balance");

        // Verify LP has increased
        assertGt(finalNaniBalance, initialNaniBalance);
        assertGt(finalWethBalance, initialWethBalance);
    }

    function testWithdraw() public {
        // Assume some NANI was sent to the contract
        uint256 amount = 1000 ether;
        vm.prank(DAO);
        IERC20(NANI).transfer(address(nlp), amount);

        // Check before balances
        uint256 contractBalanceBefore = IERC20(NANI).balanceOf(address(nlp));
        uint256 daoBalanceBefore = IERC20(NANI).balanceOf(DAO);

        // Test withdraw, assuming DAO can initiate
        vm.prank(DAO);
        nlp.withdraw(amount);

        // Verify balances post-withdrawal
        assertEq(IERC20(NANI).balanceOf(address(nlp)), contractBalanceBefore - amount);
        assertEq(IERC20(NANI).balanceOf(DAO), daoBalanceBefore + amount);
    }

    function testWithdrawRevert() public {
        // Attempt withdraw from non-DAO address should revert
        vm.expectRevert();
        vm.prank(USER);
        nlp.withdraw(1000 ether);
    }
}

interface IERC20 {
    function balanceOf(address) external view returns (uint256);
    function transfer(address, uint256) external returns (bool);
    function approve(address, uint256) external returns (bool);
}
