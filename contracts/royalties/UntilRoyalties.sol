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
import {IRoyalties} from "./IRoyalties.sol";

/**
 * Time limited royalties, pay a fixed percentage until specified block timestamp is reached.
 */
contract UntilRoyalties is IRoyalties, Initializable {
    address public recipient;
    uint16 public bps;
    uint64 public timestamp;
    
    /**
     * @param _recipient Address of the royalties collector
     * @param _bps Royalties percentage in BPS (1/10000)
     * @param _data at 0 the timestamp after which no royalties are paid
     */
    function initialize(address _recipient, uint16 _bps, bytes32[] memory _data) public override initializer {
        require(_bps < 10000, "ERC2981: Too high royalties");
        recipient = _recipient;
        bps = _bps;
        timestamp = uint64(uint256(_data[0])); // params[0] stores the timestamp of royalties payout ending
        require(timestamp > block.timestamp, "Expires in the past");
    }
    
    function royaltyInfo(uint256, uint256 _value) external view override returns (address receiver, uint256 royaltyAmount) {
        if (block.timestamp < timestamp) {
            return (recipient, (_value * bps) / 10000);
        }
        return (address(0x0), 0);
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