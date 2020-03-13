const HDWalletProvider = require("@truffle/hdwallet-provider");
const mnemonic = "defy goddess armed direct advance hungry adjust match embrace debate distance guess";

module.exports = {
  networks: {
    development: {
      host: "localhost",
      port: 7545,
      network_id: "*", // Match any network id
      gas: 5000000
    },
    kovan: {
      provider: function() {
        return new HDWalletProvider(mnemonic, "https://kovan.infura.io/v3/ef99d0681ca34d2baeb05aa437de7b4c")
      },
      network_id: 42
    }
  },
  compilers: {
    solc: {
      settings: {
        optimizer: {
          enabled: true, // Default: false
          runs: 200      // Default: 200
        },
      }
    }
  }
};
