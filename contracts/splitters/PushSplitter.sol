// SPDX-License-Identifier: MIT

/**
 * ░█▄░█▒█▀░▀█▀░░▒█▀▄▒▄▀▄░▀▄▀░█▄▒▄█▒██▀░█▄░█░▀█▀░░░▄▀▀▒█▀▄░█▒░░█░▀█▀░▀█▀▒██▀▒█▀▄░▄▀▀
 * ░█▒▀█░█▀░▒█▒▒░░█▀▒░█▀█░▒█▒░█▒▀▒█░█▄▄░█▒▀█░▒█▒▒░▒▄██░█▀▒▒█▄▄░█░▒█▒░▒█▒░█▄▄░█▀▄▒▄██
 * 
 * Made with 🧡 by Kreation.tech
 */
pragma solidity ^0.8.9;


import {Initializable} from "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import {AddressUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";
import {ContextUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";

import "./ISplitter.sol";

contract PushSplitter is Initializable, ISplitter {
    
    address[] internal _payees;
    mapping(address => uint16) internal _shares;
    
    constructor() initializer { }
    
    function initialize(Shares[] memory shares) public override initializer {
        require(shares.length > 0, "Splitter: no payees");
        uint256 totalShares = 0;
        for (uint i = 0; i < shares.length; i++) {
            _addPayee(shares[i].payee, shares[i].bps);
            totalShares += shares[i].bps;
        }
        require(totalShares == 10_000, "Shares don't sum up to 10000 pbs");
    }

    /**
     * Adds a new payee to the contract.
     * 
     * @param account the address of the payee to add.
     * @param shares the number of shares owned by the payee.
     */
    function _addPayee(address account, uint256 shares) internal {
        require(account != address(0x0), "Splitter: account is 0x0 address");
        require(shares > 0 && shares < 10_000, "Splitter: invalid shares");
        require(_shares[account] == 0, "Splitter: account duplicated");

        _payees.push(account);
        _shares[account] = uint16(shares);
    }

    receive() external payable virtual {
        uint256 value = address(this).balance;
        for (uint i = 0; i < _payees.length; i++) {
            uint256 amount = value * _shares[_payees[i]] / 10_000;
            AddressUpgradeable.sendValue(payable(_payees[i]), amount);
        }
    }

    function transferTo(address from, address payable to, uint16 amount) external {
        require(_shares[from] > 0, "Splitter: no shares to transfer");
        require(amount == 0 || _shares[from] >= amount, "Splitter: exceeding transfer");
        uint16 transfer = _shares[from];
        if (amount > 0 && amount < transfer) {
            transfer = amount;
        }
        _shares[to] += transfer;
        _shares[from] -= transfer;
    }
}
