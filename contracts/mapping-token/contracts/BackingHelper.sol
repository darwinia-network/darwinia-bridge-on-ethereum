// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "./WETH.sol";
import "./interfaces/IWETH.sol";
import "@darwinia/contracts-utils/contracts/Scale.sol";
import { ScaleStruct } from "@darwinia/contracts-utils/contracts/Scale.struct.sol";

pragma experimental ABIEncoderV2;

struct Fee {
    address token;
    uint256 fee;
}

interface IBacking {
    function crossChainSync(
        bytes memory message,
        bytes[] memory signatures,
        bytes32 root,
        uint32 MMRIndex,
        bytes memory blockHeader,
        bytes32[] memory peaks,
        bytes32[] memory siblings,
        bytes memory eventsProofStr
    ) external returns(ScaleStruct.IssuingEvent[] memory);
    function crossSendToken(
        address token,
        address recipient,
        uint256 amount) external;
    function history(uint32 blockNumber) external returns(address);
    function getIssuingEvent(
        bytes32 root,
        uint32 MMRIndex,
        bytes memory blockHeader,
        bytes32[] memory peaks,
        bytes32[] memory siblings,
        bytes memory eventsProofStr,
        uint32 blockNumber
    ) external view returns(ScaleStruct.IssuingEvent[] memory);
    function transferFee() external view returns(Fee memory);
}

contract BackingHelper is WETH9 {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    address public backing;
    mapping(uint32 => address) public history;

    event RedeemTokenEvent(address token, address recipient, uint256 value);

    constructor (address _backing) public {
        backing = _backing;
        increaseAllowance();
    }

    function increaseAllowance() public {
        allowance[address(this)][backing] = uint256(-1);
        Fee memory fee = IBacking(backing).transferFee();
        IERC20(fee.token).approve(backing, uint256(-1));
    }

    function crossSendETH(address recipient) external payable {
        require(msg.value > 0, "balance cannot be zero");
        balanceOf[address(this)] += msg.value;
        Fee memory fee = IBacking(backing).transferFee();
        if (fee.fee > 0) {
            IERC20(fee.token).safeTransferFrom(msg.sender, address(this), fee.fee);
        }
        IBacking(backing).crossSendToken(address(this), recipient, msg.value);
    }

    function redeem(
        bytes memory message,
        bytes[] memory signatures,
        bytes32 root,
        uint32 MMRIndex,
        bytes memory blockHeader,
        bytes32[] memory peaks,
        bytes32[] memory siblings,
        bytes memory eventsProofStr
    ) external {
        uint32 blockNumber = Scale.decodeBlockNumberFromBlockHeader(blockHeader);
        require(history[blockNumber] == address(0), "BackingHelper::redeem: The block has been redeemed");
        address sender = IBacking(backing).history(blockNumber);
        ScaleStruct.IssuingEvent[] memory events;
        if (sender != address(0)) {
            events = IBacking(backing).getIssuingEvent(root, MMRIndex, blockHeader, peaks, siblings, eventsProofStr, blockNumber);
        } else {
            events = IBacking(backing).crossChainSync(
                message,
                signatures,
                root,
                MMRIndex,
                blockHeader,
                peaks,
                siblings,
                eventsProofStr);
        }
        uint256 len = events.length;
        for( uint i = 0; i < len; i++) {
            ScaleStruct.IssuingEvent memory item = events[i];
            if (item.eventType == 1) {
                if (item.token == address(this)) {
                    require(balanceOf[item.recipient] >= item.value);
                    balanceOf[item.recipient] -= item.value;
                    item.recipient.transfer(item.value);
                }
                emit RedeemTokenEvent(item.token, item.recipient, item.value);
            }
        }
        history[blockNumber] = msg.sender;
    }
}

