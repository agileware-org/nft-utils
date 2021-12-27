    // SPDX-License-Identifier: MIT

/**
 * ░█▄░█▒█▀░▀█▀░░▒█▀▄░▄▀▄░▀▄▀▒▄▀▄░█▒░░▀█▀░█▒██▀░▄▀▀
 * ░█▒▀█░█▀░▒█▒▒░░█▀▄░▀▄▀░▒█▒░█▀█▒█▄▄░▒█▒░█░█▄▄▒▄██
 * 
 * Made with 🧡 by Kreation.tech
 */

pragma solidity ^0.8.9;

import {ClonesUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/ClonesUpgradeable.sol";
import {CountersUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {AddressUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

import "./IRoyalties.sol";

contract RoyaltiesFactory is OwnableUpgradeable {
    using CountersUpgradeable for CountersUpgradeable.Counter;
    
    // Counter for last royalties contract id released
    CountersUpgradeable.Counter private _counter;

    // Addresses of implementations of ISplitter contracts to clone
    mapping(bytes32 => address) private _implementations;
    
    constructor() {
        __Ownable_init();
        transferOwnership(msg.sender);
    }

    /**
     * Initializes the factory with the address of the implementation contract template
     * 
     * @param royaltiesType type of royalties
     * @param implementation IRoyalties implementation contract to clone
     */
    function addRoyaltiesType(bytes32 royaltiesType, address implementation) external onlyOwner {
        require(AddressUpgradeable.isContract(implementation), "Mot a contract");
        require(_implementations[royaltiesType] == address(0x0), "Splitter type already defined");
        _implementations[royaltiesType] = implementation;
        emit AddedRoyaltiesType(royaltiesType, msg.sender, implementation);
    }
    
    function create(bytes32 royaltiesType, address recipient, uint16 bps, bytes32[] memory data) public returns (address) {
        require(_implementations[royaltiesType] != address(0x0), "Invalid royaltiesType");
        require(recipient != address(0x0), "Invalid recipient");
        uint256 id = _counter.current();
        address implementation = ClonesUpgradeable.cloneDeterministic(_implementations[royaltiesType], bytes32(abi.encodePacked(id)));
        
        IRoyalties(implementation).initialize(recipient, bps, data);
        emit CreatedRoyalties(id, royaltiesType, msg.sender, implementation);
        _counter.increment();
        return implementation;
    }

    /**
     * Gets an edition given the created ID
     * 
     * @param royaltiesType the type identifier of the royalties to retrieve
     * @param index the id of the royalties to retrieve
     * @return IRoyalties implementation
     */
    function get(bytes32 royaltiesType, uint256 index) external view returns (IRoyalties) {
        return IRoyalties(
            ClonesUpgradeable.predictDeterministicAddress(
                _implementations[royaltiesType], bytes32(abi.encodePacked(index)), address(this)));
    }
    
    /**
     * Emitted when a royalties is created reserving the corresponding id.
     * 
     * @param id the identifier of the newly created royalties
     * @param typeId the identifier of the newly created royalties type
     * @param creator the address creating the royalties contract
     * @param contractAddress the address of the newly created royalties contract
     */
    event CreatedRoyalties(uint256 indexed id, bytes32 indexed typeId, address indexed creator, address contractAddress);

    /**
     * Emitted when a royalties type is added.
     * 
     * @param royaltiesType the identifier of the newly created royalties
     * @param creator the address adding the royalties template
     * @param contractAddress the address of the added template contract
     */
    event AddedRoyaltiesType(bytes32 indexed royaltiesType, address indexed creator, address contractAddress);

}