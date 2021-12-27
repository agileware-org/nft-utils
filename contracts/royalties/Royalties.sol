// SPDX-License-Identifier: MIT

/**
 * ░█▄░█▒█▀░▀█▀░░▒█▀▄░▄▀▄░▀▄▀▒▄▀▄░█▒░░▀█▀░█▒██▀░▄▀▀
 * ░█▒▀█░█▀░▒█▒▒░░█▀▄░▀▄▀░▒█▒░█▀█▒█▄▄░▒█▒░█░█▄▄▒▄██
 * 
 * Made with 🧡 by Kreation.tech
 */
pragma solidity ^0.8.9;

import {IERC2981} from "@openzeppelin/contracts/interfaces/IERC2981.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {AddressUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";
import {ContextUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
import {StringsUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/StringsUpgradeable.sol";
import {IRoyalties} from "./IRoyalties.sol";

abstract contract Royalties is IRoyalties, Initializable {
    using AddressUpgradeable for address;
    using StringsUpgradeable for uint256;
    address payable internal _recipient;
    uint16 internal _bps;

    /**
     * @dev Initializes the contract by setting a `name` and a `symbol` to the token collection.
     */
    function __Royalties_init(address payable recipient_, uint16 bps_) internal onlyInitializing {
        __Royalties_init_unchained(recipient_, bps_);
    }

    function __Royalties_init_unchained(address payable recipient_, uint16 bps_) internal onlyInitializing {
        _recipient = recipient_;
        _bps = bps_;
    }

    /**
     * @notice requires the value is valid bps representation
     */
    modifier validBPS(uint256 bps) {
        require(bps < 10000, "ERC2981: Too high royalties");
        _;
    }

    /**
     * @notice requires the caller being the current recipient
     */
    modifier onlyRecipient() {
        require(msg.sender == _recipient, "Royalties: caller not recipient");
        _;
    }

    function transferTo(address to) public onlyRecipient {
        require(to != address(0x0), "Royalties: invalid address");
        _recipient = payable(to);
    }

    function renounce() public onlyRecipient {
        _recipient = payable(address(0x0));
    }
}