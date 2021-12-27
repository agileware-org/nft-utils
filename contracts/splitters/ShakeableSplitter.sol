// SPDX-License-Identifier: MIT

/**
 * ░█▄░█▒█▀░▀█▀░░▒█▀▄▒▄▀▄░▀▄▀░█▄▒▄█▒██▀░█▄░█░▀█▀░░░▄▀▀▒█▀▄░█▒░░█░▀█▀░▀█▀▒██▀▒█▀▄░▄▀▀
 * ░█▒▀█░█▀░▒█▒▒░░█▀▒░█▀█░▒█▒░█▒▀▒█░█▄▄░█▒▀█░▒█▒▒░▒▄██░█▀▒▒█▄▄░█░▒█▒░▒█▒░█▄▄░█▀▄▒▄██
 * 
 * Made with 🧡 by Kreation.tech
 */
pragma solidity ^0.8.9;

import {AddressUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";
import {ContextUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";

import "./ISplitter.sol";

contract ShakeableSplitter is ISplitter, ContextUpgradeable  {

    event PaymentFailed(address to);
    event PaymentReleased(address to, uint256 amount);
    event PaymentReceived(address from, uint256 amount);

    uint256 private _totalReleased;

    mapping(address => uint256) private _released;
    mapping(address => uint16) public shares;
    address[] private _payees;

    constructor() initializer { }

    function initialize(Shares[] memory _shares) public override initializer {
        uint256 totalShares = 0;
        for (uint i = 0; i < _shares.length; i++) {
            _payees.push(_shares[i].payee);
            shares[_shares[i].payee] = _shares[i].bps;
            totalShares += _shares[i].bps;
        }
        require(totalShares == 10_000, "Shares don't sum up to 100%");
    }

    receive() external payable virtual {
        emit PaymentReceived(_msgSender(), msg.value);
    }

    /**
     * @dev Getter for the total amount of Ether already released.
     */
    function totalReleased() public view returns (uint256) {
        return _totalReleased;
    }

    /**
     * @dev Getter for the amount of Ether already released to a payee.
     */
    function released(address account) public view returns (uint256) {
        return _released[account];
    }

    /**
     * @dev Triggers a transfer to `account` of the amount of Ether they are owed, according to their percentage of the
     * total shares and their previous withdrawals.
     */
    function withdraw(address payable account) public virtual {
        _withdraw(account);
    }

    function _withdraw(address payable account) internal virtual {
        require(shares[account] > 0, "Splitter: account has no shares");

        uint256 totalReceived = address(this).balance + totalReleased();
        uint256 payment = _pendingPayment(account, totalReceived, released(account));

        require(payment != 0, "Splitter: account is not due payment");

        _released[account] += payment;
        _totalReleased += payment;

        AddressUpgradeable.sendValue(account, payment);
        emit PaymentReleased(account, payment);
    }

    /**
     * @dev internal logic for computing the pending payment of an `account` given the token historical balances and
     * already released amounts.
     */
    function _pendingPayment(address account, uint256 totalReceived, uint256 alreadyReleased) private view returns (uint256) {
        return (totalReceived * shares[account]) / 10_000 - alreadyReleased;
    }

    function safeShake() external {
        uint256 totalReceived = address(this).balance + _totalReleased;
        for (uint i = 0; i < _payees.length; i++) {
            if(_pendingPayment(_payees[i], totalReceived, _released[_payees[i]]) > 0) {
                try this.withdraw(payable(_payees[i])) {
                    // do nothing
                } catch {
                    emit PaymentFailed(_payees[i]);
                }
            }
        }
    }

    function shake() external {
        uint256 totalReceived = address(this).balance + _totalReleased;
        for (uint i = 0; i < _payees.length; i++) {
            if(_pendingPayment(_payees[i], totalReceived, _released[_payees[i]]) > 0) {
                _withdraw(payable(_payees[i]));
            }
        }
    }

    function withdrawable(address payable account) public view returns(uint256) {
        require(shares[account] > 0, "Splitter: account has no shares");

        uint256 totalReceived = address(this).balance + totalReleased();
        return _pendingPayment(account, totalReceived, released(account));
    }

    function transferTo(address from, address payable to) external {
        require(shares[from] > 0, "Splitter: no shares to transfer");
        shares[to] += shares[from];
        shares[from] = 0;
        _released[to] += _released[from];
        _released[from] += 0;
    }
}