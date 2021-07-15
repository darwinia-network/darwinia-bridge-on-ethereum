const hre = require("hardhat");

async function main() {
  const network = await hre.ethers.provider.getNetwork()
  console.log('Network: ', network.name);

  await hre.run('compile');

  const lightClientBridge = "0x5FbDB2315678afecb367f032d93F642f64180aa3"

  const BasicInboundChannel = await hre.ethers.getContractFactory("BasicInboundChannel");
  const inbound = await BasicInboundChannel.deploy(lightClientBridge);
  await inbound.deployed();
  console.log("BasicInboundChannel deployed to:", inbound.address);

  const BasicOutboundChannel = await hre.ethers.getContractFactory("BasicOutboundChannel");
  const outbound = await BasicOutboundChannel.deploy();
  await outbound.deployed();
  console.log("BasicOutboundChannel deployed to:", outbound.address);
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
