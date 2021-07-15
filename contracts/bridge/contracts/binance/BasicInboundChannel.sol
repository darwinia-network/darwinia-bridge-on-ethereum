// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.7.0;
pragma experimental ABIEncoderV2;

import "@darwinia/contracts-utils/contracts/SafeMath.sol";
import "../interfaces/ILightClientBridge.sol";

contract BasicInboundChannel {
    uint256 public constant MAX_GAS_PER_MESSAGE = 100000;

    struct Message {
        address target;
        uint64 nonce;
        bytes payload;
    }

    /**
     * The BeefyMMRLeaf is the structure of each leaf in each MMR that each commitment's payload commits to.
     * @param parentHash parent hash of the block this leaf describes
     * @param messagesRoot root hash of messages
     * @param blockNumber block number for the block this leaf describes
     */
    struct BeefyMMRLeaf {
        bytes32 parentHash;
        bytes32 messagesRoot;
        uint32 blockNumber;
    }

    event MessageDispatched(uint64 nonce, bool result);

    uint64 public nonce;
    ILightClientBridge public lightClientBridge;

    constructor(ILightClientBridge _lightClientBridge) public {
        nonce = 0;
        lightClientBridge = _lightClientBridge;
    }

    function submit(
        Message[] memory messages,
        BeefyMMRLeaf memory beefyMMRLeaf,
        uint256 beefyMMRLeafIndex,
        uint256 beefyMMRLeafCount,
        bytes32[] memory peaks,
        bytes32[] memory siblings 
    ) public {
        bytes32 beefyMMRLeafHash = hashMMRLeaf(beefyMMRLeaf);
        require(
            lightClientBridge.verifyBeefyMerkleLeaf(
                beefyMMRLeafHash,
                beefyMMRLeafIndex,
                beefyMMRLeafCount,
                peaks,
                siblings
            ),
            "Channel: Invalid proof"
        );
        verifyMessages(messages, beefyMMRLeaf);
        processMessages(messages);
    }

    function verifyMessages(Message[] memory messages, BeefyMMRLeaf memory leaf)
        internal
        view
    {
        require(
            leaf.blockNumber <= lightClientBridge.getFinalizedBlockNumber(),
            "Channel: block not finalized"
        );
        // Validate that the commitment matches the commitment contents
        require(
            validateMessagesMatchRoot(messages, leaf.messagesRoot),
            "Channel: invalid messages"
        );

        // Require there is enough gas to play all messages
        require(
            gasleft() >= messages.length * MAX_GAS_PER_MESSAGE,
            "Channel: insufficient gas for delivery of all messages"
        );
    }

    function processMessages(Message[] memory messages) internal {
        for (uint256 i = 0; i < messages.length; i++) {
            // Check message nonce is correct and increment nonce for replay protection
            require(messages[i].nonce == nonce + 1, "Channel: invalid nonce");

            nonce = nonce + 1;

            // Deliver the message to the target
            (bool success, ) =
                messages[i].target.call{value: 0, gas: MAX_GAS_PER_MESSAGE}(
                    messages[i].payload
                );

            emit MessageDispatched(messages[i].nonce, success);
        }
    }

    function validateMessagesMatchRoot(
        Message[] memory messages,
        bytes32 root
    ) internal pure returns (bool) {
        return keccak256(abi.encode(messages)) == root;
    }

    function hashMMRLeaf(BeefyMMRLeaf memory leaf)
        internal
        pure
        returns (bytes32) 
    {
        return keccak256(
                abi.encodePacked(
                    leaf.parentHash,
                    leaf.messagesRoot,
                    leaf.blockNumber
                )
            );
    }
}
