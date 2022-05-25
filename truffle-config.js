const HDWalletProvider = require('@truffle/hdwallet-provider');
const fs = require('fs');
const mnemonic = fs.readFileSync(".secret").toString().trim();


module.exports = {
  // Configure your compilers
  compilers: {
    solc: {
      version: "0.8.13", // Fetch exact version from solc-bin (default: truffle's version)
      // docker: true,        // Use "0.5.1" you've installed locally with docker (default: false)
      // settings: {          // See the solidity docs for advice about optimization and evmVersion
      optimizer: {
        enabled: true,
        runs: 200,
      },
      //  evmVersion: "byzantium"
      // }
    },
  },
  /**
   * Networks define how you connect to your ethereum client and let you set the
   * defaults web3 uses to send transactions. If you don't specify one truffle
   * will spin up a development blockchain for you on port 9545 when you
   * run `develop` or `test`. You can ask a truffle command to use a specific
   * network from the command line, e.g
   *
   * $ truffle test --network <network-name>
   */

  networks: {
   
    develop: {
      port: 8545,
      network_id: 20,
      accounts: 5,
      defaultEtherBalance: 500,
      blockTime: 3,
      websockets: true
    },

    polygon_mainnet: {
      provider: () =>
        new HDWalletProvider(mnemonic, `https://rpc-mainnet.maticvigil.com`),
      network_id: 137,
      confirmations: 2,
      timeoutBlocks: 200,
      skipDryRun: true,
    },

    bsc_testnet: {
      provider: () =>
        new HDWalletProvider(
          mnemonic,
          `https://data-seed-prebsc-1-s1.binance.org:8545`
        ),
      network_id: 97,
      confirmations: 10,
      timeoutBlocks: 200,
      skipDryRun: true,
      gas: 10000000,
    },

    bsc: {
      provider: () =>
        new HDWalletProvider(mnemonic, `https://bsc-dataseed1.binance.org`),
      network_id: 56,
      confirmations: 10,
      timeoutBlocks: 200,
      skipDryRun: true,
    },
    rinkeby: {
      provider: function() { 
       return new HDWalletProvider(mnemonic, "https://rinkeby.infura.io/v3/b35d769b8321433bbac9ad5e782ff344");
      },
      network_id: 4,
      gas: 4500000,
      gasPrice: 10000000000,
  },
    truffle_dashboard: {
      url: "http://localhost:24012/rpc",
      network_id:97
    },
    // Set default mocha options here, use special reporters etc.
    mocha: {
      // timeout: 100000
    },
  },
  plugins: ["truffle-plugin-verify"],

  api_keys: {
    
    bscscan: "UR4ZGJRAZSV12UNGS918GYMYVKDTS6CY4H",
    etherscan: "NUP3ICFY7CXI5T766CMKMYEIFUC8JAPHPV"
  },
  dashboard: {
    port: 25012,
    host: "localhost"
  }
};