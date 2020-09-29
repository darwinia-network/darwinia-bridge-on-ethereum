
const MMR = artifacts.require("MMR");
const Blake2b = artifacts.require("Blake2b");
const DarwiniaRelay = artifacts.require("DarwiniaRelay");
const RelayerGame = artifacts.require("RelayerGame");
const POARelay = artifacts.require("POARelay");

module.exports = function(deployer) {
  deployer.deploy(MMR);
  deployer.deploy(Blake2b);
  
  // deployer.link(MMR, DarwiniaRelay);
  // deployer.link(Blake2b, DarwiniaRelay);
  // deployer.deploy(DarwiniaRelay);

  // deployer.deploy(RelayerGame);

  deployer.link(MMR, POARelay);
  deployer.deploy(POARelay);
};
