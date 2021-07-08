// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.7.0;
import "./ds-test/test.sol";

import "./Input.sol";
import "./Scale.sol";
import { ScaleStruct } from "./Scale.struct.sol";
import "hardhat/console.sol";

pragma experimental ABIEncoderV2;

contract ScaleTest is DSTest {
    using Input for Input.Data;

    function setUp() public {}

    function testFail_basic_sanity() public {
        assertTrue(false);
    }

    function test_basic_sanity() public {
        assertTrue(true);
    }

    function testDecodeU32() public {
        uint32 index = Scale.decodeU32(Input.from(hex"02000100"));
        assertEq(uint256(index), 16384);

        index = Scale.decodeU32(Input.from(hex"fdff"));
        assertEq(uint256(index), 16383);

        index = Scale.decodeU32(Input.from(hex"feffffff"));
        assertEq(uint256(index), 1073741823);
    }

    function testDecodeReceiptProof() public {
        // {
        //     at: 0x1408715bbfa970e0a698a495c5f51ce88a27c23efa20fd66550777e388033836,
        //     proof: [
        //         0x5f00d41e5e16056765bc8461851072c9d735031400000000000000608796090000000002000000010000001702e096b1496b056d5e1ee8e9ef272ff74f05e50884a52318adde16b3b5c6655c3f22aaaaf10536d812c7e097f59e7b769e24341830d42d4551a5c0369a588e4e4000e40b54020000000000000000000000000001000000200600c4192700000000000000000000000000000100000017040f99850f381fdfb5b965617619e59ed082a4515c22967c9c1c94621969362aba0071c6090000000000000000000000000000010000000000401b5f1300000000000000,
        //         0x80ffb9805626b5eeb95364cd35028f6c2e9502e6763c35b49146c3e06eb0fb0c8437e2f5807d6bd45dc0de8a9d3c09ed996173e3228aa1f0c14343e3613600679837c0459e80a1aec849f3a38d7d135fb693c8ea2d30ce711f9de4d6216df3c1a9a1fed7652480f4aa779b91c9584e64e8f414a45415633ddab553b733a8f053ea281665f6e2798037521b6b221966c2e46dadb5ec9f5dd9955bfb6ddc80b7fd2426c8a80b715742807dfc144d3b4073275b82f6e907ec3a2e23734838c9dfd21815d40813f1037bc980257276b52625f532a5b3415084fb91ded52ba117e97209555a8c05054ce5310d80e9e915eca5fb72b66cf72c2e7726f366889ee12e459bb8e4c8db0db83b5b408f80f39c11c55a33b88d079ac377e5fddee82d1c9471f66fb6a28bd3ad96446c983680df791956f0167fb9bed6c0e9fee9de3d6babf3d1152f5deca446dc29a9e9c9fe80d0b26d2c3777a1ff46e46dab9260a54906108d698aa87d6e4a5ebd0d9d9dd416800d5ead5e5c3f67b600edee6ff127a9cdb90fa28f06bc4804ce6dc639c887360b8004815669f5ffdf790a76a75b3b40f700e8bf7d73eb084aaf9dd793eeda3d5252,
        //         0x9eaa394eea5630e07c48ae0c9558cef7298d585f0a98fdbe9ce6c55837576c60c7af3850100500000080798651e0861e900ea90d37dbeea088da90fe28b729ad85b33daa3e3b3dcc9c514c5f0684a022a34dd8bfa2baaf44f172b710040180ebbd938d8e0afb593ff42ca3bc9f58af377da287c9f7c380aa508fa6da70e15580ced43296cd3920efab18447ae4ba50dcc5e87a8db36593ee92756cdd9f36b7598082a75959f024cac266849285f69c1ac49da16ee7801ff4f93fd3cfd3563a47bc605f09cce9c888469bb1a0dceaa129672ef818701043726162,
        //         0x804b0c80feecb9b8cd91aca389352bb80a01c989ade193be7b6361af47238c2974617a1c808294a7635adce51c7ce4f1faa73c37b02852af44ddea9f79eedfea377ce12711801941a755228dfeade556d93ca6af552ca8974fef5d59b56e6ed0083814201fd0800c8012fed6518393bda3231cc9bc889428748a0c4f6e4c832a632469630e203180d80ae17a3fa70e1addb66fd67ff84d2d84c290c73ef9d15d1d748a134d79b15580f732747b5206732f92adaf4f143693558e5cff9d78ae1b2b40040fdcbef859b2
        //     ]
        // }

        // Encode Vec<u8>

        bytes memory hexData = hex"1081035f00d41e5e16056765bc8461851072c9d735031400000000000000608796090000000002000000010000001702e096b1496b056d5e1ee8e9ef272ff74f05e50884a52318adde16b3b5c6655c3f22aaaaf10536d812c7e097f59e7b769e24341830d42d4551a5c0369a588e4e4000e40b54020000000000000000000000000001000000200600c4192700000000000000000000000000000100000017040f99850f381fdfb5b965617619e59ed082a4515c22967c9c1c94621969362aba0071c6090000000000000000000000000000010000000000401b5f1300000000000000c10680ffb9805626b5eeb95364cd35028f6c2e9502e6763c35b49146c3e06eb0fb0c8437e2f5807d6bd45dc0de8a9d3c09ed996173e3228aa1f0c14343e3613600679837c0459e80a1aec849f3a38d7d135fb693c8ea2d30ce711f9de4d6216df3c1a9a1fed7652480f4aa779b91c9584e64e8f414a45415633ddab553b733a8f053ea281665f6e2798037521b6b221966c2e46dadb5ec9f5dd9955bfb6ddc80b7fd2426c8a80b715742807dfc144d3b4073275b82f6e907ec3a2e23734838c9dfd21815d40813f1037bc980257276b52625f532a5b3415084fb91ded52ba117e97209555a8c05054ce5310d80e9e915eca5fb72b66cf72c2e7726f366889ee12e459bb8e4c8db0db83b5b408f80f39c11c55a33b88d079ac377e5fddee82d1c9471f66fb6a28bd3ad96446c983680df791956f0167fb9bed6c0e9fee9de3d6babf3d1152f5deca446dc29a9e9c9fe80d0b26d2c3777a1ff46e46dab9260a54906108d698aa87d6e4a5ebd0d9d9dd416800d5ead5e5c3f67b600edee6ff127a9cdb90fa28f06bc4804ce6dc639c887360b8004815669f5ffdf790a76a75b3b40f700e8bf7d73eb084aaf9dd793eeda3d525269039eaa394eea5630e07c48ae0c9558cef7298d585f0a98fdbe9ce6c55837576c60c7af3850100500000080798651e0861e900ea90d37dbeea088da90fe28b729ad85b33daa3e3b3dcc9c514c5f0684a022a34dd8bfa2baaf44f172b710040180ebbd938d8e0afb593ff42ca3bc9f58af377da287c9f7c380aa508fa6da70e15580ced43296cd3920efab18447ae4ba50dcc5e87a8db36593ee92756cdd9f36b7598082a75959f024cac266849285f69c1ac49da16ee7801ff4f93fd3cfd3563a47bc605f09cce9c888469bb1a0dceaa129672ef8187010437261622503804b0c80feecb9b8cd91aca389352bb80a01c989ade193be7b6361af47238c2974617a1c808294a7635adce51c7ce4f1faa73c37b02852af44ddea9f79eedfea377ce12711801941a755228dfeade556d93ca6af552ca8974fef5d59b56e6ed0083814201fd0800c8012fed6518393bda3231cc9bc889428748a0c4f6e4c832a632469630e203180d80ae17a3fa70e1addb66fd67ff84d2d84c290c73ef9d15d1d748a134d79b15580f732747b5206732f92adaf4f143693558e5cff9d78ae1b2b40040fdcbef859b2";
        Input.Data memory data = Input.from(hexData);

        bytes[] memory proofs = Scale.decodeReceiptProof(data);
        bytes[] memory expect = new bytes[](4);
        expect[0] = hex"5f00d41e5e16056765bc8461851072c9d735031400000000000000608796090000000002000000010000001702e096b1496b056d5e1ee8e9ef272ff74f05e50884a52318adde16b3b5c6655c3f22aaaaf10536d812c7e097f59e7b769e24341830d42d4551a5c0369a588e4e4000e40b54020000000000000000000000000001000000200600c4192700000000000000000000000000000100000017040f99850f381fdfb5b965617619e59ed082a4515c22967c9c1c94621969362aba0071c6090000000000000000000000000000010000000000401b5f1300000000000000";
        expect[1] = hex"80ffb9805626b5eeb95364cd35028f6c2e9502e6763c35b49146c3e06eb0fb0c8437e2f5807d6bd45dc0de8a9d3c09ed996173e3228aa1f0c14343e3613600679837c0459e80a1aec849f3a38d7d135fb693c8ea2d30ce711f9de4d6216df3c1a9a1fed7652480f4aa779b91c9584e64e8f414a45415633ddab553b733a8f053ea281665f6e2798037521b6b221966c2e46dadb5ec9f5dd9955bfb6ddc80b7fd2426c8a80b715742807dfc144d3b4073275b82f6e907ec3a2e23734838c9dfd21815d40813f1037bc980257276b52625f532a5b3415084fb91ded52ba117e97209555a8c05054ce5310d80e9e915eca5fb72b66cf72c2e7726f366889ee12e459bb8e4c8db0db83b5b408f80f39c11c55a33b88d079ac377e5fddee82d1c9471f66fb6a28bd3ad96446c983680df791956f0167fb9bed6c0e9fee9de3d6babf3d1152f5deca446dc29a9e9c9fe80d0b26d2c3777a1ff46e46dab9260a54906108d698aa87d6e4a5ebd0d9d9dd416800d5ead5e5c3f67b600edee6ff127a9cdb90fa28f06bc4804ce6dc639c887360b8004815669f5ffdf790a76a75b3b40f700e8bf7d73eb084aaf9dd793eeda3d5252";
        expect[2] = hex"9eaa394eea5630e07c48ae0c9558cef7298d585f0a98fdbe9ce6c55837576c60c7af3850100500000080798651e0861e900ea90d37dbeea088da90fe28b729ad85b33daa3e3b3dcc9c514c5f0684a022a34dd8bfa2baaf44f172b710040180ebbd938d8e0afb593ff42ca3bc9f58af377da287c9f7c380aa508fa6da70e15580ced43296cd3920efab18447ae4ba50dcc5e87a8db36593ee92756cdd9f36b7598082a75959f024cac266849285f69c1ac49da16ee7801ff4f93fd3cfd3563a47bc605f09cce9c888469bb1a0dceaa129672ef818701043726162";
        expect[3] = hex"804b0c80feecb9b8cd91aca389352bb80a01c989ade193be7b6361af47238c2974617a1c808294a7635adce51c7ce4f1faa73c37b02852af44ddea9f79eedfea377ce12711801941a755228dfeade556d93ca6af552ca8974fef5d59b56e6ed0083814201fd0800c8012fed6518393bda3231cc9bc889428748a0c4f6e4c832a632469630e203180d80ae17a3fa70e1addb66fd67ff84d2d84c290c73ef9d15d1d748a134d79b15580f732747b5206732f92adaf4f143693558e5cff9d78ae1b2b40040fdcbef859b2";

        console.log(proofs.length);
        console.logBytes(proofs[0]);

        // console.log(keys.length);
        // console.logBytes(keys[0]);

        assertEq0(proofs[0], expect[0]);
        assertEq0(proofs[1], expect[1]);
        assertEq0(proofs[2], expect[2]);
        assertEq0(proofs[3], expect[3]);
    }

    function testDecodeAccountId() public {
        bytes memory hexData = hex"d43593c715fdd31c61141abd04a99fd6822c8558854ccde39a5684e7a56da27d";
        Input.Data memory data = Input.from(hexData);

        bytes32 accountId = Scale.decodeAccountId(data);
        assertEq32(accountId, bytes32(hex"d43593c715fdd31c61141abd04a99fd6822c8558854ccde39a5684e7a56da27d"));

        console.logBytes32(accountId);
    }

    function testDecodeAccountId2() public {
        bytes memory hexData = hex"d43593c715fdd31c61141abd04a99fd6822c8558854ccde39a5684e7a56da27d0000";
        Input.Data memory data = Input.from(hexData);

        bytes32 accountId = Scale.decodeAccountId(data);
        assertEq32(accountId, bytes32(hex"d43593c715fdd31c61141abd04a99fd6822c8558854ccde39a5684e7a56da27d"));

        console.logBytes32(accountId);
    }

    function testDecodeBalance() public {
        bytes memory hexData = hex"00000000000000000000000000000000";
        Input.Data memory data = Input.from(hexData);

        uint128 balance = Scale.decodeBalance(data);
        console.log(balance);
        assertEq(uint256(balance), uint256(0));
    }

    function testDecodeBalance1() public {
        bytes memory hexData = hex"01000000000000000000000000000000";
        Input.Data memory data = Input.from(hexData);

        uint128 balance = Scale.decodeBalance(data);
        console.log(balance);
        assertEq(uint256(balance), uint256(1));
    }

    function testDecodeBalance2() public {
        bytes memory hexData = hex"01000000e88f872b824dc77261421300";
        Input.Data memory data = Input.from(hexData);

        uint128 balance = Scale.decodeBalance(data);
        console.log(balance);
        assertEq(uint256(balance), uint256(100000000000000000000000000000000001));
    }

    function testDecodeBalance3() public {
        bytes memory hexData = hex"ffffffffffffffffffffffffffffffff";
        Input.Data memory data = Input.from(hexData);

        uint128 balance = Scale.decodeBalance(data);
        console.log(balance);
        assertEq(uint256(balance), uint256(340282366920938463463374607431768211455));
    }

    function testDecodeLockEvents() public {
        // Vec<Event>    Event = <index, Data>   Data = {accountId, EthereumAddress, types, Balance}
        bytes memory hexData = hex"082403e44664996ab7b5d86c12e9d5ac3093f5b2efc9172cb7ce298cd6c3c51002c318cc5e48beb33b83b8bd0d9d9a85a8f6a27c51f5c5b52fbe2b925ab79a821b261c82c5ba0814aaa5e000ca9a3b0000000000000000000000002404e44664996ab7b5d86c12e9d5ac3093f5b2efc9172cb7ce298cd6c3c51002c318cc5e48beb33b83b8bd0d9d9a85a8f6a27c51f5c51994100c58753793d52c6f457f189aa3ce9cee9400943577000000000000000000000000";
        Input.Data memory data = Input.from(hexData);
        ScaleStruct.LockEvent[] memory eventData = Scale.decodeLockEvents(data);

        console.log(eventData.length);

        assertEq(eventData.length, 2);

        assertEq32(eventData[0].sender, hex"e44664996ab7b5d86c12e9d5ac3093f5b2efc9172cb7ce298cd6c3c51002c318");
        assertEq(eventData[0].recipient, 0xcC5E48BEb33b83b8bD0D9d9A85A8F6a27C51F5C5);
        assertEq(eventData[0].token, 0xb52FBE2B925ab79a821b261C82c5Ba0814AAA5e0);
        assertEq(uint(eventData[0].value), 1000000000);

        assertEq32(eventData[1].sender, hex"e44664996ab7b5d86c12e9d5ac3093f5b2efc9172cb7ce298cd6c3c51002c318");
        assertEq(eventData[1].recipient, 0xcC5E48BEb33b83b8bD0D9d9A85A8F6a27C51F5C5);
        assertEq(eventData[1].token, 0x1994100c58753793D52c6f457f189aa3ce9cEe94);
        assertEq(uint(eventData[1].value), 2000000000);

        // assertEq32(eventData[2].sender, hex"8eaf04151687736326c9fea17e25fc5287613693c912909cb226aa4794f26a48");
        // assertEq(eventData[2].recipient, 0xB20bd5D04BE54f870D5C0d3cA85d82b34B836405);
        // assertEq(uint(eventData[2].token), 0);
        // assertEq(uint(eventData[2].value), 456000000000);

        // assertEq32(eventData[3].sender, hex"8eaf04151687736326c9fea17e25fc5287613693c912909cb226aa4794f26a48");
        // assertEq(eventData[3].recipient, 0xB20bd5D04BE54f870D5C0d3cA85d82b34B836405);
        // assertEq(uint(eventData[3].token), 1);
        // assertEq(uint(eventData[3].value), 20000000000);

        console.logBytes32(eventData[0].sender);
        console.logAddress(eventData[0].recipient);
        console.logAddress(eventData[0].token);
        console.log(uint(eventData[0].value));

        console.logBytes32(eventData[1].sender);
        console.logAddress(eventData[1].recipient);
        console.logAddress(eventData[1].token);
        console.log(uint(eventData[1].value));

        // console.logBytes32(eventData[2].sender);
        // console.logAddress(eventData[2].recipient);
        // console.log(uint(eventData[2].token));
        // console.log(uint(eventData[2].value));

        // console.logBytes32(eventData[3].sender);
        // console.logAddress(eventData[3].recipient);
        // console.log(uint(eventData[3].token));
        // console.log(uint(eventData[3].value));

    }

    function testDecodeEthereumAddress() public {
        bytes memory hexData = hex"b20bd5d04be54f870d5c0d3ca85d82b34b83640501020304";
        Input.Data memory data = Input.from(hexData);

        address addr = Scale.decodeEthereumAddress(data);
        console.logAddress(addr);
        assertEq(addr, 0xB20bd5D04BE54f870D5C0d3cA85d82b34B836405);
    }

    function testDecodeAuthorities() public {

        // let str = api.createType('{"prefix": "Vec<u8>", "methodID": "[u8; 4]" "nonce": "Compact<u32>", "authorities": "Vec<EthereumAddress>"}', {
        // prefix: 'crab',
        // methodID: 'b4bcf497',
        // nonce: 100,
        // authorities: ['0x9f284e1337a815fe77d2ff4ae46544645b20c5ff','0x9469d013805bffb7d3debe5e7839237e535ec483']
        // })
        // console.log(str)
        // console.log(str.toHex())

        // {prefix: 0x63726162, methodID:0xb4bcf497, nonce: 100, authorities: [0x9F284E1337A815fe77D2Ff4aE46544645B20c5ff, 0x9469d013805bffb7d3debe5e7839237e535ec483]}
        // 1063726162b4bcf4979101089f284e1337a815fe77d2ff4ae46544645b20c5ff9469d013805bffb7d3debe5e7839237e535ec483

        bytes memory hexData = hex"1063726162b4bcf4979101089f284e1337a815fe77d2ff4ae46544645b20c5ff9469d013805bffb7d3debe5e7839237e535ec483";
        Input.Data memory data = Input.from(hexData);

        (bytes memory prefix, bytes4 methodID, uint32 nonce, address[] memory authorities) = Scale.decodeAuthorities(data);

        console.log(uint256(nonce));
        console.log(authorities.length);
        console.logAddress(authorities[0]);
        console.logAddress(authorities[1]);
        console.logBytes(prefix);
        console.logBytes4(methodID);

        assertEq0(prefix, hex"63726162");
        assertEq(uint256(nonce), 100);
        assertEq(authorities[0], 0x9F284E1337A815fe77D2Ff4aE46544645B20c5ff);
        assertEq(authorities[1], 0x9469D013805bFfB7D3DEBe5E7839237e535ec483);
    }

    function testDecodeMMRRoot() public {
        // let str = api.createType('{"prefix": "Vec<u8>", "index": "Compact<u32>", "root": "H256"}', new Uint8Array([16, 68, 82, 77, 76, 85, 12, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 1, 2, 3, 4, 5, 6, 7, 8, 9, 1, 2, 3, 4, 5, 6, 7, 8, 9, 1, 2, 3, 4]))
        // console.log(str)
        // console.log(str.toHex())

        // {prefix: Crab, methodID: 0x479fbdf9, index: 16384, root: 0x5fe7f977e71dba2ea1a68e21057beebb9be2ac30c6410aa38d4f3fbe41dcffd2}
        // 1043726162479fbdf9020001005fe7f977e71dba2ea1a68e21057beebb9be2ac30c6410aa38d4f3fbe41dcffd2

        bytes memory hexData = hex"1043726162479fbdf9020001005fe7f977e71dba2ea1a68e21057beebb9be2ac30c6410aa38d4f3fbe41dcffd2";
        Input.Data memory data = Input.from(hexData);

        (bytes memory prefix, bytes4 methodID, uint32 index, bytes32 root) = Scale.decodeMMRRoot(data);

        console.log(uint256(index));
        console.logBytes32(root);
        console.logBytes(prefix);
        console.logBytes4(methodID);

        assertEq0(prefix, hex"43726162");
        assertEq(uint256(index), 16384);
        assertEq(root, bytes32(hex"5fe7f977e71dba2ea1a68e21057beebb9be2ac30c6410aa38d4f3fbe41dcffd2"));
    }

    function testDecodeStateRootFromBlockHeader() public {
        bytes32 root = Scale.decodeStateRootFromBlockHeader(hex"b20ea574de7640b8b6f84312c90a40cd123c1be7cc1655edb4713e61f97fd3ae8991eb3811bb17fe224d59847a47ae0bdd2b2663b1e422c3473638227f86dec82818e7d09cdbf8205034542f4a0116aa07ce96efe63cd2255895acd0474e28d7587f1006424142453402000000003f08f80f000000000466726f6e8801673d4723721b48cef07ce4c4208f4ac233734d7e58cc6ab27f8452bc238cb8df0000904d4d5252b5d7c88ac37e4f91f481e642f87d111e4b2a3b7e791697950139000e4eef094705424142450101b82ad773a86ff32162375e8e6bb455043db376439a90dbc530967f3f2d47184a4610bd6e231b4a5256df1d751c05dffa4d3869c74209b9bf0be55548850f1286");
        console.logBytes32(root);
        assertEq(root, bytes32(hex"eb3811bb17fe224d59847a47ae0bdd2b2663b1e422c3473638227f86dec82818"));
    }

    function testDecodeBlockNumberFromBlockHeader() public {
        uint32 blocknumber = Scale.decodeBlockNumberFromBlockHeader(hex"3d92b814cb5f05b1f33aeeb4ebead80ed7b5e7eb21838c546acbbb1a585f04d4deb2da003536ace91a15febf2fb1f3b26399915c6756b497c01a53be21a92c8d0ed56a470b8d75c63be1924db8b654d30968ca1e9d0658258fda8e7028e2cfa432a21c080c0642414245340219000000aed900100000000000904d4d525233e62b9e4a7770773c4e8a021d6ce0701537c9f80a4a6d129528165ec0e5af4705424142450101702886fa858cdc9c8bb61cce6228d143c60b9b6d1ae1e729d48a4de8fa87c42575346a4a0da449b5c41d2a5eb71b09e355c0a787738ac2683066430d312ba687");
        console.log(blocknumber);
        assertEq(uint256(blocknumber), 3583159);
    }

    function testHackDecodeMMRRootAndDecodeAuthorities() public {

        // let str = api.createType('{"prefix": "Vec<u8>", "index": "Compact<u32>", "root": "H256"}', new Uint8Array([16, 68, 82, 77, 76, 85, 12, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 1, 2, 3, 4, 5, 6, 7, 8, 9, 1, 2, 3, 4, 5, 6, 7, 8, 9, 1, 2, 3, 4]))
        // console.log(str)
        // console.log(str.toHex())

        // {prefix: Crab, index: 16384, root: 0x5fe7f977e71dba2ea1a68e21057beebb9be2ac30c6410aa38d4f3fbe41dcffd2}
        // 1043726162020001005fe7f977e71dba2ea1a68e21057beebb9be2ac30c6410aa38d4f3fbe41dcffd2

        // Scale.DecodeAuthorities Scale.DecodeMMRRoot use
        bytes memory hexData = hex"10637261629101089f284e1337a815fe77d2ff4ae46544645b20c5ff9469d013805bffb7d3debe5e7839237e535ec483";
        Input.Data memory data = Input.from(hexData);

        (bytes memory prefix, , uint32 index, bytes32 root) = Scale.decodeMMRRoot(data);

        assertEq0(prefix, hex"63726162");
        assertEq(uint256(index), 100);
        assertEq(root, bytes32(hex"089f284e1337a815fe77d2ff4ae46544645b20c5ff9469d013805bffb7d3debe"));
    }
}
