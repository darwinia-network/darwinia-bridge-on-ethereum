// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.7.0;
pragma experimental ABIEncoderV2;

import "../interfaces/IOutboundChannel.sol";

// BasicOutboundChannel is a basic channel that just sends messages with a nonce.
contract BasicOutboundChannel is IOutboundChannel {

    uint64 public nonce;

    event Message(
        address source,
        uint64 nonce,
        bytes payload
    );

    /**
     * @dev Sends a message across the channel
     */
    function submit(bytes calldata payload) external override {
        nonce = nonce + 1;
        emit Message(msg.sender, nonce, payload);
    }
}
