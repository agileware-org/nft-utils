// SPDX-License-Identifier: MIT

/**
 * ░█▄░█▒█▀░▀█▀░░▒█▀▄▒▄▀▄░▀▄▀░█▄▒▄█▒██▀░█▄░█░▀█▀░░░▄▀▀▒█▀▄░█▒░░█░▀█▀░▀█▀▒██▀▒█▀▄░▄▀▀
 * ░█▒▀█░█▀░▒█▒▒░░█▀▒░█▀█░▒█▒░█▒▀▒█░█▄▄░█▒▀█░▒█▒▒░▒▄██░█▀▒▒█▄▄░█░▒█▒░▒█▒░█▄▄░█▀▄▒▄██
 * 
 * Made with 🧡 by Kreation.tech
 */
pragma solidity ^0.8.6;

interface ISplitter {
    struct Shares {
        address payable payee;
        uint16 bps;
    }
    
    function initialize(Shares[] memory shares) external;

}