// SPDX-License-Identifier: MIT

/**
 * ░█▄░█▒█▀░▀█▀░░░█▒█░▀█▀░█░█▒ ░▄▀▀
 * ░█▒▀█░█▀░▒█▒▒░░▀▄█ ▒█▒░█▒█▄▄▒▄██
 * 
 * Made with 🧡 by Kreation.tech
 */
pragma solidity ^0.8.9;

interface ITransferrable {
    event Transferred(address indexed from, address indexed to);
  
    function transferTo(address payable to) external;
}