//deployment for testing purpose
const MOCK_NextMillionaire = artifacts.require("NextMillionaire");

module.exports = function (deployer) {
  deployer.deploy(MOCK_NextMillionaire,1653465925);
};
