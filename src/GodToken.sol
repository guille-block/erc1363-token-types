// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "erc1363-payable-token/contracts/token/ERC1363/ERC1363.sol";

/**
 * @title GodToken
 * @dev Implementation of the GodToken contract, based on ERC1363.
 */
contract GodToken is ERC1363 {
    address private immutable godAccount;

    /**
     * @dev Modifier that only allows the God Account to call the function.
     */
    modifier onlyGodAccount() {
        require(godAccount == msg.sender, "ONLY GOD ACCOUNT CAN MAKE THIS TRANSFER");
        _;
    }

    /**
     * @dev Constructor for GodToken contract.
     * @param name The name of the token.
     * @param symbol The symbol of the token.
     * @param _godAccount The address of the God Account.
     */
    constructor(string memory name, string memory symbol, uint amountToMint, address _godAccount) ERC20(name, symbol) {
        godAccount = _godAccount;
        _mint(msg.sender, amountToMint);
    }

    /**
     * @dev Function to transfer tokens in God Mode.
     * @param from The address from which to transfer tokens.
     * @param to The address to which to transfer tokens.
     * @param amount The amount of tokens to transfer.
     */
    function godModeTokenTransfer(address from, address to, uint256 amount) external onlyGodAccount {
        _transfer(from, to, amount);
    }
}
