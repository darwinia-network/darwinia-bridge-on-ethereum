const {expect, use} = require('chai');
const { solidity }  = require("ethereum-waffle");

use(solidity);

describe.skip('MerkleProofTest', function (accounts) {
    let SimpleMerkleProofTest;

    before(async () => {
        SimpleMerkleProof = await ethers.getContractFactory("SimpleMerkleProof");
        // CompactMerkleProofTest = await ethers.getContractFactory("CompactMerkleProofTest");
        Scale = await ethers.getContractFactory("Scale");

        scale = await Scale.deploy();
        await scale.deployed();

        ScaleTest = await ethers.getContractFactory("ScaleTest",
        {
          libraries: {
            // Scale: scale.address
          }
        });

        // compactMerkleProofTest = await CompactMerkleProofTest.deploy();
        // await compactMerkleProofTest.deployed();

        scaleTest = await ScaleTest.deploy();
        await scaleTest.deployed();
        
        simpleMerkleProof = await SimpleMerkleProof.deploy();
        await simpleMerkleProof.deployed();

        SimpleMerkleProofTest = await ethers.getContractFactory(
            'SimpleMerkleProofTest',
            {
              libraries: {
                // SimpleMerkleProof: simpleMerkleProof.address
              }
            }
          );

        simpleMerkleProofTest = await SimpleMerkleProofTest.deploy()
        await simpleMerkleProofTest.deployed()
    });

    it('ScaleTest', async() => {
        await scaleTest.testDecodeReceiptProof()
    })

    it('ScaleTest decodeVec', async () => {
      await scaleTest.testDecodeU32();
      await scaleTest.testDecodeAccountId();
      await scaleTest.testDecodeAccountId2();
      await scaleTest.testDecodeBalance();
      await scaleTest.testDecodeBalance1();
      await scaleTest.testDecodeBalance2();
      await scaleTest.testDecodeBalance3();
      await scaleTest.testDecodeLockEvents();
      await scaleTest.testDecodeEthereumAddress();
      await scaleTest.testDecodeAuthorities();
      await scaleTest.testDecodeMMRRoot();
      await scaleTest.testDecodeStateRootFromBlockHeader();
      await scaleTest.testDecodeBlockNumberFromBlockHeader();
      await scaleTest.testHackDecodeMMRRootAndDecodeAuthorities();
      
    })

    // it('CompactMerkleProofTest testCompactMerkleProofTest', async () => {
    //     await compactMerkleProofTest.testSimplePairVerifyProof()
    //     await compactMerkleProofTest.testPairVerifyProof()
    //     await compactMerkleProofTest.testPairsVerifyProof()

    //     await compactMerkleProofTest.test_decode_leaf()
    //     await compactMerkleProofTest.test_encode_leaf()
    //     await compactMerkleProofTest.test_decode_branch()
    //     await compactMerkleProofTest.test_encode_branch()
    // })

    it('SimpleMerkleProof testSimpleMerkleProof1', async () => {
        res = await simpleMerkleProofTest.testNonCompactMerkleProof1()
        console.log(res)

        expect(res).that.equal('0x240000000000000080e36a09000000000200000001000000000000000000000000000200000002000000000000ca9a3b00000000020000000300000000030e017b1e76c223d1fa5972b6e3706100bb8ddffb0aeafaf0200822520118a87e00000300000003000e017b1e76c223d1fa5972b6e3706100bb8ddffb0aeafaf0200822520118a87ef0a4b9550b000000000000000000000000000300000003020d584a4cbbfd9a4878d816512894e65918e54fae13df39a6f520fc90caea2fb00e017b1e76c223d1fa5972b6e3706100bb8ddffb0aeafaf0200822520118a87ef0a4b9550b00000000000000000000000000030000000e060017640700000000000000000000000000000300000003045a9ae1e0730536617c67ca727de00d4d197eb6afa03ac0b4ecaa097eb87813d6c005d9010000000000000000000000000000030000000000c0769f0b00000000000000')
    })

    it('SimpleMerkleProof testSimpleMerkleProof2', async () => {
        res = await simpleMerkleProofTest.testNonCompactMerkleProof2()
        console.log(res)

        expect(res).that.equal('0x102403d43593c715fdd31c61141abd04a99fd6822c8558854ccde39a5684e7a56da27ddac17f958d2ee523a2206206994597c13d831ec700000e5fa31c00000000000000000000002404d43593c715fdd31c61141abd04a99fd6822c8558854ccde39a5684e7a56da27ddac17f958d2ee523a2206206994597c13d831ec70100e40b5402000000000000000000000024038eaf04151687736326c9fea17e25fc5287613693c912909cb226aa4794f26a48b20bd5d04be54f870d5c0d3ca85d82b34b8364050000d0b72b6a000000000000000000000024048eaf04151687736326c9fea17e25fc5287613693c912909cb226aa4794f26a48b20bd5d04be54f870d5c0d3ca85d82b34b8364050100c817a8040000000000000000000000')
    })

    it('SimpleMerkleProof testGetEvents', async () => {
      res = await simpleMerkleProofTest.testGetEvents()
      console.log(res)

      expect(res).that.equal('0x102403d43593c715fdd31c61141abd04a99fd6822c8558854ccde39a5684e7a56da27ddac17f958d2ee523a2206206994597c13d831ec700000e5fa31c00000000000000000000002404d43593c715fdd31c61141abd04a99fd6822c8558854ccde39a5684e7a56da27ddac17f958d2ee523a2206206994597c13d831ec70100e40b5402000000000000000000000024038eaf04151687736326c9fea17e25fc5287613693c912909cb226aa4794f26a48b20bd5d04be54f870d5c0d3ca85d82b34b8364050000d0b72b6a000000000000000000000024048eaf04151687736326c9fea17e25fc5287613693c912909cb226aa4794f26a48b20bd5d04be54f870d5c0d3ca85d82b34b8364050100c817a8040000000000000000000000')
    })

    it('SimpleMerkleProof testGetEvents1', async () => {
      res = await simpleMerkleProofTest.testGetEvents1()
      console.log(res)

      expect(res).that.equal('0x082403d43593c715fdd31c61141abd04a99fd6822c8558854ccde39a5684e7a56da27df39fd6e51aad88f6f4ce6ab8827279cfffb9226600000e5fa31c00000000000000000000002404d43593c715fdd31c61141abd04a99fd6822c8558854ccde39a5684e7a56da27df39fd6e51aad88f6f4ce6ab8827279cfffb922660100c817a8040000000000000000000000')
    })
});
