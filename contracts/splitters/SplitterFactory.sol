// SPDX-License-Identifier: MIT

/**
 * ░█▄░█▒█▀░▀█▀░░▒█▀▄▒▄▀▄░▀▄▀░█▄▒▄█▒██▀░█▄░█░▀█▀░░░▄▀▀▒█▀▄░█▒░░█░▀█▀░▀█▀▒██▀▒█▀▄░▄▀▀
 * ░█▒▀█░█▀░▒█▒▒░░█▀▒░█▀█░▒█▒░█▒▀▒█░█▄▄░█▒▀█░▒█▒▒░▒▄██░█▀▒▒█▄▄░█░▒█▒░▒█▒░█▄▄░█▀▄▒▄██
 * 
 * Made with 🧡 by Kreation.tech
 */
pragma solidity ^0.8.9;

import {Clones} from "@openzeppelin/contracts/proxy/Clones.sol";
import {Counters} from "@openzeppelin/contracts/utils/Counters.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Address} from "@openzeppelin/contracts/utils/Address.sol";

import "./ISplitter.sol";
import "./PushSplitter.sol";
import "./ShakeableSplitter.sol";

contract SplitterFactory is Ownable {
    using Counters for Counters.Counter;

    // Counter for current contract id
    Counters.Counter internal _counter;

    // Addresses of implementations of ISplitter contracts to clone
    mapping(bytes32 => address) private _implementations;

    constructor() {}

    /**
     * Initializes the factory with the address of the implementation contract template
     * 
     * @param splitterType type of splitter
     * @param implementation ISplitter implementation contract to clone
     */
    function addSplitterType(bytes32 splitterType, address implementation) external onlyOwner {
        require(Address.isContract(implementation), "Not a contract");
        require(_implementations[splitterType] == address(0x0), "Splitter type already defined");
        _implementations[splitterType] = implementation;
        emit AddedSplitterType(splitterType, msg.sender, implementation);
    }

    /**
     * Creates a new splitter contract as a factory with a deterministic address, returning the address of the newly created splitter contract.
     * Returns the id of the created splitter contract.
     * 
     * @param splitterType type of splitter
     * @param shares list of tuples representing the payees and their shares in bps
     */
    function create(bytes32 splitterType, ISplitter.Shares[] memory shares) external returns (address payable) {
        uint256 id = _counter.current();
        address payable instance = payable(Clones.cloneDeterministic(_implementations[splitterType], bytes32(abi.encodePacked(id))));
        ISplitter(instance).initialize(shares);
        emit CreatedSplitter(id, splitterType, msg.sender, instance, shares);
        _counter.increment();
        return instance;
    }

    /**
     * Gets a splitter given the unique identifier
     * 
     * @param splitterType type of splitter
     * @param index id of splitter to get contract for
     * @return the Splitter payment contract
     */
    function get(bytes32 splitterType, uint256 index) external view returns (ISplitter) {
        return ISplitter(payable(Clones.predictDeterministicAddress(_implementations[splitterType], bytes32(abi.encodePacked(index)), address(this))));
    }

    /**
     * @return the number of splitter instances released so far
     */
    function instances() external view returns (uint256) {
        return _counter.current();
    }

    /**
     * Emitted when a splitter is created.
     * 
     * @param index the identifier of newly created edition
     * @param splitterType the type of splitter
     * @param creator the edition's owner
     * @param contractAddress the address of the splitting contract
     * @param shares the shares splitting rules
     */
    event CreatedSplitter(uint256 indexed index, bytes32 indexed splitterType, address indexed creator, address contractAddress, ISplitter.Shares[] shares);

    /**
     * Emitted when a splitter type is added.
     * 
     * @param splitterType the type of splitter
     * @param creator address adding the splitter template
     * @param contractAddress the address of the splitting contract template
     */
     event AddedSplitterType(bytes32 indexed splitterType, address indexed creator, address contractAddress);
}
