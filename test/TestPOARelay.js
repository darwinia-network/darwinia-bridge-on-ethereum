const { expectRevert, time } = require('@openzeppelin/test-helpers');

const POARelay = artifacts.require('POARelay');
const MMR = artifacts.require('MMR');

const Web3Utils = require("web3-utils");
const BigNumber = web3.BigNumber;

require("chai")
  .use(require("chai-as-promised"))
  .use(require("chai-bignumber")(BigNumber))
  .should();

contract('POARelay', (accounts) => {
  let mmrLib;
  let relay;
  let blake2b;
  let res;
  let darwiniaRelay;
  before(async () => {
    mmrLib = await MMR.new();
    await POARelay.link('MMR', mmrLib.address);
  });

  describe('utils', async () => {
    before(async () => {
      relay = await POARelay.new();
      const proof = {
        root: '0xfa36bb3176772b05ba22963825abbfb14379fe87b9a18449ec8175096c345d93',
        width: 7,
        peakBagging: [
          "0x53beeed16718d356e5494ef52332b50d16cf8588f36dd19f29f7d4c404d860be",
          "0xa7df2cb3ecdca703b0471f655de3cefc7ebf943b4d94303c317b06a9dcc6ddcb",
          "0xc58e247ea35c51586de2ea40ac6daf90eac7ac7b2f5c88bbc7829280db7890f1"
        ],
        siblings: [
          '0x70d641860d40937920de1eae29530cdc956be830f145128ebb2b496f151c1afb',
          '0xdfafd69d36c0d7d6cd07bfce7bcf93c5221e9f2fe11ea9df8ff79e1a4750295b'
        ]
      }

      // const isValid = await relay.inclusionProof.call(proof.root, proof.width, 1, '0x00', '0x34f61bfda344b3fad3c3e38832a91448b3c613b199eb23e5110a635d71c13c65', proof.peakBagging, proof.siblings)
      // console.log(isValid)
    });

    it('decodeCompactU8a 63', async () => {
      let result = await relay.decodeCompactU8aOffset.call('0xfc');
      assert.equal(result.toNumber(), 1);
    });

    it('decodeCompactU8a 511', async () => {
      let result = await relay.decodeCompactU8aOffset.call('0xFD');
      assert.equal(result.toNumber(), 2);
    });

    it('decodeCompactU8a 0xffff', async () => {
      let result = await relay.decodeCompactU8aOffset.call('0xFE');
      assert.equal(result.toNumber(), 4);
    });

    it('decodeCompactU8a 0xfffffff9', async () => {
      let result = await relay.decodeCompactU8aOffset.call('0x3');
      assert.equal(result.toNumber(), 5);
    });

    it('decodeCompactU8a 1556177', async () => {
      let result = await relay.decodeCompactU8aOffset.call('0x46');
      assert.equal(result.toNumber(), 4);
    });

    it('block 1', async () => {
      let result = await relay.getStateRootFromBlockHeader.call(0, '0x00000000000000000000000000000000000000000000000000000000000000000034d4cabbcdf7ad81f7966f17f08608a6dfb87fcd2ec60ee4a14a5e13223c110f03170a2e7597b7b7e3d84c05391d139a62b157e78786d8c082f29dcf4c11131400');
      assert.equal(result, '0x34d4cabbcdf7ad81f7966f17f08608a6dfb87fcd2ec60ee4a14a5e13223c110f');
    });

    it('block 1556177', async () => {
      result = await relay.getStateRootFromBlockHeader.call(0, '0xb0209dd32ae874b32f152fc6fe2db8239b661746f010a82aa3389f57a33c659c46fb5e003a95a548cc56b60091f835b0d467bdd0bfff9f1cf5414ae6628f03ce0166ef3580f3f8edfbc56eed5c09443c4a82551a4d312df46208d7664d096001464192de00');
      assert.equal(result, '0x3a95a548cc56b60091f835b0d467bdd0bfff9f1cf5414ae6628f03ce0166ef35');
    });

    it('block 1073741824', async () => {
      result = await relay.getStateRootFromBlockHeader.call(0, '0xb0209dd32ae874b32f152fc6fe2db8239b661746f010a82aa3389f57a33c659c03000000403a95a548cc56b60091f835b0d467bdd0bfff9f1cf5414ae6628f03ce0166ef3580f3f8edfbc56eed5c09443c4a82551a4d312df46208d7664d096001464192de00');
      assert.equal(result, '0x3a95a548cc56b60091f835b0d467bdd0bfff9f1cf5414ae6628f03ce0166ef35');
    });
  });


  describe('updateRoot', async () => {
    it('add mmr root', async () => {
      result = await relay.updateRoot(0, '0x0000000000000000000000000000000000000000000000000000000000000001');
      const mmr = await relay.getMMR.call(0);
      assert.equal(mmr, '0x0000000000000000000000000000000000000000000000000000000000000001');
    });

    it('updateRoot same width', async () => {
      await expectRevert(
        relay.updateRoot(0, '0x0000000000000000000000000000000000000000000000000000000000000001'),
        'Width has been set.',
      );
    });
  })

  describe('resetRoot', async () => {
    it('reset mmr root', async () => {
      await relay.updateRoot(5, '0x0000000000000000000000000000000000000000000000000000000000000005');
      await relay.updateRoot(6, '0x0000000000000000000000000000000000000000000000000000000000000006');
      await relay.resetRoot(5, '0x0000000000000000000000000000000000000000000000000000000000000055');
      expect(await relay.getMMR.call(5)).to.be.equal(
        '0x0000000000000000000000000000000000000000000000000000000000000055',
      );
    });

    it('paused status', async () => {
      await expectRevert(relay.updateRoot(7, '0x0000000000000000000000000000000000000000000000000000000000000007'),
        'Pausable: paused.',
      );
    });

    it('unpaused status', async () => {
      await relay.unpause();
      await relay.updateRoot(8, '0x0000000000000000000000000000000000000000000000000000000000000008');
      const mmr = await relay.getMMR.call(8);
      assert.equal(mmr, '0x0000000000000000000000000000000000000000000000000000000000000008');
    });
  })
});
