const { expect } = require("chai");
const { solidity } = require("ethereum-waffle");
const chai = require("chai");

chai.use(solidity);

var jsonRpcProvider = new ethers.providers.JsonRpcProvider();
  // devnet

  // Locked 123 RING, 20 KTON

  // blocknumber 9314
  // blockhash 0xb821babd95f01467e9ab889e5e03d42030e5db9c7027954223991239c8e0e4ac
  // blockheader 0xb20ea574de7640b8b6f84312c90a40cd123c1be7cc1655edb4713e61f97fd3ae8991eb3811bb17fe224d59847a47ae0bdd2b2663b1e422c3473638227f86dec82818e7d09cdbf8205034542f4a0116aa07ce96efe63cd2255895acd0474e28d7587f1006424142453402000000003f08f80f000000000466726f6e8801673d4723721b48cef07ce4c4208f4ac233734d7e58cc6ab27f8452bc238cb8df0000904d4d5252b5d7c88ac37e4f91f481e642f87d111e4b2a3b7e791697950139000e4eef094705424142450101b82ad773a86ff32162375e8e6bb455043db376439a90dbc530967f3f2d47184a4610bd6e231b4a5256df1d751c05dffa4d3869c74209b9bf0be55548850f1286
  // mmr 0xb5d7c88ac37e4f91f481e642f87d111e4b2a3b7e791697950139000e4eef0947

  // storage_key 0xf8860dda3d08046cf2706b92bf7202eaae7a79191c90e76297e0895605b8b457
  // state_root 0xeb3811bb17fe224d59847a47ae0bdd2b2663b1e422c3473638227f86dec82818
  // rpc state.getReadProof
  // {
  //   at: 0xb821babd95f01467e9ab889e5e03d42030e5db9c7027954223991239c8e0e4ac,
  //   proof: [
  //     0x5f0e7a79191c90e76297e0895605b8b4573d02082403d43593c715fdd31c61141abd04a99fd6822c8558854ccde39a5684e7a56da27df39fd6e51aad88f6f4ce6ab8827279cfffb9226600000e5fa31c00000000000000000000002404d43593c715fdd31c61141abd04a99fd6822c8558854ccde39a5684e7a56da27df39fd6e51aad88f6f4ce6ab8827279cfffb922660100c817a8040000000000000000000000,
  //     0x807fb980b6e1c772a600a844f50a096c8ece7c17ba3897424e9b2c4c628c9dbfbcb67b1180a1cbea221dc71ebd79d899ff50968a589cd5841bdd2bf6ea1eec40e9a02312c88008d8c6bfac6a63ef239d1d263897e322d5f5cff900439d8be2f9ffe536cfc6a780945fd7ca814966d58e83678f656dd4091ea35d8a1264b0555a67a3a27d8a03818038a4dad4200861e593e8d60b8eead8bbe3df94173b1f073eb0049a0371d822808083fe283f390223d4986264faf72bdbc0e147b52d3967876e0a3b90d589564f5480eeeba3be5735ffab390c56824467c3ea8a35bdd3bd267a2dbee0a75013c91d7b80eb96b92133be69af0b427d0457762cee9836003b9b09e9da247907a7b850f79280dbeb12984b545e2760b9cc11bc64c07b5106c5c0504f64e91cdb071081d775f080bd72408dd9809d3ac3875a56e858563a51fd0257d4cefa21486aea4f9ac251a7804144c4c32418317dfe8ac2429fb859dcc924620b2b6dfde736de89331830bf2e8000ad313b9727685624be3c71895bb435eaab6c023ac95938be0381947670d322,
  //     0x9e860dda3d08046cf2706b92bf7202ea120d808d9379a2f152a490b6f4eaf9b3b15dc4fdf5c40db04d1027c096f460f6a8325d80e3c1a4bc53f79d38ece4b23b636d88697deeed63410fc26e85d8baa2d39dde568019e0d8e940b47b8f7e291d08c882bb0ccc4599a1ed5229a9b41403dd57f685c58054fa566867bf20c6cad36d14786d19b415f7d99b4592850593168d7aa78cb448805eebc21f9bf3cb232ed1097ff90a4975f025a5f7d91691639272527c9794e246,
  //     0x80450180cadab1e024b52fa549e97b73e004a41a66934b4cbd2dcdb8d6074412b5e61eaa8042ecc1701d89c0574ab923be5da376c04ea0bb25c5c1e09c068ae1db4703fc0b80ef50809ca9c02fd313cbf878155b3ee608c543784d0aa5e440a50fd4fe3950ae80b11ce23fad848e1f49ec34917483ecf7aff0ade3295988f94a881f3cd491641f
  //   ]
  // }

  // let proofs = api.createType('Vec<proof>', [...proofs])
  // console.log(proofs.toHex())
  // result: 0x1089025f0e7a79191c90e76297e0895605b8b4573d02082403d43593c715fdd31c61141abd04a99fd6822c8558854ccde39a5684e7a56da27df39fd6e51aad88f6f4ce6ab8827279cfffb9226600000e5fa31c00000000000000000000002404d43593c715fdd31c61141abd04a99fd6822c8558854ccde39a5684e7a56da27df39fd6e51aad88f6f4ce6ab8827279cfffb922660100c817a80400000000000000000000003d06807fb980b6e1c772a600a844f50a096c8ece7c17ba3897424e9b2c4c628c9dbfbcb67b1180a1cbea221dc71ebd79d899ff50968a589cd5841bdd2bf6ea1eec40e9a02312c88008d8c6bfac6a63ef239d1d263897e322d5f5cff900439d8be2f9ffe536cfc6a780945fd7ca814966d58e83678f656dd4091ea35d8a1264b0555a67a3a27d8a03818038a4dad4200861e593e8d60b8eead8bbe3df94173b1f073eb0049a0371d822808083fe283f390223d4986264faf72bdbc0e147b52d3967876e0a3b90d589564f5480eeeba3be5735ffab390c56824467c3ea8a35bdd3bd267a2dbee0a75013c91d7b80eb96b92133be69af0b427d0457762cee9836003b9b09e9da247907a7b850f79280dbeb12984b545e2760b9cc11bc64c07b5106c5c0504f64e91cdb071081d775f080bd72408dd9809d3ac3875a56e858563a51fd0257d4cefa21486aea4f9ac251a7804144c4c32418317dfe8ac2429fb859dcc924620b2b6dfde736de89331830bf2e8000ad313b9727685624be3c71895bb435eaab6c023ac95938be0381947670d322dd029e860dda3d08046cf2706b92bf7202ea120d808d9379a2f152a490b6f4eaf9b3b15dc4fdf5c40db04d1027c096f460f6a8325d80e3c1a4bc53f79d38ece4b23b636d88697deeed63410fc26e85d8baa2d39dde568019e0d8e940b47b8f7e291d08c882bb0ccc4599a1ed5229a9b41403dd57f685c58054fa566867bf20c6cad36d14786d19b415f7d99b4592850593168d7aa78cb448805eebc21f9bf3cb232ed1097ff90a4975f025a5f7d91691639272527c9794e2461d0280450180cadab1e024b52fa549e97b73e004a41a66934b4cbd2dcdb8d6074412b5e61eaa8042ecc1701d89c0574ab923be5da376c04ea0bb25c5c1e09c068ae1db4703fc0b80ef50809ca9c02fd313cbf878155b3ee608c543784d0aa5e440a50fd4fe3950ae80b11ce23fad848e1f49ec34917483ecf7aff0ade3295988f94a881f3cd491641f

  // blocknumber 9315
  // mmr 0x7f175625e6e00b1504c2ae1ec4669257cbadc50193fe73cb3e7a9abc69ebe090

describe.skip('Relay', () => {
  let mmrLib;
  let relay;
  let blake2b;
  let res;
  let darwiniaRelay;
  let accounts;

  const waitNBlocks = async n => {
    await Promise.all(
      [...Array(n).keys()].map(async i => {
        return await jsonRpcProvider.send('evm_mine', [])
      }   
      )
    );
  };

  const waitNTime =  n => {
     jsonRpcProvider.send('evm_increaseTime', [n])
  };

  let relayConstructor = {};

  const proof = {
    root: '0xe1fe85d768c17641379ef6dfdf50bdcabf6dd83ec325506dc82bf3ff653550dc',
    MMRIndex: 11309,
    blockNumber: 9314,
    blockHeader: '0xb20ea574de7640b8b6f84312c90a40cd123c1be7cc1655edb4713e61f97fd3ae8991eb3811bb17fe224d59847a47ae0bdd2b2663b1e422c3473638227f86dec82818e7d09cdbf8205034542f4a0116aa07ce96efe63cd2255895acd0474e28d7587f1006424142453402000000003f08f80f000000000466726f6e8801673d4723721b48cef07ce4c4208f4ac233734d7e58cc6ab27f8452bc238cb8df0000904d4d5252b5d7c88ac37e4f91f481e642f87d111e4b2a3b7e791697950139000e4eef094705424142450101b82ad773a86ff32162375e8e6bb455043db376439a90dbc530967f3f2d47184a4610bd6e231b4a5256df1d751c05dffa4d3869c74209b9bf0be55548850f1286',
    siblings: [
      '0x84632d50d72a1f57a17c7c146ff5b8312dc2bb1a816c54a5fdeb88eaf49e4aaa', 
      '0x12a555f1cd033f0b245715e56ba8d0b08e127cb49fc0a7aa5a0ee7a02f937fd5', 
      '0xdbe301b15d93fa0954d364fe246a0569c9c8fdcd59e057730db78c4c6306af4e', 
      '0x397e09fef9a8debe96d506924c675f3388a43306b2ef35a2bc7c3523d2a2cd02', 
      '0x6417c9e10ab9182e7f0905fe654741322b3a06b29cd8f156653e02ac727d805a', 
      '0x90c457a898830fff9c2d1888a9fbd9e9d6cf0992b483ec4da6763d83e9932e11', 
      '0x583034854f823b781cd5d4e81b195d30e6515f0f951c8d45eefc4ff25f7db0bc', 
      '0x4da01f2f4f1e057c1dabc187b8dffdfac1d77b171c252b3e719b9df9123e0e39', 
      '0xce0ef0402153f498c058b136f6d6059691f096713baddd028b9f98371ff43171', 
      '0x06da5271cd0e93becabbf662240934d84657ea5c1023cdd3c02773486e6f8b8d', 
      '0x705f11146a3cb90288827e1e23150aee8b89fc06c3dbc9360e2b8b45d121a5c5'
    ],
    peaks: [
      '0xab8bfa22aa826d1fba75fef2d6697942c3b6da1aa0c1b8a8ac3f0ff4e2c768ac',
      '0x3a8cfe61f1a38facf433a0ac89ecfd3556bad4ed4eeab3cb8a628eff72f67236',
      '0x9e5868fbe37c4a08230b4ef3eff56107a8c96171f8d3d72d152bbcb5fda90bc7'
    ],
    proofstr: '0x1089025f0e7a79191c90e76297e0895605b8b4573d02082403d43593c715fdd31c61141abd04a99fd6822c8558854ccde39a5684e7a56da27df39fd6e51aad88f6f4ce6ab8827279cfffb9226600000e5fa31c00000000000000000000002404d43593c715fdd31c61141abd04a99fd6822c8558854ccde39a5684e7a56da27df39fd6e51aad88f6f4ce6ab8827279cfffb922660100c817a80400000000000000000000003d06807fb980b6e1c772a600a844f50a096c8ece7c17ba3897424e9b2c4c628c9dbfbcb67b1180a1cbea221dc71ebd79d899ff50968a589cd5841bdd2bf6ea1eec40e9a02312c88008d8c6bfac6a63ef239d1d263897e322d5f5cff900439d8be2f9ffe536cfc6a780945fd7ca814966d58e83678f656dd4091ea35d8a1264b0555a67a3a27d8a03818038a4dad4200861e593e8d60b8eead8bbe3df94173b1f073eb0049a0371d822808083fe283f390223d4986264faf72bdbc0e147b52d3967876e0a3b90d589564f5480eeeba3be5735ffab390c56824467c3ea8a35bdd3bd267a2dbee0a75013c91d7b80eb96b92133be69af0b427d0457762cee9836003b9b09e9da247907a7b850f79280dbeb12984b545e2760b9cc11bc64c07b5106c5c0504f64e91cdb071081d775f080bd72408dd9809d3ac3875a56e858563a51fd0257d4cefa21486aea4f9ac251a7804144c4c32418317dfe8ac2429fb859dcc924620b2b6dfde736de89331830bf2e8000ad313b9727685624be3c71895bb435eaab6c023ac95938be0381947670d322dd029e860dda3d08046cf2706b92bf7202ea120d808d9379a2f152a490b6f4eaf9b3b15dc4fdf5c40db04d1027c096f460f6a8325d80e3c1a4bc53f79d38ece4b23b636d88697deeed63410fc26e85d8baa2d39dde568019e0d8e940b47b8f7e291d08c882bb0ccc4599a1ed5229a9b41403dd57f685c58054fa566867bf20c6cad36d14786d19b415f7d99b4592850593168d7aa78cb448805eebc21f9bf3cb232ed1097ff90a4975f025a5f7d91691639272527c9794e2461d0280450180cadab1e024b52fa549e97b73e004a41a66934b4cbd2dcdb8d6074412b5e61eaa8042ecc1701d89c0574ab923be5da376c04ea0bb25c5c1e09c068ae1db4703fc0b80ef50809ca9c02fd313cbf878155b3ee608c543784d0aa5e440a50fd4fe3950ae80b11ce23fad848e1f49ec34917483ecf7aff0ade3295988f94a881f3cd491641f',
    storageKey: '0xf8860dda3d08046cf2706b92bf7202eaae7a79191c90e76297e0895605b8b457'
  };

  const address = {
    relayLogic: '0x83bCf76C6e96A3AA50Ded5F1298917614CcDb182',
    relayProxy: '0xE4A2892599Ad9527D76Ce6E26F93620FA7396D85',

    tokenIssuingLogic: '0xc1f804012Ffb67426EB308274E905CFcC7Cc7B17',
    tokenIssuingProxy: '0x214c2B7E9D20b6BeB9F5cE503Fd010Bc716a9AD2',
  }

  before(async () => {
    // const MMR = await ethers.getContractFactory("MMR");
    // const Scale = await ethers.getContractFactory("Scale");
    // const SimpleMerkleProof = await ethers.getContractFactory("SimpleMerkleProof");

    const [owner, addr1, addr2] = await ethers.getSigners();
    accounts = await ethers.getSigners();

    // all test accounts
    for (const account of accounts) {
      console.log(account.address);
    }

    const TokenIssuing = await ethers.getContractFactory("TokenIssuing", {
      libraries: {
        // Scale: scale.address,
      }
    });

    Relay = await ethers.getContractFactory(
      'Relay',
      {
        libraries: {
          // MMR: mmrLib.address,
          // SimpleMerkleProof: simpleMerkleProof.address,
          // Scale: scale.address
        }
      }
    );

    // uint32 _index,
    // bytes32 _genesisMMRRoot,
    // address[] memory _relayers,
    // uint32 _nonce,
    // uint8 _threshold,
    // bytes memory _prefix

    relayConstructor = [
      11309,
      '0xe1fe85d768c17641379ef6dfdf50bdcabf6dd83ec325506dc82bf3ff653550dc',
      [
        // '0x6aA70f55E5D770898Dd45aa1b7078b8A80AAbD6C'
        await owner.getAddress(),
        // await addr1.getAddress(),
        // await addr2.getAddress(),
      ],
      0,
      60,
      "0x43726162"
      // "0x50616e676f6c696e"
    ];
    
    relay = await Relay.attach(address.relayProxy);

    const issuingConstructor = [
      "0x0000000000000000000000000000000000000000",
      relay.address,
      "0xf8860dda3d08046cf2706b92bf7202eaae7a79191c90e76297e0895605b8b457"
    ]

    issuing = await TokenIssuing.attach(address.tokenIssuingProxy);
  });

  describe('Call', async () => {
    before(async () => {
      
    });

    it('getMMRRoot', async () => {
      let result = await relay.getMMRRoot(11309);
      expect(result).that.equal('0xe1fe85d768c17641379ef6dfdf50bdcabf6dd83ec325506dc82bf3ff653550dc');
    });

    it('checkNetworkPrefix', async () => {
      let result = await relay.checkNetworkPrefix(0x43726162);
      expect(result).that.equal(true);
    });

    it('verifyBlockProof', async () => {
      let result = await relay.verifyBlockProof(
        proof.root,
        proof.MMRIndex,
        proof.blockNumber,
        proof.blockHeader,
        proof.peaks,
        proof.siblings,

      );
      expect(result).that.equal(true);
    });


    it('verifyRootAndDecodeReceipt', async () => {
      let result = await relay.verifyRootAndDecodeReceipt(
        proof.root,
        proof.MMRIndex,
        proof.blockNumber,
        proof.blockHeader,
        proof.peaks,
        proof.siblings,
        proof.proofstr,
        proof.storageKey
      );
      expect(result).that.equal('0x082403d43593c715fdd31c61141abd04a99fd6822c8558854ccde39a5684e7a56da27df39fd6e51aad88f6f4ce6ab8827279cfffb9226600000e5fa31c00000000000000000000002404d43593c715fdd31c61141abd04a99fd6822c8558854ccde39a5684e7a56da27df39fd6e51aad88f6f4ce6ab8827279cfffb922660100c817a8040000000000000000000000');
    });
  });

  describe("Tx", async () => {
    it('resetNetworkPrefix', async () => {
      // Pangolin 0x50616e676f6c696e
      // Crab 0x43726162
      const res = await relay.resetNetworkPrefix('0x50616e676f6c696e');
      await res.wait();
    });

    it('resetRelayer', async () => {
      const res = await relay.resetRelayer(0, ['0x6aa70f55e5d770898dd45aa1b7078b8a80aabd6c']);
      await res.wait();

      const relayers = await relay.getRelayer();
      assert(relayers, ['0x6aA70f55E5D770898Dd45aa1b7078b8A80AAbD6C'], "test")
      const nonce = await relay.getRelayerNonce();
      expect(nonce).that.equal(0);
    });

    it('updateRelayer', async () => {
      const res = await relay.updateRelayer(
        "0x2050616e676f6c696e00086aa70f55e5d770898dd45aa1b7078b8a80aabd6cb34ca61ce3202315aae32e70f0101d938c0bd13d",
        ["0x7e0555ce6f0c7ce237d51b53ddacde421e7ee6076ab180ae6d31bc0a2a91008906735a86119618620a271fdf008b5328340a7c3f4834ebc99ecfcec495c8b4c01b"],
        "0x129f002b1c0787ea72c31b2dc986e66911fe1b4d6dc16f83a1127f33e5a74c7d",
        {
          gasLimit: 8000000
        }
      );

      await res.wait();
      const relays = await relay.getRelayer();
      console.log(relays);
      // expect(root).that.equal("0xe1fe85d768c17641379ef6dfdf50bdcabf6dd83ec325506dc82bf3ff65355000");
    });

    it('recover', async () => {
       // {prefix: 0x43726162, index: 20000, root: 0x5fe7f977e71dba2ea1a68e21057beebb9be2ac30c6410aa38d4f3fbe41dcffd2}
      //  const msg = "0x96a09466adda89c1e60c252592cdc10e19f85093a87617b57a44392fd377148b";
      //  const bytesMsg = ethers.utils.arrayify(msg)
 
      //  const hash = ethers.utils.keccak256(bytesMsg);
      //  const bytesHash = ethers.utils.arrayify(hash);
 
      //  signatures.push(await owner.signMessage(bytesHash));
      //  signatures.push(await addr1.signMessage(bytesHash));
      //  // signatures.push(await addr2.signMessage(msg));
      //  console.log('signatures:', signatures);
      //  console.log('hash:', hash);
 
       console.log('ethers verifyMessage check: ', ethers.utils.verifyMessage(ethers.utils.arrayify('0x96a09466adda89c1e60c252592cdc10e19f85093a87617b57a44392fd377148b'), ethers.utils.arrayify('0x7e0555ce6f0c7ce237d51b53ddacde421e7ee6076ab180ae6d31bc0a2a91008906735a86119618620a271fdf008b5328340a7c3f4834ebc99ecfcec495c8b4c01b')));
       // signatures.forEach((item, index) => {
       //   expect(ethers.utils.recoverAddress(msg, item)).that.equal([owner, addr1, addr2][index]);
       // })
 
    });

    it('appendRoot', async () => {
      const [owner, addr1, addr2] = await ethers.getSigners();
      const signatures = [];
      
      // {prefix: 0x43726162, index: 20000, root: 0x5fe7f977e71dba2ea1a68e21057beebb9be2ac30c6410aa38d4f3fbe41dcffd2}
      const msg = "0x1043726162823801005fe7f977e71dba2ea1a68e21057beebb9be2ac30c6410aa38d4f3fbe41dcffd2";
      const bytesMsg = ethers.utils.arrayify(msg)

      const hash = ethers.utils.keccak256(bytesMsg);
      const bytesHash = ethers.utils.arrayify(hash);

      signatures.push(await owner.signMessage(bytesHash));
      signatures.push(await addr1.signMessage(bytesHash));
      // signatures.push(await addr2.signMessage(msg));
      console.log('signatures:', signatures);
      console.log('hash:', hash);

      console.log('ethers verifyMessage check: ', ethers.utils.verifyMessage(bytesHash, signatures[0]));
      // signatures.forEach((item, index) => {
      //   expect(ethers.utils.recoverAddress(msg, item)).that.equal([owner, addr1, addr2][index]);
      // })

      // const appendRoot = await relay.appendRoot(msg, signatures, {
      //   gasLimit: 9500000
      // });
      // await appendRoot.wait();

      // const root = await relay.getMMRRoot(20000);
      // expect(root).that.equal("0x5fe7f977e71dba2ea1a68e21057beebb9be2ac30c6410aa38d4f3fbe41dcffd2");
    });


    it('verifyProof', async () => {
      let result = await issuing.verifyProof(
        proof.root,
        proof.MMRIndex,
        proof.blockNumber,
        proof.blockHeader,
        proof.peaks,
        proof.siblings,
        proof.proofstr
      , {
        gasLimit: 8000000
      });
      rsp = await result.wait();

      // console.log("result:", rsp);

      // gasUsed: 486694
      console.log('gasUsed:', rsp.gasUsed.toString());
      console.log(rsp.events)
      // rsp.events.forEach(event => {
      //   console.log('event:', event.eventSignature);
      //   console.log('data:', JSON.stringify(event.decode(event.data), null, 2));
      // });
     
      let event0 = rsp.events[0];
      expect(event0.eventSignature).that.equal('MintRingEvent(address,uint256,bytes32)');
      expect(event0.decode(event0.data)[0]).that.equal('0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266');
      expect(event0.decode(event0.data)[1].toString()).that.equal('123000000000000000000');
      expect(event0.decode(event0.data)[2]).that.equal('0xd43593c715fdd31c61141abd04a99fd6822c8558854ccde39a5684e7a56da27d');

      let event1 = rsp.events[1];
      expect(event1.eventSignature).that.equal('MintKtonEvent(address,uint256,bytes32)');
      expect(event1.decode(event1.data)[0]).that.equal('0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266');
      expect(event1.decode(event1.data)[1].toString()).that.equal('20000000000000000000');
      expect(event1.decode(event1.data)[2]).that.equal('0xd43593c715fdd31c61141abd04a99fd6822c8558854ccde39a5684e7a56da27d');
    });

    it('Repeated verification of the same block will be reverted', async () => {
      expect(issuing.verifyProof(
        proof.root,
        proof.MMRIndex,
        proof.blockNumber,
        proof.blockHeader,
        proof.peaks,
        proof.siblings,
        proof.proofstr
      , {
        gasLimit: 10000000
      })).be.reverted;
    });

    it('resetRoot', async () => {
      const res = await relay.resetRoot(2000, "0xe1fe85d768c17641379ef6dfdf50bdcabf6dd83ec325506dc82bf3ff65355000");
      await res.wait();
      const root = await relay.getMMRRoot(2000);
      expect(root).that.equal("0xe1fe85d768c17641379ef6dfdf50bdcabf6dd83ec325506dc82bf3ff65355000");
    });

  })
});
