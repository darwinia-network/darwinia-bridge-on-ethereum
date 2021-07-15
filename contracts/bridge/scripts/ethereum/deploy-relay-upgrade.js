// We require the Hardhat Runtime Environment explicitly here. This is optional 
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");
const Util = require("./utils");

const ethers = hre.ethers;
const upgrades = hre.upgrades;

async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile 
  // manually to make sure everything is compiled
  await hre.run('compile');

  const [owner, addr1, addr2] = await ethers.getSigners();
  const network = await ethers.provider.getNetwork()
  console.log('Network: ', network.name);

  // We get the contract to deploy

  const ProxyAdmin = await ethers.getContractFactory("ProxyAdmin");
  // const proxyAdmin = await Util.deployContract("ProxyAdmin", ProxyAdmin);

  const proxyAdminAddress = {
    'kovan': '0x239c672bB2De2516a165c1d901335b4A8530A680',
    'unknown': '0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512',
    'ropsten': '0x197Ab983234DF1ba0c0129d665d44bDaa933d7ba',
    'mainnet': '0x0000000000000000000000000000000000000000'
  }

  const registryAddress = {
    'kovan': '0x0000000000000000000000000000000000000000',
    'unknown': '0x0000000000000000000000000000000000000000',
    'ropsten': '0x6982702995b053A21389219c1BFc0b188eB5a372',
    'mainnet': '0x0000000000000000000000000000000000000000',
  }

  // Get contract artifacts
  const TransparentUpgradeableProxy = await ethers.getContractFactory("TransparentUpgradeableProxy");

  const Relay = await ethers.getContractFactory(
    'Relay',
    {
      libraries: {
        // if the type of function change to "public"
        // MMR: mmrLib.address,
        // SimpleMerkleProof: simpleMerkleProof.address,
        // Scale: scale.address
      }
    }
  );

  // Pangolin 0x50616e676f6c696e
  // Crab 0x43726162
  const relayConstructor = [
    11309,
    '0xe1fe85d768c17641379ef6dfdf50bdcabf6dd83ec325506dc82bf3ff653550dc',
    [
      await owner.getAddress(),
      await addr1.getAddress(),
      await addr2.getAddress(),
    ],
    0,
    60,
    '0x50616e676f6c696e'
  ];

  const TokenIssuing = await ethers.getContractFactory("TokenIssuing", {
    libraries: {
      // Scale: scale.address,
    }
  });
  const adminContract = await ProxyAdmin.attach(proxyAdminAddress[network.name]);

  async function upgradeRelay() {
    const relayLogic = await Util.upgradeProxy("Relay", Relay, TransparentUpgradeableProxy, '0xf106a8A1C0aA10EB6E7EA7595A6E63ac6AcBdEe8', adminContract);
  }

  async function upgradeTokenIssuing() {
      const tokenIssuingLogic = await Util.upgradeProxy("TokenIssuing", TokenIssuing, TransparentUpgradeableProxy, '0x214c2B7E9D20b6BeB9F5cE503Fd010Bc716a9AD2', adminContract);
  }

  await upgradeTokenIssuing();

  // const relayLogic = await Util.upgradeProxy("Relay", Relay, TransparentUpgradeableProxy, '0x7e25Ced0F83156b77897618bE0bC88AAd4C372E6', adminContract);
  // const tokenIssuingLogic = await Util.upgradeProxy("TokenIssuing", TokenIssuing, TransparentUpgradeableProxy, '0xbf2941547bCd039D941b21C81bcEbA1aF77b2253', adminContract);
  // return
  // const [relayLogic, relayProxy] = await Util.deployTransparentUpgradeableProxy("Relay", Relay, TransparentUpgradeableProxy, proxyAdminAddress[network.name], relayConstructor);
  // const proxyAdmin = ProxyAdmin.attach(proxyAdminAddress[network.name]);
  // const proxyAdminAddr = await proxyAdmin.getProxyAdmin(relayProxy.address);

  // console.log('check proxy admin: ', proxyAdminAddr);

  // const TokenIssuing = await ethers.getContractFactory("TokenIssuing", {
  //   libraries: {
  //     // Scale: scale.address,
  //   }
  // });

  // const issuingConstructor = [
  //   // registry.address
  //   registryAddress[network.name],
  //   // relay.address
  //   relayProxy.address,
  //   // storage_key
  //   "0xf8860dda3d08046cf2706b92bf7202eaae7a79191c90e76297e0895605b8b457"
  // ]

  // const [issuingLogic, issuingProxy] = await Util.deployTransparentUpgradeableProxy("TokenIssuing", TokenIssuing, TransparentUpgradeableProxy, proxyAdminAddress[network.name], issuingConstructor);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });