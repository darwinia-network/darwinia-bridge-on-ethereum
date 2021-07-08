// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.7.0;
import "./ds-test/test.sol";

import "./Bytes.sol";
import "hardhat/console.sol";

pragma experimental ABIEncoderV2;

contract BytesTest is DSTest {
    using Bytes for bytes;

    function setUp() public {}

    function testFail_basic_sanity() public {
        assertTrue(false);
    }

    function test_basic_sanity() public {
        assertTrue(true);
    }


    function testToBytes32() public logs_gas{
        bytes memory data1 = hex"15eaf80e3066655d1638aa316fe417d6998efbc383204099c00d5429c8d06456";
        bytes32 res1 = data1.toBytes32();
        assertEq32(res1, bytes32(hex'15eaf80e3066655d1638aa316fe417d6998efbc383204099c00d5429c8d06456'));


        bytes memory data2 = hex"15eaf80e3066655d1638aa316fe417d6998efbc383204099c00d542900000000";
        bytes32 res2 = data2.toBytes32();
        assertEq32(res2, bytes32(hex'15eaf80e3066655d1638aa316fe417d6998efbc383204099c00d542900000000'));


        bytes memory data3 = hex"000000003066655d1638aa316fe417d6998efbc383204099c00d5429c8d06456";
        bytes32 res3 = data3.toBytes32();
        assertEq32(res3, bytes32(hex'000000003066655d1638aa316fe417d6998efbc383204099c00d5429c8d06456'));


        bytes memory data4 = hex"0000000000000000000000000000000000000000000000000000000000000000";
        bytes32 res4 = data4.toBytes32();
        assertEq32(res4, bytes32(hex'0000000000000000000000000000000000000000000000000000000000000000'));
    }

    function testToBytes16() public logs_gas{
        bytes memory data1 = hex"15eaf80e3066655d1638aa316fe417d6";
        bytes32 res1 = data1.toBytes16(0);
        assertEq32(res1, bytes32(hex'15eaf80e3066655d1638aa316fe417d6'));
    }

    function testToBytes32Revert() public logs_gas{
        bytes memory data = hex"15ea";
        bytes32 res = data.toBytes32();
        assertEq32(res, bytes32(hex'15ea'));
    }

    function testToBytes16Revert() public logs_gas{
        bytes memory data = hex"15ea";
        bytes32 res = data.toBytes16(0);
        assertEq32(res, bytes32(hex'15ea'));
    }
}
