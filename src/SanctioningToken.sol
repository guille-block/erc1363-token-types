// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "erc1363-payable-token/contracts/token/ERC1363/ERC1363.sol";

/**
 * @title SanctioningToken
 * @dev Extends ERC1363 token contract and adds functionality to restrict sending and receiving from sanctioned addresses.
 */
contract SanctioningToken is ERC1363 {
    mapping(address => bool) private sanctionedSendAddresses;
    mapping(address => bool) private sanctionedRecieveAddresses;

    address immutable admin;

    /**
     * @dev Throws if the caller is not the contract's admin.
     */
    modifier onlyAdmin() {
        require(msg.sender == admin, "ONLY ADMIN CAN UPDATE");
        _;
    }

    constructor(string memory name, string memory symbol, address _admin) ERC20(name, symbol) {
        admin = _admin;
    }

    /**
     * @dev Updates the sanctioned send address mapping.
     * @param sanctioned The address to update.
     * @param state The new state of the address.
     */
    function updateSanctionedSendingAddress(address sanctioned, bool state) external onlyAdmin {
        sanctionedSendAddresses[sanctioned] = state;
    }

    /**
     * @dev Updates the sanctioned receive address mapping.
     * @param sanctioned The address to update.
     * @param state The new state of the address.
     */
    function updateSanctionedReceiveAddress(address sanctioned, bool state) external onlyAdmin {
        sanctionedRecieveAddresses[sanctioned] = state;
    }

    /**
     * @dev Overrides the _beforeTokenTransfer function to include sanctions checks.
     * @param from The address sending the tokens.
     * @param to The address receiving the tokens.
     * @param amount The amount of tokens being transferred.
     */
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal override {
        require(sanctionedSendAddresses[from], "SANCTIONED ADDRESS: CANT SEND FUNDS");
        require(sanctionedRecieveAddresses[to], "SANCTIONED ADDRESS: CANT RECEIVE FUNDS");
    }
}
