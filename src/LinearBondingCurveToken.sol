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
    uint256 tokenPoolAmount;

    constructor(string memory _name, string memory _symbol) ERC20(_name, _symbol) {}

    /**
     * @notice Allows users to buy LBC tokens by sending native tokens to the contract
     * @dev Calculates the required amount of LBC tokens to mint based on the current token pool and native token received, and mints them to the sender.
     */
    function buyTokens() external payable nonReentrant {
        uint256 tokensBought = getRequiredAmount(msg.value);
        _mint(msg.sender, tokensBought);
        tokenPoolAmount += tokensBought;
    }

    /**
     * @inheritdoc IERC1363Receiver
     * @dev Calculates the amount of native tokens to be sent to the sender based on the amount of tokens received by the contract, and burns them.
     * @param spender The address of the contract which initiated the transfer.
     * @param sender The address which initiated the transfer.
     * @param amount The amount of tokens being transferred.
     * @param data Additional data passed to the function.
     * @return `bytes4(keccak256("onTransferReceived(address,address,uint256,bytes)"))`
     */
    function onTransferReceived(
        address spender,
        address sender,
        uint256 amount,
        bytes calldata data
    ) external nonReentrant returns (bytes4) {
        uint256 tokensSold = address(this).balance - tokenPoolAmount;
        uint256 amountToReceive = getReceivingAmount(tokensSold);
        _burn(address(this), tokensSold);
        tokenPoolAmount -= tokensSold;
        payable(spender).call{value: amountToReceive}("0x00");
    }

    /**
     * @notice Calculates the required amount of tokens to be minted based on the native received
     * @param amountToBuy The amount of native tokens received
     * @return The amount of tokens to be received
     */
    function getRequiredAmount(uint256 amountToBuy) public view returns (uint256) {
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
    function getReceivingAmount(uint256 amountToSell) public view returns (uint256) {
        uint256 initialSupply = tokenPoolAmount;
        uint256 initialPoolBalance = initialSupply ** LINEAR_BONDING_CURVE;
        uint256 finalPoolBalance = (initialSupply - amountToSell) ** LINEAR_BONDING_CURVE;
        uint256 receivingAmount = initialPoolBalance - finalPoolBalance;
        return receivingAmount;
    }
}
