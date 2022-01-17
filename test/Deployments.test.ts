/* eslint-disable no-unused-expressions */
/* eslint-disable node/no-unpublished-import */
/* eslint-disable node/no-missing-import */
/* eslint-disable camelcase */
import "@nomiclabs/hardhat-ethers";
import { ethers } from "hardhat";
import { SplitterFactory, SplitterFactory__factory } from "../src/types";
import types from "../src/splitters.json";

const { expect } = require("chai");

describe("Deployments", function () {
  it("Should deploy SplitterFactory contracts", async function () {
    const PushSplitter = await ethers.getContractFactory("PushSplitter");
    const pushSplitter = await PushSplitter.deploy();

    const ShakeableSplitter = await ethers.getContractFactory("ShakeableSplitter");
    const shakeableSplitter = await ShakeableSplitter.deploy();

    const SplitterFactory = await ethers.getContractFactory("SplitterFactory");
    const factory = await SplitterFactory.deploy();

    const [deployer] = await ethers.getSigners();
    const instance = SplitterFactory__factory.connect(factory.address, deployer) as SplitterFactory;

    instance.addSplitterType(types.push, pushSplitter.address);
    instance.addSplitterType(types.shakeable, shakeableSplitter.address);
  });

  it("Should upgrade DroppableCollection", async function () {
    /*
    const { AuctionFactory } = await deployments.fixture(["auction"]);
    const [deployer] = await ethers.getSigners();
    const factory = (await ethers.getContractAt("AuctionFactory", AuctionFactory.address)) as AuctionFactory;

    const tx = await factory.connect(deployer).create({
      name: "pippo",
      symbol: "PIPPO",
      description: "A nice description"
    }, 1000, "ipfs://someHash", 1500);

    let contractAddress:string;
    for (const e of (await tx.wait()).events!) {
      if (e.event === "CreatedCollection") {
        contractAddress = e.args!.contractAddress;
      }
    }
    const instance = DroppableCollection__factory.connect(contractAddress!, deployer);
    expect(await instance.totalSupply()).to.be.equal(1000);

    await factory.upgrade((await (await ethers.getContractFactory("DroppableCollectionV2")).deploy()).address);
    expect(await instance.totalSupply()).to.be.equal(2000);
    */
  });
});
