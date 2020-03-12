const Migrations = artifacts.require("Trading");

module.exports = function(deployer) {
  deployer.deploy(Migrations);
};
