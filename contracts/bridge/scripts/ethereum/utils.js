const fs = require("fs");


async function upgradeProxy(name, Factory, TransparentUpgradeableProxy, proxyAddress, adminContract) {
  // Build sol Logic
  const logic = await deployContract(name, Factory, []);
  // const proxy = TransparentUpgradeableProxy.attach(proxyAddress);
  await adminContract.upgrade(proxyAddress, logic.address);
  return logic;
}

async function deployTransparentUpgradeableProxy(name, Factory, TransparentUpgradeableProxy, admin, argu = []) {
  // Build sol Logic
  const logic = await deployContract(name, Factory, []);

  // Build sol Proxy
  const dataTransparentUpgradeableProxy = getInitializerData(Factory, argu);

  const proxyConstructor = [logic.address, admin, dataTransparentUpgradeableProxy];
  const proxy = await TransparentUpgradeableProxy.deploy(...proxyConstructor);

  writeFile(`./scripts/argu/${name}.proxy.js`, convertArguText(
    JSON.stringify(proxyConstructor, null, 2)
  ),
  );

  await proxy.deployed();
  console.log('==================');
  console.log(`${name} logic deployed to:`, logic.address);
  console.log(`${name} proxy deployed to:`, proxy.address);
  console.log(`${name} prxoy admin is:`, admin);
  console.log('==================');
  return [logic, proxy];
}

async function deployContract(name, Factory, argu = []) {
  factory = await Factory.deploy(...argu);
  await factory.deployed();
  console.log(`${name} contract deployed to:`, factory.address);

  writeFile(`./scripts/argu/${name}.js`, convertArguText(
    JSON.stringify(argu, null, 2)
  ),
  );
  return factory;
}

function convertArguText(jsonText) {
  return 'module.exports = ' + jsonText;
}

function writeFile(path, content) {
  fs.writeFile(path, content, error => {
    if (error) return console.log("fs:: error:" + error.message);
    console.log(`fs:: success: ${path}`);
  });
}

function getInitializerData(ImplFactory, args, initializer) {
  if (initializer === false) {
    return '0x';
  }

  const allowNoInitialization = initializer === undefined && args.length === 0;
  initializer = initializer || 'initialize';

  try {
    const fragment = ImplFactory.interface.getFunction(initializer);
    return ImplFactory.interface.encodeFunctionData(fragment, args);
  } catch (e) {
    if (e instanceof Error) {
      if (allowNoInitialization && e.message.includes('no matching function')) {
        return '0x';
      }
    }
    throw e;
  }
}


module.exports = {
  getInitializerData,
  writeFile,
  convertArguText,
  deployContract,
  deployTransparentUpgradeableProxy,
  upgradeProxy
}