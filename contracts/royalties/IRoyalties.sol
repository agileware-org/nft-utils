// SPDX-License-Identifier: MIT

/**
 * ░█▄░█▒█▀░▀█▀░░▒█▀▄░▄▀▄░▀▄▀▒▄▀▄░█▒░░▀█▀░█▒██▀░▄▀▀
 * ░█▒▀█░█▀░▒█▒▒░░█▀▄░▀▄▀░▒█▒░█▀█▒█▄▄░▒█▒░█░█▄▄▒▄██
 * 
 * Made with 🧡 by Kreation.tech
 */
pragma solidity ^0.8.9;

import {IERC2981} from "@openzeppelin/contracts/interfaces/IERC2981.sol";

interface IRoyalties is IERC2981 {
    event RoyaltiesTransferred(address indexed from, address indexed to, address indexed contractAddress);
  
    function initialize(address recipient, uint16 bps, bytes32[] memory data) external;
    function transferTo(address to) external;
    function renounce() external;
}