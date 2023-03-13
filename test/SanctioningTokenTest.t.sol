// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "../src/SanctioningToken.sol";
import "forge-std/Test.sol";

contract SanctioningTokenTest is Test {
    SanctioningToken sanctioningToken;
    uint256 constant initialSupply = 1_000_000;
    address admin = address(1);
    address bob = address(2);
    address alice = address(3);

    function setUp() public {
        vm.prank(bob);
        sanctioningToken = new SanctioningToken("SanctioningToken", "SCT", initialSupply, admin);
    }

    /// @notice Test sanctioning bob from sending tokens
    function testSanctionBobTransferOutTokens() public {
        vm.prank(admin);
        sanctioningToken.updateSanctionedSendingAddress(bob, true);
        vm.startPrank(bob);
        vm.expectRevert("SANCTIONED ADDRESS: CANT SEND FUNDS");
        sanctioningToken.transfer(alice, initialSupply);
    }

    /// @notice Test sanctioning Alice from receiving tokens
    function testSanctionAliceReceiveTokens() public {
        vm.prank(admin);
        sanctioningToken.updateSanctionedReceiveAddress(alice, true);
        vm.startPrank(bob);
        vm.expectRevert("SANCTIONED ADDRESS: CANT RECEIVE FUNDS");
        sanctioningToken.transfer(alice, initialSupply);
    }

    /// @notice Test that if no sanctions involved in the transfer, the transfer happens correctly
    function testNormalTransferWithNoSanctions() public {
        vm.startPrank(bob);
        sanctioningToken.transfer(alice, initialSupply);
        assertEq(sanctioningToken.balanceOf(alice), initialSupply);
    }
}
