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

  // const MMR = await ethers.getContractFactory("MMR");
  // mmrLib = await MMR.deploy();
  // await mmrLib.deployed();
  // console.log("MMR deployed to:", mmrLib.address);

  // const Scale = await ethers.getContractFactory("Scale");
  // scale = await Scale.deploy();
  // await scale.deployed();
  // console.log("Scale deployed to:", scale.address);

  // const SimpleMerkleProof = await ethers.getContractFactory("SimpleMerkleProof");
  // simpleMerkleProof = await SimpleMerkleProof.deploy();
  // await simpleMerkleProof.deployed();
  // console.log("SimpleMerkleProof deployed to:", simpleMerkleProof.address);

  // MMR deployed to: 0x8C66aebC119a98Bbc521d192CD976E500f64a73a
  // Scale deployed to: 0xa4D869e3Eea8Ba408740779a00aFe1dd59f4993f
  // SimpleMerkleProof deployed to: 0xacfeDAf15495b430155C8554e6e3678F938B5784

  // const ProxyAdmin = await ethers.getContractFactory("ProxyAdmin");
  // proxyAdmin = await ProxyAdmin.deploy();
  // await proxyAdmin.deployed();
  // console.log("ProxyAdmin deployed to:", proxyAdmin.address);

  const proxyAdminAddress = {
    'kovan': '0x239c672bB2De2516a165c1d901335b4A8530A680',
    'dev': '0x0000000000000000000000000000000000000000',
    'ropsten': '0x0000000000000000000000000000000000000000',
    'mainnet': '0x0000000000000000000000000000000000000000'
  }

  const registryAddress = {
    'kovan': '0x0000000000000000000000000000000000000000',
    'dev': '0x0000000000000000000000000000000000000000',
    'ropsten': '0x0000000000000000000000000000000000000000',
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
    0x43726162
  ];

  // Build Relay.sol Logic
  relay = await Relay.deploy();
  await relay.deployed();
  console.log("Relay logic deployed to:", relay.address);

  // Build Relay.sol Proxy
  const relayDataTransparentUpgradeableProxy = Util.getInitializerData(Relay, relayConstructor);
  
  const relayProxyConstructor = [relay.address, proxyAdminAddress[network.name], relayDataTransparentUpgradeableProxy];
  relayTransparentUpgradeableProxy = await TransparentUpgradeableProxy.deploy(...relayProxyConstructor);

  Util.writeFile('./scripts/argu/relayproxy.js', Util.convertArguText(
    JSON.stringify(relayProxyConstructor, null, 2)
    ),
  );

  await relayTransparentUpgradeableProxy.deployed();
  console.log("Relay proxy deployed to:", relayTransparentUpgradeableProxy.address);

  // Non-proxy deploy
  // await relay.initialize(...relayConstructor);
  // relay = await upgrades.deployProxy(Relay, relayConstructor, { unsafeAllowCustomTypes: true });
  // console.log("Relay Proxy deployed to:", relay.address);

  const TokenIssuing = await ethers.getContractFactory("TokenIssuing", {
    libraries: {
      // Scale: scale.address,
    }
  });

  const issuingConstructor = [
    "0x0000000000000000000000000000000000000000",
    // relay.address
    relayTransparentUpgradeableProxy.address
  ]
  
  // Build TokenIssuing.sol Logic
  issuing = await TokenIssuing.deploy();
  await issuing.deployed();

  // Non-proxy deploy
  // await issuing.initialize(...issuingConstructor);
  // issuing = await upgrades.deployProxy(TokenIssuing, issuingConstructor, { unsafeAllowCustomTypes: true });

  // Build TokenIssuing.sol Proxy
  const issuingDataTransparentUpgradeableProxy = Util.getInitializerData(TokenIssuing, issuingConstructor);
  Util.writeFile('./scripts/argu/tokenbackingproxy.js', Util.convertArguText(
      JSON.stringify([relay.address, proxyAdminAddress[network.name], issuingDataTransparentUpgradeableProxy], null, 2)
      ),
    );

  relayTransparentUpgradeableProxy = await TransparentUpgradeableProxy.deploy(relay.address, proxyAdminAddress[network.name], issuingDataTransparentUpgradeableProxy);
  await relayTransparentUpgradeableProxy.deployed();
  console.log("Relay proxy deployed to:", relayTransparentUpgradeableProxy.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });