const TestVectors = require('./blake2-kat.json');
const { expect } = require("chai");
const { solidity } = require("ethereum-waffle");
const chai = require("chai");
const MerkleTree = require("merkletreejs").MerkleTree;

chai.use(solidity);


describe('Blake2bTest', function (accounts) {
    let contract;

    before(async () => {
        Blake2bTest = await ethers.getContractFactory("Blake2bTest");

        contract = await Blake2bTest.deploy();
        await contract.deployed();
    });

    it.skip('blake2b crab MMRMerge6', async () => {
        let input = Buffer.from('12e69454d992b9b1e00ea79a7fa1227c889c84d04b7cd47e37938d6f69ece45d3733bd06905e128d38b9b336207f301133ba1d0a4be8eaaff6810941f0ad3b1a', 'hex');
        let ret = await contract.testOneBlock32(input);
        expect(ret).to.equal('0xbc3653f301c613152cf85bc3af425692b456847ff6371e5c23e4d74eb6f95ff3');
    });

    it.skip('blake2b reftest (25 bytes input)', async () => {
        let input = Buffer.from('000102030405060708090a0b0c0d0e0f101112131415161718', 'hex');
        let ret = await contract.testOneBlock32(input);
        expect(ret).to.equal('0x3b0b9b4027203daeb62f4ff868ac6cdd78a5cbbf7664725421a613794702f4f4');
    });

    it.skip('blake2b reftest (255 bytes input)', async () => {
        let input = Buffer.from('000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f202122232425262728292a2b2c2d2e2f303132333435363738393a3b3c3d3e3f404142434445464748494a4b4c4d4e4f505152535455565758595a5b5c5d5e5f606162636465666768696a6b6c6d6e6f707172737475767778797a7b7c7d7e7f808182838485868788898a8b8c8d8e8f909192939495969798999a9b9c9d9e9fa0a1a2a3a4a5a6a7a8a9aaabacadaeafb0b1b2b3b4b5b6b7b8b9babbbcbdbebfc0c1c2c3c4c5c6c7c8c9cacbcccdcecfd0d1d2d3d4d5d6d7d8d9dadbdcdddedfe0e1e2e3e4e5e6e7e8e9eaebecedeeeff0f1f2f3f4f5f6f7f8f9fafbfcfdfe', 'hex');
        let ret = await contract.testOneBlock32(input);
        expect(ret).to.equal('0x1d0850ee9bca0abc9601e9deabe1418fedec2fb6ac4150bd5302d2430f9be943');
    });
});
