const RandomNumberGenerator = artifacts.require("RandomNumberGenerator");

module.exports = function (deployer) {
  deployer.deploy(RandomNumberGenerator,4861);
};
