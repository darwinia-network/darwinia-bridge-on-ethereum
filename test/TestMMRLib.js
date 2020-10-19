const MMRWrapper = artifacts.require('MMRWrapper');
const MMR = artifacts.require('MMR');
const chai = require('chai');
const blake = require('blakejs');
chai.use(require('chai-bn')(web3.utils.BN));
chai.use(require('chai-as-promised'));
chai.should();

const leafHashs = [
  '0x34f61bfda344b3fad3c3e38832a91448b3c613b199eb23e5110a635d71c13c65',
  '0x70d641860d40937920de1eae29530cdc956be830f145128ebb2b496f151c1afb',
  '0x12e69454d992b9b1e00ea79a7fa1227c889c84d04b7cd47e37938d6f69ece45d',
  '0x3733bd06905e128d38b9b336207f301133ba1d0a4be8eaaff6810941f0ad3b1a',
  '0x3d7572be1599b488862a1b35051c3ef081ba334d1686f9957dbc2afd52bd2028',
  '0x2a04add3ecc3979741afad967dfedf807e07b136e05f9c670a274334d74892cf',
  "0xc58e247ea35c51586de2ea40ac6daf90eac7ac7b2f5c88bbc7829280db7890f1"
]

const rootList = [
  "0x34f61bfda344b3fad3c3e38832a91448b3c613b199eb23e5110a635d71c13c65",
  "0x3aafcc7fe12cb8fad62c261458f1c19dba0a3756647fa4e8bff6e248883938be",
  "0x7ddf10d67045173e3a59efafb304495d9a7c84b84f0bc0235470a5345e32535d",
  "0x488e9565547fec8bd36911dc805a7ed9f3d8d1eacabe429c67c6456933c8e0a6",
  "0x6e0c4ab56e0919a7d45867fcd1216e2891e06994699eb838386189e9abda55f1",
  "0x293b49420345b185a1180e165c76f76d8cc28fe46c1f6eb4a96959253b571ccd",
  "0x2dee5b87a481a9105cb4b2db212a1d8031d65e9e6e68dc5859bef5e0fdd934b2"
]

/**
 * Merkle Mountain Range Tree
 * MMR
 */
contract('MerkleMountainRange', async () => {
  let mmrLib;
  let res;
  before(async () => {
    mmrLib = await MMR.new();
    await MMRWrapper.link('MMR', mmrLib.address);
    console.log('MMR Tree : 5 |                             31');
    console.log('           4 |             15                                 30                                    46');
    console.log('           3 |      7             14                 22                 29                 38                 45');
    console.log('           2 |   3      6     10       13       18       21        25       28        34        37       41        44       49');
    console.log('           1 | 1  2   4  5   8  9    11  12   16  17    19  20   23  24    26  27   32  33    35  36   39  40    42  43   47  48    50');
    console.log('       width | 1  2   3  4   5  6     7   8    9  10    11  12   13  14    15  16   17  18    19  20   21  22    23  24   25  26    27');
  });
  context('Test pure functions', async () => {
    describe('getChildren()', async () => {
      it('should return 1,2 as children for 3', async () => {
        res = await mmrLib.getChildren(3);
        res.left.should.be.a.bignumber.that.equals('1');
        res.right.should.be.a.bignumber.that.equals('2');
      });
      it('should return 3,6 as children for 7', async () => {
        res = await mmrLib.getChildren(7);
        res.left.should.be.a.bignumber.that.equals('3');
        res.right.should.be.a.bignumber.that.equals('6');
      });
      it('should return 22,29 as children for 30', async () => {
        res = await mmrLib.getChildren(30);
        res.left.should.be.a.bignumber.that.equals('22');
        res.right.should.be.a.bignumber.that.equals('29');
      });
      it('should be reverted for leaves like 1,2,4', async () => {
        try {
          const aa = await mmrLib.getChildren(1)
          console.log(aa)
        } catch (error) {
          console.log(1, error)
        }
        await mmrLib.getChildren(1).should.be.rejected;
        await mmrLib.getChildren(2).should.be.rejected;
        await mmrLib.getChildren(4).should.be.rejected;
      });
    });
    describe('getPeakIndexes()', async () => {
      it('should return [15, 22, 25] for a mmr which width is 14', async () => {
        res = await mmrLib.getPeakIndexes(14);
        res[0].should.be.a.bignumber.that.equals('15');
        res[1].should.be.a.bignumber.that.equals('22');
        res[2].should.be.a.bignumber.that.equals('25');
      });
      it('should return [3] for a mmr which width is 2', async () => {
        res = await mmrLib.getPeakIndexes(2);
        res[0].should.be.a.bignumber.that.equals('3');
      });
      it('should return [31, 46, 49, 50] for a mmr which width is 27', async () => {
        res = await mmrLib.getPeakIndexes(27);
        res[0].should.be.a.bignumber.that.equals('31');
        res[1].should.be.a.bignumber.that.equals('46');
        res[2].should.be.a.bignumber.that.equals('49');
        res[3].should.be.a.bignumber.that.equals('50');
      });
    });
    // describe('hashBranch()', async () => {
    //   it('should return blake2b(m|left,right)', async () => {

    //     // let left = web3.utils.soliditySha3(1, '0x00'); // At 1
    //     // let right = web3.utils.soliditySha3(2, '0x00'); // At 2
    //     let left = '0x34f61bfda344b3fad3c3e38832a91448b3c613b199eb23e5110a635d71c13c65';
    //     let right = '0x70d641860d40937920de1eae29530cdc956be830f145128ebb2b496f151c1afb';
    //     res = await mmrLib.hashBranch(3, left, right);
    //     res.should.equal(blake.blake2bHex(Buffer.from('70d641860d40937920de1eae29530cdc956be830f145128ebb2b496f151c1afb70d641860d40937920de1eae29530cdc956be830f145128ebb2b496f151c1afb', 'hex'), null, 32));
    //   });
    // });
    // describe('hashLeaf()', async () => {
    //   it('should return sha3(m|data)', async () => {
    //     let dataHash = web3.utils.soliditySha3('0xa300');
    //     let leaf = web3.utils.soliditySha3(23, dataHash); // At 1
    //     res = await mmrLib.hashLeaf(23, dataHash);
    //     res.should.equal(leaf);
    //   });
    // });
    describe('mountainHeight()', async () => {
      it('should return 3 for its highest peak when the size is less than 12 and greater than 4', async () => {
        for (let i = 5; i < 12; i++) {
          (await mmrLib.mountainHeight(i)).should.be.a.bignumber.that.equals('3');
        }
      });
      it('should return 4 for its highest peak when the size is less than 27 and greater than 11', async () => {
        for (let i = 12; i < 27; i++) {
          (await mmrLib.mountainHeight(i)).should.be.a.bignumber.that.equals('4');
        }
      });
    });
    describe('heightAt()', async () => {
      let firstFloor = [1, 2, 4, 5, 8, 9, 11, 12, 16, 17, 19, 20, 23, 24, 26, 27, 32, 33, 35, 36, 39, 40, 42, 43, 47, 48];
      let secondFloor = [3, 6, 10, 13, 18, 21, 25, 28, 34, 37, 41, 44, 49];
      let thirdFloor = [7, 14, 22, 29, 38, 45];
      let fourthFloor = [15, 30, 46];
      let fifthFloor = [31];
      it('should return 1 as the height of the index which belongs to the first floor', async () => {
        for (let index of firstFloor) {
          (await mmrLib.heightAt(index)).should.be.a.bignumber.that.equals('1');
        }
      });
      it('should return 2 as the height of the index which belongs to the second floor', async () => {
        for (let index of secondFloor) {
          (await mmrLib.heightAt(index)).should.be.a.bignumber.that.equals('2');
        }
      });
      it('should return 3 as the height of the index which belongs to the third floor', async () => {
        for (let index of thirdFloor) {
          (await mmrLib.heightAt(index)).should.be.a.bignumber.that.equals('3');
        }
      });
      it('should return 4 as the height of the index which belongs to the fourth floor', async () => {
        for (let index of fourthFloor) {
          (await mmrLib.heightAt(index)).should.be.a.bignumber.that.equals('4');
        }
      });
      it('should return 5 as the height of the index which belongs to the fifth floor', async () => {
        for (let index of fifthFloor) {
          (await mmrLib.heightAt(index)).should.be.a.bignumber.that.equals('5');
        }
      });
    });
  });

  context.skip('Gas usage test', async () => {
    let count = leafHashs.length
    it(`inserted ${count} items to the tree`, async () => {
      let mmr = await MMRWrapper.new();
      let total = 0;
      let res;
      for (let i = 0; i < count; i++) {
        res = await mmr.append('0x00', leafHashs[i]);
        total += res.receipt.gasUsed;
        console.log(`Append index:${i} used ${res.receipt.gasUsed} gas`)
      }
      console.log(`Used ${total / count} on average to append ${count} items`);
    });
  });

  context('Append items to an on-chain MMR tree', async () => {
    describe('inclusionProof()', async () => {
      let mmr;
      before(async () => {
        mmr = await MMRWrapper.new();
      });
      it('should return pass true when it receives a valid merkle proof', async () => {
        // 验证1033在1037的mmr_root下:
        // 1. 准备好数据
        // mmr_proof = darwinia.get_mmr_proof(1033, 1036)
        // peaks = get_all_peaks_from(mmr_proof)
        // slibings = 1033's hash + get_all_slibings_from(mmr_proof)
        // 2. 调用合约的验证函数验证
        // mmr_contract.inclusionProof(mmr_root, 1036+1, 1033+1, 1033's hash, peaks, slibings)

        // await mmrLib.inclusionProof(
        //   '0xa9c501f12a7c30c335a79f973860fc4dd6255ed2ecc8e8da83f4b089242d2700',
        //   1037,
        //   1034,
        //   '0x00',
        //   '0xba574b186b85e24d4463fdd798a27e69d2a7c74f20454064af9b761b4dae1477',
        //   [
        //     '0xf444ad927fa5b4cb116c47b9b98ca50685149ee661d560c9eca816d18be0fb49',
        //     '0x93101ab9177cd5e690d1193ae0fe0e3670bcebecb570759e25827528804c8cda',
        //     '0x9de7a78805e4185b60d3201f4dab68ae1b28011e090591d093e1b5739f7c13f5',
        //     '0xd79f1f4cddc867a8a9f82d272f1d9d8dc1cea213b8cfe574a5d67e190202bbd9'
        //   ],
        //   [
        //     '0xb4df4e2cbbd4ca595c35ff6a3162056d9812eeae50537cf6d679d74fc581d4bb',
        //     '0x8179c80c5eb8912721e0cf77f1233531b4e3e5a992ee951dcea21f1029b8d3cd'
        //   ]
        // ).should.eventually.equal(true);
      })

      it('should return pass true when it receives a valid merkle proof (1-7)', async () => {
        // bytes32 root,
        // uint256 width,
        // uint256 index,
        // bytes memory value,
        // bytes32[] memory peaks,
        // bytes32[] memory siblings
        (await mmrLib.verifyProof(
          '0x2dee5b87a481a9105cb4b2db212a1d8031d65e9e6e68dc5859bef5e0fdd934b2',
          7,
          1,
          '0x00',
          '0x34f61bfda344b3fad3c3e38832a91448b3c613b199eb23e5110a635d71c13c65',
          [
            '0x488e9565547fec8bd36911dc805a7ed9f3d8d1eacabe429c67c6456933c8e0a6',
            '0x9197278f146f85de21a738c806c24e0b18b266d45fc33cbb922e9534ab26dacd'
          ],
          [
            '0x70d641860d40937920de1eae29530cdc956be830f145128ebb2b496f151c1afb',
            '0xbc3653f301c613152cf85bc3af425692b456847ff6371e5c23e4d74eb6f95ff3'
          ]
        )).should.be.a.bignumber.that.equals('0');
      })

      it('should return pass true when it receives a valid merkle proof (7000-10000)', async () => {
        // bytes32 root,
        // uint256 width,
        // uint256 index,
        // bytes memory value,
        // bytes32[] memory peaks,
        // bytes32[] memory siblings
        (await mmrLib.verifyProof(
          '0x04c012d3f663112b7990c75f5aa85686a988b4e921c9f228755eb0494bd62f56',
          10000,
          13990,
          '0x00',
          '0xdeae4db467aa052af33cb3a4ad5aa1069d1c8d974bd18416381668b53962cebb',
          [
            '0x30f3e4a3960d9ead43c1ea633525f093f3df91579ee4c05e6d9e1561eeb893a5',
            '0x8f7da3cfe0c556f25e21c183709a0cee0c705584482c2971d63d54bd1729cd7e'
          ],
          [
            '0x7e97f120b837fc887b63dd3015282a81e24982f1c5df7fadb12a478571d8fce2', 
            '0xffc09ec5cb061d801c5f383985c5972a6d61fe9de188d3e39d371f669212c1b2', 
            '0x119d189805003a3e220ff8cee8cbfa57f1bed60813167a37e116954e56248cbc', 
            '0x7e1da34ada17f6c701542c81ace090b59efe294838a24a4809572e957fa0aaa6', 
            '0xe554ef2847b6cf629100f429ae72f67ec6b8286622d5773fc83ad5dc52a00455', 
            '0x246417bf2d87a2c52e5d23f9b1b77526ba35638876ba753905bdd82949d8b88e', 
            '0xe19ce8884ba884b8c9b253b411160f3c70ac19e64c8de63693af40bc0f557016', 
            '0xca5a68547c628431df0df8c5988c559b26506fb064d3e785a2a55967891bbc88', 
            '0xd23a47a77e4489f4f9404055698c80b78e6852b478c917361fd072e90dc782bb', 
            '0x9df14d647154a18947b5840b7973f8c464fabe820e511f716f0bf928680be58a', 
            '0x1bc39b3c5738795825336b5449025f3b20e5c665dcbb6b9e8a1d21354a3940f8', 
            '0x42f19c560c737eb06e7a9fa7b027e07a78275517422d5a7bc8bf0dfac28899fd', 
            '0xfc7c8a2e0780489f9487f329ddb967865ca00be6a1b2ce292197b349f2319da5'
          ]
        )).should.be.a.bignumber.that.equals('0');
      })


      it('should return pass true when it receives a valid merkle proof (5-7)', async () => {
        // bytes32 root,
        // uint256 width,
        // uint256 index,
        // bytes memory value,
        // bytes32[] memory peaks,
        // bytes32[] memory siblings
        (await mmrLib.verifyProof(
          '0x2dee5b87a481a9105cb4b2db212a1d8031d65e9e6e68dc5859bef5e0fdd934b2',
          7,
          8,
          '0x00',
          '0x3d7572be1599b488862a1b35051c3ef081ba334d1686f9957dbc2afd52bd2028',
          [
            '0x488e9565547fec8bd36911dc805a7ed9f3d8d1eacabe429c67c6456933c8e0a6',
            '0x50371e8a99e6c118a0719d96185b92c8943db374143f0d8f2df55d4571316cbe',
            '0xc58e247ea35c51586de2ea40ac6daf90eac7ac7b2f5c88bbc7829280db7890f1'
          ],
          [
            '0x2a04add3ecc3979741afad967dfedf807e07b136e05f9c670a274334d74892cf', 
          ]
        )).should.be.a.bignumber.that.equals('0');
      })
     
    });
  });

  describe.skip('append()', async () => {
    it('should increase the size to 15 when 8 items are added', async () => {
      let mmr = await MMRWrapper.new();
      for (let i = 0; i < 8; i++) {
        await mmr.append('0x0000', '0x0000');
      }
      res = await mmr.getMerkleProof(i + 1);
      console.log(res)
        (await mmr.getSize()).should.be.a.bignumber.that.equals('15');
    });
    it('should increase the size to 50 when 27 items are added', async () => {
      let mmr = await MMRWrapper.new();
      for (let i = 0; i < 27; i++) {
        await mmr.append('0x0000', '0x0000');
      }
      (await mmr.getSize()).should.be.a.bignumber.that.equals('50');
    });
  });

  describe.skip('getMerkleProof() inclusionProof()', async () => {
    let mmr;
    before(async () => {
      mmr = await MMRWrapper.new();
      for (let i = 0; i < leafHashs.length; i++) {
        await mmr.append(`0x000${i}`, leafHashs[i]);
        const root = await mmr.getRoot();

        console.log(`append ${leafHashs[i]}, root: ${root}`)
      }
    });
    it('should return pass true when it receives a valid merkle proof', async () => {
      res = await mmr.getMerkleProof(3);
      console.log(`index: ${index} proof`, res)
      // for (let index = 1; index < leafHashs.length; index++) {
      //   res = await mmr.getMerkleProof(index);
      //   console.log(`index: ${index} proof`, res)
      //   // await mmrLib.inclusionProof(res.root, res.width, index, '0x00', leafHashs[index - 1], res.peakBagging, res.siblings).should.eventually.equal(true);
      // }
    })
    it('should return 0x2f... for its root value', async () => {
      res.root.should.equal('0x2dee5b87a481a9105cb4b2db212a1d8031d65e9e6e68dc5859bef5e0fdd934b2');
    });
    it('should return 7 for its width', async () => {
      res.width.should.be.a.bignumber.that.equals('7');
    });
    it('should return [0xfdb6.., 0x3fd8.., 0x2fce..] for its peaks', async () => {
      res.peakBagging[0].should.equal('0x488e9565547fec8bd36911dc805a7ed9f3d8d1eacabe429c67c6456933c8e0a6');
      res.peakBagging[1].should.equal('0x50371e8a99e6c118a0719d96185b92c8943db374143f0d8f2df55d4571316cbe');
      res.peakBagging[2].should.equal('0xc58e247ea35c51586de2ea40ac6daf90eac7ac7b2f5c88bbc7829280db7890f1');
    });
    it('should return hash value at the index 9 as its sibling', async () => {
      res.siblings[0].should.equal('0x70d641860d40937920de1eae29530cdc956be830f145128ebb2b496f151c1afb');
      res.siblings[1].should.equal('0xbc3653f301c613152cf85bc3af425692b456847ff6371e5c23e4d74eb6f95ff3');
    });

    it('should revert when it receives an invalid merkle proof', async () => {
      let index = 1;
      res = await mmr.getMerkleProof(index);
      await mmrLib.inclusionProof(res.root, res.width, index, '0x00', leafHashs[index], res.peakBagging, res.siblings).should.be.rejected;
    })
  });
});
