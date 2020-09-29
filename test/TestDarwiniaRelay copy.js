
const MMRWrapper = artifacts.require('MMRWrapper');
const DarwiniaRelay = artifacts.require("DarwiniaRelay");
const MMR = artifacts.require('MMR');
const Blake2b = artifacts.require("Blake2b");


contract('DarwiniaRelay1', (accounts) => {
  let mmrLib;
  let blake2b;
  let res;
  let darwiniaRelay;
  before(async () => {
    // blake2b = await Blake2b.new();
    // console.log('blake2b:', blake2b)
    // await MMR.link('Blake2b', blake2b.address);

    mmrLib = await MMR.new();
    // console.log('mmrLib:', mmrLib)
    // await MMR.link('Blake2b', blake2b.address);

    // darwiniaRelay = await DarwiniaRelay.deployed();
    // await DarwiniaRelay.link('MMR', mmrLib.address);
    // await DarwiniaRelay.link('Blake2b', blake2b.address);
    
    await MMRWrapper.link('MMR', mmrLib.address);
    // console.log('MMR Tree : 5 |                             31');
    // console.log('           4 |             15                                 30                                    46');
    // console.log('           3 |      7             14                 22                 29                 38                 45');
    // console.log('           2 |   3      6     10       13       18       21        25       28        34        37       41        44       49');
    // console.log('           1 | 1  2   4  5   8  9    11  12   16  17    19  20   23  24    26  27   32  33    35  36   39  40    42  43   47  48    50');
    // console.log('       width | 1  2   3  4   5  6     7   8    9  10    11  12   13  14    15  16   17  18    19  20   21  22    23  24   25  26    27');
  });

  // const aaa = {
  //   root:
  //     '0xa6094754328d473e11ab4aa55e04d39d8e5607f3c66fe97f903c66fee9018ed6',
  //   width: '<BN: e>',
  //   peakBagging:
  //     ['0x0dfa92386d2f697ec7fba09c01a9b6c4df4681951519add7ee6086b27cd2f319',
  //       '0x8fd6b87c0343ba19c5d9b3075a699d8171f72df4105ddd9ae05cba5f434d998f',
  //       '0x176cd98f201d2d9af8a47cca45cac4637cc18f86bccf402934ee554046741fb5'],
  //   siblings:
  //     ['0xea53f4f0625edf727a750b721b124e58e2a73f80606ab47601f4493f6b4ca920',
  //       '0x4ee186d69fe539de9b1360cd91b4397168ad20232445a3085917f0461f54acf2',
  //       '0xf1f173a34ecaf6f0f5187732c3a59ff0026a177c0ebf8ce6bc3f973e70adb88d']
  // }

  describe('inclusionProof()', async () => {
    before(async () => {
      mmr = await MMRWrapper.new();
      const data = [
        '0x34f61bfda344b3fad3c3e38832a91448b3c613b199eb23e5110a635d71c13c65',
        '0x70d641860d40937920de1eae29530cdc956be830f145128ebb2b496f151c1afb',
        '0x12e69454d992b9b1e00ea79a7fa1227c889c84d04b7cd47e37938d6f69ece45d',
        '0x3733bd06905e128d38b9b336207f301133ba1d0a4be8eaaff6810941f0ad3b1a',
        '0x3d7572be1599b488862a1b35051c3ef081ba334d1686f9957dbc2afd52bd2028',
        '0x2a04add3ecc3979741afad967dfedf807e07b136e05f9c670a274334d74892cf'
      ]
      for (let i = 0; i < data.length; i++) {
        await mmr.append(data[i], data[i]);
        mmr.root.call()
      }
    });

    it('MMRMerge', async () => {
      /**
       * ("70d641860d40937920de1eae29530cdc956be830f145128ebb2b496f151c1afb", "3aafcc7fe12cb8fad62c261458f1c19dba0a3756647fa4e8bff6e248883938be")
       */
      darwiniaRelay = await DarwiniaRelay.new();
      let input = Buffer.from('70d641860d40937920de1eae29530cdc956be830f145128ebb2b496f151c1afb3aafcc7fe12cb8fad62c261458f1c19dba0a3756647fa4e8bff6e248883938be', 'hex');
      let ret = await darwiniaRelay.Blake2bHash.call(input);
      console.log(ret)
      // assert.equal(ret, '0xfea52f021bee75845654f1e5e0751cfe81b270cb59624d6c3204eef03db1fab8')
// return
      let index = 2;
      res = await mmr.getMerkleProof(index);
      console.log(`proof(${index})`, res);

      // const isInclusionProof = await mmrLib.inclusionProof.call(res.root, res.width, index, '0x70d641860d40937920de1eae29530cdc956be830f145128ebb2b496f151c1afb', res.peakBagging, res.siblings);
      // assert.equal(isInclusionProof, true)
    });

    // it('should revert when it receives an invalid merkle proof', async () => {
    //   let index = 27;
    //   res = await mmr.getMerkleProof(index);
    //   // Stored value is 0x0000 not 0x0001
    //   const result = await mmrLib.inclusionProof(res.root, res.width, index, '0x0001', res.peakBagging, res.siblings).should.be.rejected;

    // });
  });




  // 5234f61bfda344b3fad3c3e38832a91448b3c613b199eb23e5110a635d71c13c65
  // 523aafcc7fe12cb8fad62c261458f1c19dba0a3756647fa4e8bff6e248883938be
  // 527ddf10d67045173e3a59efafb304495d9a7c84b84f0bc0235470a5345e32535d
  // 52488e9565547fec8bd36911dc805a7ed9f3d8d1eacabe429c67c6456933c8e0a6
  // 526e0c4ab56e0919a7d45867fcd1216e2891e06994699eb838386189e9abda55f1


  // it('should put 10000 DarwiniaRelay in the first account', async () => {
  //   const metaCoinInstance = await DarwiniaRelay.deployed();
  //   const balance = await metaCoinInstance.getBalance.call(accounts[0]);

  //   assert.equal(balance.valueOf(), 10000, "10000 wasn't in the first account");
  // });
  // it('should call a function that depends on a linked library', async () => {
  //   const metaCoinInstance = await DarwiniaRelay.deployed();
  //   const metaCoinBalance = (await metaCoinInstance.getBalance.call(accounts[0])).toNumber();
  //   const metaCoinEthBalance = (await metaCoinInstance.getBalanceInEth.call(accounts[0])).toNumber();

  //   assert.equal(metaCoinEthBalance, 2 * metaCoinBalance, 'Library function returned unexpected function, linkage may be broken');
  // });
  // it('should send coin correctly', async () => {
  //   const metaCoinInstance = await DarwiniaRelay.deployed();

  //   // Setup 2 accounts.
  //   const accountOne = accounts[0];
  //   const accountTwo = accounts[1];

  //   // Get initial balances of first and second account.
  //   const accountOneStartingBalance = (await metaCoinInstance.getBalance.call(accountOne)).toNumber();
  //   const accountTwoStartingBalance = (await metaCoinInstance.getBalance.call(accountTwo)).toNumber();

  //   // Make transaction from first account to second.
  //   const amount = 10;
  //   await metaCoinInstance.sendCoin(accountTwo, amount, { from: accountOne });

  //   // Get balances of first and second account after the transactions.
  //   const accountOneEndingBalance = (await metaCoinInstance.getBalance.call(accountOne)).toNumber();
  //   const accountTwoEndingBalance = (await metaCoinInstance.getBalance.call(accountTwo)).toNumber();


  //   assert.equal(accountOneEndingBalance, accountOneStartingBalance - amount, "Amount wasn't correctly taken from the sender");
  //   assert.equal(accountTwoEndingBalance, accountTwoStartingBalance + amount, "Amount wasn't correctly sent to the receiver");
  // });
});
