// SPDX-License-Identifier: MIT

/**
 * ░█▄░█▒█▀░▀█▀░░▒█▀▄░▄▀▄░▀▄▀▒▄▀▄░█▒░░▀█▀░█▒██▀░▄▀▀
 * ░█▒▀█░█▀░▒█▒▒░░█▀▄░▀▄▀░▒█▒░█▀█▒█▄▄░▒█▒░█░█▄▄▒▄██
 * 
 * Made with 🧡 by Kreation.tech
 */
pragma solidity ^0.8.9;

import {IERC2981Upgradeable, IERC165Upgradeable} from "@openzeppelin/contracts-upgradeable/interfaces/IERC2981Upgradeable.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {ITransferAwareRoyalties} from "./ITransferAwareRoyalties.sol";

/**
 * Progressively reducing royalties, starting at a value which gets reduced after each sale.
 */
contract ProgressiveRoyalties is ITransferAwareRoyalties, Initializable {
    address public recipient;
    uint16 public bps;
    uint8 public pct;
    uint16 public abs;
    
    /**
     * @param _recipient Address of the royalties collector
     * @param _bps Royalties percentage in BPS (1/10000)
     * @param _data at 0 the reduction percentage
     *              at 1 the absoolute bps value reduction
     */
    function initialize(address _recipient, uint16 _bps, bytes32[] memory _data) public override initializer {
        require(_bps < 10000, "ERC2981: Too high royalties");
        recipient = _recipient;
        bps = _bps;
        pct = uint8(uint256(_data[0])); // params[0] stores the reduction percentage
        require(pct < 100, "Royalties: not a percentage");
        abs = uint16(uint256(_data[1])); // params[1] stores the absolute bps reduction
        require(abs < 10000, "Royalties: invalid reduction");
    }
    
    function royaltyInfo(uint256, uint256 _value) external view override returns (address receiver, uint256 royaltyAmount) {
        return (recipient, (_value * bps) / 10000);
    }
    
    
    function transferred(address, address, uint256) external override {
        uint24 newBps = bps;
        if (pct > 0) {
            newBps = uint24((newBps * (100 - pct) / 100));
        }
        if (newBps > abs) {
            newBps = newBps - uint16(abs);
        } else {
            newBps = 0;
        }
        bps = uint16(newBps);
    }
    
    function supportsInterface(bytes4 interfaceId) public pure override returns (bool) {
        return type(IERC2981Upgradeable).interfaceId == interfaceId;
    }

    function transferTo(address to) public {
        require(msg.sender == recipient, "Royalties: caller not recipient");
        require(to != address(0x0), "Royalties: invalid address");
        recipient = payable(to);
    }

    function renounce() public {
        require(msg.sender == recipient, "Royalties: caller not recipient");
        recipient = payable(address(0x0));
    }
}