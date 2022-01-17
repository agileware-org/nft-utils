/* eslint-disable camelcase */
/* eslint-disable node/no-missing-import */
/* eslint-disable node/no-extraneous-import */
import "@nomiclabs/hardhat-ethers";

import { PushSplitter, ShakeableSplitter, SplitterFactory, SplitterFactory__factory } from "../src/types";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { solidity } from "ethereum-waffle";
import chai from "chai";
import types from "../src/splitters.json";
chai.use(solidity);
const { expect } = require("chai");
const { ethers, deployments } = require("hardhat");

describe("The SplitterFactory", () => {
	let factory: SplitterFactory;
	let factoryAddress: string;
	let deployer: SignerWithAddress;
	let someone: SignerWithAddress;
	let shareholder1: SignerWithAddress;
	let shareholder2: SignerWithAddress;
	let shareholder3: SignerWithAddress;
	let sender: SignerWithAddress;

	before(async () => {
		[deployer, someone, shareholder1, shareholder2, shareholder3, sender] = await ethers.getSigners(); // test wallets
    factoryAddress = (await deployments.get("SplitterFactory")).address; // factory address as deployed by --deploy-fixture
		factory = SplitterFactory__factory.connect(factoryAddress, deployer);
    await factory.addSplitterType(types.push, (await deployments.get("PushSplitter")).address);
    await factory.addSplitterType(types.shakeable, (await deployments.get("ShakeableSplitter")).address);
		// await factory.grantRole(await factory.ARTIST_ROLE(), artist.address);
	});

  it("Should emit a CreatedSplitter event upon create", async function () {
    expect(await factory.instances()).to.be.equal(0);
    const expectedAddress = await factory.get(types.push, 0);
    await expect(factory.connect(someone)
      .create(types.push, [{ payee: shareholder1.address, bps: 2500 }, { payee: shareholder2.address, bps: 2500 }, { payee: shareholder3.address, bps: 5000 }]))
      .to.emit(factory, "CreatedSplitter");

    expect(await factory.instances()).to.be.equal(1);
    expect(await factory.get(types.push, 0)).to.be.equal(expectedAddress);
  });

  it("Should be able to distinguish types", async function () {
    expect(await factory.get(types.shakeable, 1)).not.to.be.equal(await factory.get(types.push, 1));
  });

  it("Should be able to create multiple types", async function () {
    expect(await factory.instances()).to.be.equal(1);
    const shakeAddress = await factory.get(types.shakeable, 1);
    const pushAddress = await factory.get(types.push, 2);
    expect(await factory.get(types.shakeable, 2)).not.to.be.equal(pushAddress);

    await expect(factory.connect(someone)
      .create(types.shakeable, [{ payee: shareholder1.address, bps: 2500 }, { payee: shareholder2.address, bps: 2500 }, { payee: shareholder3.address, bps: 5000 }]))
      .to.emit(factory, "CreatedSplitter");
    await expect(factory.connect(someone)
      .create(types.shakeable, [{ payee: shareholder1.address, bps: 2500 }, { payee: shareholder2.address, bps: 2500 }, { payee: shareholder3.address, bps: 5000 }]))
      .to.emit(factory, "CreatedSplitter");

    expect(await factory.instances()).to.be.equal(3);
    expect(await factory.get(types.shakeable, 1)).to.be.equal(shakeAddress);
    expect(await factory.get(types.push, 2)).to.be.equal(pushAddress);
  });

  describe("A PushSplitter", () => {
    it("Should forward payments automatically", async function () {
      const receipt = await (await factory.connect(someone)
        .create(types.push, [{ payee: shareholder1.address, bps: 1500 }, { payee: shareholder2.address, bps: 3500 }, { payee: shareholder3.address, bps: 5000 }]))
        .wait();

      let contractAddress = "0x0";
      for (const event of receipt.events!) {
        if (event.event === "CreatedSplitter") {
          contractAddress = event.args!.contractAddress;
        }
      }
      expect(contractAddress).to.not.be.equal("0x0");
      const splitter = (await ethers.getContractAt("PushSplitter", contractAddress)) as PushSplitter;
      await expect(await sender.sendTransaction({ to: splitter.address, value: ethers.utils.parseEther("1.0") }))
      .to.changeEtherBalances(
        [sender, shareholder1, shareholder2, shareholder3, splitter],
        [ethers.utils.parseEther("-1.0"), ethers.utils.parseEther(".15"), ethers.utils.parseEther(".35"), ethers.utils.parseEther(".50"), ethers.utils.parseEther("0")]);
    });

    it("Should allow transferring", async function () {
      const receipt = await (await factory.connect(someone)
        .create(types.push, [{ payee: shareholder1.address, bps: 1500 }, { payee: shareholder2.address, bps: 3500 }, { payee: shareholder3.address, bps: 5000 }]))
        .wait();

      let contractAddress = "0x0";
      for (const event of receipt.events!) {
        if (event.event === "CreatedSplitter") {
          contractAddress = event.args!.contractAddress;
        }
      }
      expect(contractAddress).to.not.be.equal("0x0");
      const splitter = (await ethers.getContractAt("PushSplitter", contractAddress)) as PushSplitter;
      await splitter.connect(shareholder1).transferTo(shareholder2.address);
      await expect(await sender.sendTransaction({ to: splitter.address, value: ethers.utils.parseEther("1.0") }))
      .to.changeEtherBalances(
        [sender, shareholder1, shareholder2, shareholder3, splitter],
        [ethers.utils.parseEther("-1.0"), ethers.utils.parseEther(".0"), ethers.utils.parseEther(".4117"), ethers.utils.parseEther(".5882"), ethers.utils.parseEther("0")]);
    });
  });

  describe("The created ShakeableSplitter", () => {
    let splitter:ShakeableSplitter;

    it("Should hold payments", async function () {
      const receipt = await (await factory.connect(someone)
        .create(types.shakeable, [{ payee: shareholder1.address, bps: 1500 }, { payee: shareholder2.address, bps: 3500 }, { payee: shareholder3.address, bps: 5000 }]))
        .wait();

      let contractAddress = "0x0";
      for (const event of receipt.events!) {
        if (event.event === "CreatedSplitter") {
          contractAddress = event.args!.contractAddress;
        }
      }
      expect(contractAddress).to.not.be.equal("0x0");
      splitter = (await ethers.getContractAt("ShakeableSplitter", contractAddress)) as ShakeableSplitter;
      await expect(await sender.sendTransaction({ to: splitter.address, value: ethers.utils.parseEther("1.0") })).to.changeEtherBalances(
          [sender, splitter],
          [ethers.utils.parseEther("-1.0"), ethers.utils.parseEther("1.0")]);
    });

    it("Should allow withdrawals", async function () {
      await expect(await splitter.withdraw(shareholder1.address)).to.changeEtherBalances(
        [splitter, shareholder1],
        [ethers.utils.parseEther("-.15"), ethers.utils.parseEther(".15")]);

      await expect(await splitter.withdraw(shareholder3.address)).to.changeEtherBalances(
          [splitter, shareholder3],
          [ethers.utils.parseEther("-.50"), ethers.utils.parseEther(".50")]);

      await expect(await splitter.totalReleased()).to.be.equal(ethers.utils.parseEther(".65"));
    });

    it("Should allow shaking", async function () {
      await splitter.shake(); // clears the balance
      await sender.sendTransaction({ to: splitter.address, value: ethers.utils.parseEther("3.0") });
      await expect(await splitter.shake()).to.changeEtherBalances(
        [splitter, shareholder1, shareholder2, shareholder3],
        [ethers.utils.parseEther("-3.0"), ethers.utils.parseEther(".45"), ethers.utils.parseEther("1.05"), ethers.utils.parseEther("1.50")]);
    });
  });
});
