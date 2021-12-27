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
 * Perpetual royalties, pay a fixed percentage indefinitely.
 */
contract PerpetualRoyalties is IRoyalties, Initializable {
    address public recipient;
    uint16 public bps;
    
    /**
     * @param _recipient Address of the royalties collector
     * @param _bps Royalties percentage in BPS (1/10000)
     */
    function initialize(address _recipient, uint16 _bps, bytes32[] memory) public override initializer {
        require(_bps < 10000, "ERC2981: Too high royalties");
        recipient = _recipient;
        bps = _bps;
    }
    
    function royaltyInfo(uint256, uint256 _value) external view override returns (address receiver, uint256 royaltyAmount) {
        return (recipient, (_value * bps) / 10000);
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