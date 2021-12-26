import * as dotenv from "dotenv";

import { HardhatUserConfig, task } from "hardhat/config";
import "@nomiclabs/hardhat-etherscan";
import "@nomiclabs/hardhat-waffle";
import "@typechain/hardhat";

import "hardhat-deploy";
import "hardhat-gas-reporter";
import "solidity-coverage";

dotenv.config();

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

const INFURA_API_KEY = process.env.INFURA_API_KEY;
const PRIVATE_KEY = process.env.PRIVATE_KEY;

const config: HardhatUserConfig = {
  defaultNetwork: "rinkeby",
  namedAccounts: {
    deployer: {
      default: 0,
      1: "0xDEE48aB42ceEb910c8C61a8966A57Dcf3E8B6706",
      4: "0xDEE48aB42ceEb910c8C61a8966A57Dcf3E8B6706",
    }
  },
  solidity: {
    compilers: [{
      version: "0.8.9",
      settings: {
        optimizer: {
          runs: 200000,
          enabled: true
        }
      }
    }],
    overrides: {
    }
  },
  networks: {
    hardhat: {
      mining: {
        auto: true,
        interval: 200
      }
    },
    localhost: {},
    rinkeby: {
      url: `https://rinkeby.infura.io/v3/${INFURA_API_KEY}`,
      accounts: [process.env.PRIVATE_KEY || ""],
    },
    coverage: {
      url: "http://127.0.0.1:8545", // Coverage launches its own ganache-cli client
    },
    mainnet: {
      url: `https://mainnet.infura.io/v3/${INFURA_API_KEY}`,
      gasPrice: 70000000000, // 70 Gwei
      accounts: [process.env.PRIVATE_KEY || ""],
    }
  },
  etherscan: {
    apiKey: process.env.ETHERSCAN_API_KEY,
  },
  gasReporter: {
    currency: "USD",
    enabled: process.env.REPORT_GAS !== undefined,
    coinmarketcap: process.env.COINMARKETCAP_API_KEY,
    maxMethodDiff: 10,
  },
  typechain: {
    outDir: "src/types"
  }
};

export default config;
