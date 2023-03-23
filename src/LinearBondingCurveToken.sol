// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "erc1363-payable-token/contracts/token/ERC1363/ERC1363.sol";
import "erc1363-payable-token/contracts/token/ERC1363/IERC1363Receiver.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

/// @title LBC Token
/// @author Guillermo Fairbairn
/// @notice ERC1363 Token with bonding curve mechanism
/// @dev The token follows a f(x) = 2x curve for simplicity
contract LinearBondingCurveToken is ERC1363, ReentrancyGuard, IERC1363Receiver {
    uint256 constant LINEAR_BONDING_CURVE = 2;
    uint256 public tokenPoolAmount;

    constructor(string memory _name, string memory _symbol) ERC20(_name, _symbol) {}

    /**
     * @notice Allows users to buy LBC tokens by sending native tokens to the contract
     * @dev Calculates the required amount of LBC tokens to mint based on the current token pool and native token received, and mints them to the sender.
     */
    function buyTokens(uint amountToBuy) external payable {
        uint256 valueRequired = getRequiredNativeTokenAmount(amountToBuy);
        require(msg.value >= valueRequired, "NOT ENOUGH VALUE FOR THIS PURCHASE");
        tokenPoolAmount += amountToBuy;
        if (msg.value > valueRequired) {
            msg.sender.call{value: msg.value - valueRequired}("");
        }
        _mint(msg.sender, amountToBuy);
    }

    /**
     * @inheritdoc IERC1363Receiver
     * @dev Calculates the amount of native tokens to be sent to the sender based on the amount of tokens received by the contract, and burns them.
     * @param sender The address which initiated the transfer.
     * @param amount The amount of tokens being transferred.
     * @param data Additional data passed to the function.
     * @return `bytes4(keccak256("onTransferReceived(address,address,uint256,bytes)"))`
     */
    function onTransferReceived(
        address,
        address sender,
        uint256 amount,
        bytes calldata data
    ) external nonReentrant returns (bytes4) {
        uint256 amountToReceive = getReceivingNativeTokenAmount(amount);
        _burn(address(this), amount);
        tokenPoolAmount -= amount;
        payable(sender).call{value: amountToReceive}("0x00");
        return IERC1363Receiver.onTransferReceived.selector;
    }

    /**
     * @notice Calculates the required amount of tokens to be minted based on the native received
     * @param amountToBuy The amount of native tokens received
     * @return The amount of tokens to be received
     */
    function getRequiredNativeTokenAmount(uint256 amountToBuy) public view returns (uint256) {
        uint256 initialSupply = totalSupply();
        uint256 initialPoolBalance = initialSupply ** LINEAR_BONDING_CURVE;
        uint256 finalPoolBalance = (initialSupply + amountToBuy) ** LINEAR_BONDING_CURVE;
        uint256 requiredAmount = finalPoolBalance - initialPoolBalance;
        return requiredAmount;
    }

    /**
     * @notice Calculates the amount of native token to be received for a given amount of tokens
     * @param amountToSell The amount of tokens to be sold
     * @return The amount of native tokens to be received
     */
    function getReceivingNativeTokenAmount(uint256 amountToSell) public view returns (uint256) {
        uint256 initialSupply = tokenPoolAmount;
        uint256 initialPoolBalance = initialSupply ** LINEAR_BONDING_CURVE;
        uint256 finalPoolBalance = (initialSupply - amountToSell) ** LINEAR_BONDING_CURVE;
        uint256 receivingAmount = initialPoolBalance - finalPoolBalance;
        return receivingAmount;
    }
}
