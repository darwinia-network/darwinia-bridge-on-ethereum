const hre = require("hardhat");

async function main() {
  const network = await hre.ethers.provider.getNetwork()
  console.log('Network: ', network.name);

  await hre.run('compile');

  const LightClientBridge = await hre.ethers.getContractFactory("LightClientBridge");
  const lightClientBridge = await LightClientBridge.deploy(0, 3, "0x7ed7485ab2520a165816e82b778b62e65b2d21da3d0dbf98493869287b386607");

  await lightClientBridge.deployed();

  console.log("LightClientBridge deployed to:", lightClientBridge.address);
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
