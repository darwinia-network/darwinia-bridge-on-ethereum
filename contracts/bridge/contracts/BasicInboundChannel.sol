// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.7.0;
pragma experimental ABIEncoderV2;

import "@darwinia/contracts-utils/contracts/SafeMath.sol";
import "./interfaces/ILightClientBridge.sol";

contract BasicInboundChannel {
    uint256 public constant MAX_GAS_PER_MESSAGE = 100000;

    uint64 public nonce;

    struct Message {
        address target;
        uint64 nonce;
        bytes payload;
    }

    // struct MMRLeaf {
    //     bytes32 blockHash;
    //     bytes32 beefyNextAuthoritySetRoot;
    // }

    event MessageDispatched(uint64 nonce, bool result);

    ILightClientBridge public lightClientBridge;

    constructor(ILightClientBridge _lightClientBridge) public {
        nonce = 0;
        lightClientBridge = _lightClientBridge;
    }

    // TODO: Submit should take in all inputs required for verification,
    function submit(
        Message[] memory messages,
        bytes memory beefyMMRLeaf,
        uint256 beefyMMRLeafIndex,
        uint256 beefyMMRLeafCount,
        bytes32[] memory peaks,
        bytes32[] memory siblings
    ) public {
        require(
            lightClientBridge.verifyBeefyMerkleLeaf(
                beefyMMRLeaf,
                beefyMMRLeafIndex,
                beefyMMRLeafCount,
                peaks,
                siblings
            ),
            "Invalid proof"
        );
        verifyMessages(messages, beefyMMRLeaf);
        processMessages(messages);
    }

    // struct BlockHeader {
    //     parentHash bytes32;
    //     number uint64;
    //     stateRoot bytes32;
    //     extrinsicsRoot bytes32;
    //     digest bytes;
    //     messagesRoot bytes32;
    // }
    //TODO: verifyMessages should accept all needed proofs
    function verifyMessages(Message[] memory messages, bytes memory /*beefyMMRLeaf*/)
        internal
        view
        returns (bool success)
    {

        // Scale.decodeBeefyMMRLeaf(beefyMMRLeaf)
        // Scale.decodeBlockHeader(beefyMMRLeaf.BlockHeader)
        // require(
        //     blockHeader.BlockNumber <= lightClientBridge.getFinalizedBlockNumber(),
        //     "block not finalized"
        // )

        // Validate that the commitment matches the commitment contents
        // require(
        //     validateMessagesMatchCommitment(messages, blockHeader.messageRoot),
        //     "invalid messages"
        // );

        // Require there is enough gas to play all messages
        require(
            gasleft() >= messages.length * MAX_GAS_PER_MESSAGE,
            "insufficient gas for delivery of all messages"
        );

        return true;
    }

    function processMessages(Message[] memory messages) internal {
        for (uint256 i = 0; i < messages.length; i++) {
            // Check message nonce is correct and increment nonce for replay protection
            require(messages[i].nonce == nonce + 1, "invalid nonce");

            nonce = nonce + 1;

            // Deliver the message to the target
            (bool success, ) =
                messages[i].target.call{value: 0, gas: MAX_GAS_PER_MESSAGE}(
                    messages[i].payload
                );

            emit MessageDispatched(messages[i].nonce, success);
        }
    }

    function validateMessagesMatchCommitment(
        Message[] memory messages,
        bytes32 commitment
    ) internal pure returns (bool) {
        return keccak256(abi.encode(messages)) == commitment;
    }
}
