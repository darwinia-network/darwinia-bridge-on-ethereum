const { expect } = require("chai");
const { solidity } = require("ethereum-waffle");
const chai = require("chai");

chai.use(solidity);

describe('inputTest', function (accounts) {

  before(async () => {

    InputTest = await ethers.getContractFactory("InputTest");

    inputTest = await InputTest.deploy();
    await inputTest.deployed();
  });

  it('inputTest', async () => {
    await inputTest.testToBytes32();
    await inputTest.testToBytesN();
  })

  it('testToBytes32Revert', async () => {
    await expect(inputTest.testToBytes32Revert()).to.be.revertedWith('Input: Out of range');
  })
});
