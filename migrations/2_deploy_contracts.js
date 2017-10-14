var IBO = artifacts.require('./IBO.sol');
var HumanStandardToken = artifacts.require('./HumanStandardToken.sol');

module.exports = function (deployer) {
  deployer.deploy(HumanStandardToken, 5000000000, 'MY COIN', 3, 'my').then(function (contractAddress) {
    console.log(contractAddress);
    deployer.deploy(IBO, HumanStandardToken.address).then(function (tx) {
      console.log('done', tx);
    }).catch(function (e) {
      console.log(e);
    });
  }).catch(function (e) {
    console.log(e);
  });
};
