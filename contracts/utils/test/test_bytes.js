const { expect } = require("chai");
const { solidity } = require("ethereum-waffle");
const chai = require("chai");

chai.use(solidity);

describe('TestBytes', function (accounts) {

  before(async () => {

    Bytes = await ethers.getContractFactory("BytesTest");

    bytesLib = await Bytes.deploy();
    await bytesLib.deployed();
  });

  it.skip('BytesTest', async () => {
    await bytesLib.testToBytes32();
    await bytesLib.testToBytes16();
  })

  it.skip('testToBytes32Revert', async () => {
    await expect(bytesLib.testToBytes32Revert()).to.be.revertedWith('Bytes:: toBytes32: data is to short.');
  })

  it.skip('testToBytes16Revert', async () => {
    await expect(bytesLib.testToBytes16Revert()).to.be.revertedWith('Bytes:: toBytes16: data is to short.');
  })
});
