var HDWalletProvider = require('truffle-hdwallet-provider');
var mnemonic = 'thank brown track peasant piano exact spell foot hunt budget crush smooth';

module.exports = {
  networks: {
    development: {
      host: "localhost",
      port: 8545,
      network_id: "*" // Match any network id
    },
    ropsten: {
     provider: new HDWalletProvider(mnemonic, "https://testnet.infura.io/"),
     network_id: 3
   },
  }
};
