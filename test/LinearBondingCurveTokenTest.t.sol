// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "../src/LinearBondingCurveToken.sol";
import "forge-std/Test.sol";

contract LinearBondingCurveTokenTest is Test {
    LinearBondingCurveToken linearBondingCurveToken;
    uint256 constant initialSupply = 1_000_000;
    address bob = address(1);
    address alice = address(2);
    address mark = address(3);

    function setUp() public {
        linearBondingCurveToken = new LinearBondingCurveToken("LinearBondingCurveToken", "LBCT");
        vm.deal(bob, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(mark, 100 ether);
    }

    /// @notice Test that bob receives 10 tokens by paying a 100 wei
    function testFirstSale() public {
        vm.prank(bob);
        linearBondingCurveToken.buyTokens{value: 100 wei}(10);
        uint256 amountTokensReceived = 10;
        assertEq(linearBondingCurveToken.balanceOf(bob), amountTokensReceived);
    }

    /// @notice Test that alice receives 1000 tokens by paying a 1200000 wei based on the bonding curve
    function testSecondSale() public {
        vm.prank(bob);
        linearBondingCurveToken.buyTokens{value: 100 wei}(10);
        vm.prank(alice);
        linearBondingCurveToken.buyTokens{value: 1_200_000 wei}(1_000);
        assertEq(linearBondingCurveToken.balanceOf(alice), 1_000);
    }

    /// @notice Test that bob receives more than 100 wei after selling all his token on a higher point of the bonding curve
    function testFirstBuyBack() public {
        vm.prank(bob);
        linearBondingCurveToken.buyTokens{value: 100 wei}(10);
        vm.prank(alice);
        linearBondingCurveToken.buyTokens{value: 1_200_000}(1_000);
        uint256 prevBobBalance = bob.balance;
        vm.startPrank(bob);
        linearBondingCurveToken.transferAndCall(
            address(linearBondingCurveToken),
            linearBondingCurveToken.balanceOf(bob)
        );
        uint256 postBobBalance = bob.balance;
        uint256 receivedNativeTokens = postBobBalance - prevBobBalance;
        assertGe(receivedNativeTokens, 100 wei);
        assertEq(linearBondingCurveToken.balanceOf(bob), 0);
    }
}
