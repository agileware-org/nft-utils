/* eslint-disable camelcase */
/* eslint-disable node/no-missing-import */
/* eslint-disable node/no-unpublished-require */
/* eslint-disable node/no-unpublished-import */
import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction, DeployResult } from "hardhat-deploy/types";
import { SplitterFactory__factory } from "../src/types";
import "hardhat-deploy-ethers";
import { writeFileSync } from "fs";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployments, getNamedAccounts, getChainId } = require("hardhat");
  const { deploy, get } = deployments;
  const { deployer } = await getNamedAccounts();

  const factory = await deploy("SplitterFactory", {
    from: deployer,
    log: true
  }) as DeployResult;

  if (await getChainId() < 10) {
    const [deployer] = await hre.ethers.getSigners();
    const contract = SplitterFactory__factory.connect(factory.address, deployer);
    const splitters = {
      push: hre.ethers.utils.keccak256(hre.ethers.utils.toUtf8Bytes("push")),
      shakeable: hre.ethers.utils.keccak256(hre.ethers.utils.toUtf8Bytes("shakeable"))
    };
    try {
      await contract.addSplitterType(splitters.push, (await get("PushSplitter")).address);
      console.log("PushSplitter deployed and linked");
      await contract.addSplitterType(splitters.shakeable, (await get("ShakeableSplitter")).address);
      console.log("ShakeableSplitter deployed and linked");

      writeFileSync("./src/splitters.json", JSON.stringify(splitters, null, 2), { encoding: "utf-8" });
    } catch (e) { console.log(e); }
  }
};
export default func;
func.dependencies = ["PushSplitter"];
func.dependencies = ["ShakeableSplitter"];
func.tags = ["splitters"];
