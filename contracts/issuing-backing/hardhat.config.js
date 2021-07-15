require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-etherscan");
require('hardhat-abi-exporter');

require('dotenv').config({ path: '../../.env' })

const MAINNET_RPC_URL = process.env.MAINNET_RPC_URL || process.env.ALCHEMY_MAINNET_RPC_URL 
const RINKEBY_RPC_URL = process.env.RINKEBY_RPC_URL 
const ROPSTEN_RPC_URL = process.env.ROPSTEN_RPC_URL
const KOVAN_RPC_URL = process.env.KOVAN_RPC_URL 
const PRIVATE_KEY = process.env.PRIVATE_KEY 
const ETHERSCAN_API_KEY = process.env.ETHERSCAN_API_KEY 

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  mocha: {
    timeout: 1000000
  },
  solidity: {
    compilers: [
      {
        version: "0.6.9",
        settings: {
          evmVersion: "istanbul",
          optimizer: {
            enabled: true,
            runs: 999999
          },
          outputSelection: {
            "*": {
              "*": [
                "abi",
                "devdoc",
                "metadata",
                "evm.bytecode.object",
                "evm.bytecode.sourceMap",
                "evm.deployedBytecode.object",
                "evm.deployedBytecode.sourceMap",
                "evm.methodIdentifiers"
              ],
              "": ["ast"]
            }
          }
        }
      },
      {
        version: "0.4.24",
        settings: {
          evmVersion: "byzantium",
          optimizer: {
            enabled: true,
            runs: 999999
          },
          outputSelection: {
            "*": {
              "*": [
                "abi",
                "devdoc",
                "metadata",
                "evm.bytecode.object",
                "evm.bytecode.sourceMap",
                "evm.deployedBytecode.object",
                "evm.deployedBytecode.sourceMap",
                "evm.methodIdentifiers"
              ],
              "": ["ast"]
            }
          }
        }
      }
    ]
  },
  paths: {
    sources: "./contracts",
    tests: "./test",
    cache: "./cache",
    artifacts: "./artifacts"
  },
  defaultNetwork: 'ropsten',
  networks: {
    hardhat: {
    },
    dev: {
      url: 'http://localhost:8545/',
      network_id: "*",
      accounts: [PRIVATE_KEY]
    },
    ropsten: {
      url: ROPSTEN_RPC_URL,
      network_id: "*",
      accounts: [PRIVATE_KEY],
      timeout: 100000
    },
    mainnet: {
      url: MAINNET_RPC_URL,
      network_id: "1",
      gasPrice: 53100000000,
      accounts: [PRIVATE_KEY],
      timeout: 1000000
    },
    kovan: {
      url: KOVAN_RPC_URL,
      network_id: "*",
      accounts: [PRIVATE_KEY],
      timeout: 200000
    }
  },
  etherscan: {
    apiKey: process.env.ETHERSCAN_KEY
  },
  abiExporter: {
    path: './abi/',
    clear: false,
    flat: false,
    only: [],
  }
};

