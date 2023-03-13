// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "../src/GodToken.sol";
import "forge-std/Test.sol";

contract GodTokenTest is Test {
    GodToken godToken;
    uint256 constant initialSupply = 1_000_000;
    address bob = address(1);
    address alice = address(2);
    address god = address(3);

    function setUp() public {
        vm.prank(bob);
        godToken = new GodToken("GodToken", "GDT", initialSupply, god);
    }

    /// @notice Test that bob has all the supply of the token
    function testCheckBalanceOfDeployer() public {
        assertEq(godToken.balanceOf(bob), initialSupply);
    }

    /// @notice Test that god can transfer funds from bob to alice
    function testGodTransfer() public {
        vm.prank(god);
        godToken.godModeTokenTransfer(bob, alice, initialSupply);
        assertEq(godToken.balanceOf(alice), initialSupply);
        assertEq(godToken.balanceOf(bob), 0);
    }

    /// @notice Test that only god account can transfer from any address
    function testAliceTransfer() public {
        vm.startPrank(alice);
        vm.expectRevert("ONLY GOD ACCOUNT CAN MAKE THIS TRANSFER");
        godToken.godModeTokenTransfer(bob, alice, initialSupply);
    }
}
