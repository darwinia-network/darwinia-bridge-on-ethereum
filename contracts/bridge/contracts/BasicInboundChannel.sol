// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.7.0;
pragma experimental ABIEncoderV2;

import "@darwinia/contracts-utils/contracts/SafeMath.sol";
import "@darwinia/contracts-utils/contracts/ScaleHeader.sol";
import "@darwinia/contracts-utils/contracts/Hash.sol";
import "./interfaces/ILightClientBridge.sol";

contract BasicInboundChannel {
    uint256 public constant MAX_GAS_PER_MESSAGE = 100000;

    struct Message {
        address target;
        uint64 nonce;
        bytes payload;
    }

    event MessageDispatched(uint64 nonce, bool result);

    uint64 public nonce;
    ILightClientBridge public lightClientBridge;

    constructor(ILightClientBridge _lightClientBridge) public {
        nonce = 0;
        lightClientBridge = _lightClientBridge;
    }

    // TODO: Submit should take in all inputs required for verification,
    function submit(
        Message[] memory messages,
        bytes memory beefyMMRLeaf,
        bytes memory blockHeader,
        uint256 beefyMMRLeafIndex,
        uint256 beefyMMRLeafCount,
        bytes32[] memory peaks,
        bytes32[] memory siblings 
    ) public {
        bytes32 beefyMMRLeafHash = keccak256(beefyMMRLeaf);
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
        verifyMessages(messages, beefyMMRLeaf, blockHeader);
        processMessages(messages);
    }

    //TODO: verifyMessages should accept all needed proofs
    function verifyMessages(Message[] memory messages, bytes memory beefyMMRLeaf, bytes memory blockHeader)
        internal
        view
        returns (bool success)
    {
        // struct BeefyMMRLeaf {
        //     uint32 parentNumber;
        //     bytes32 parentHash;
        //     bytes32 parachainHeadsRoot;
        //     uint64 nextAuthoritySetId;
        //     uint32 nextAuthoritySetLen;
        //     bytes32 nextAuthoritySetRoot;
        // }
        // struct MMRLeaf {
        //     bytes32 parentHash;
        // }
        bytes32 blockHash = abi.decode(beefyMMRLeaf, (bytes32));
        require(blockHash == keccak256(blockHeader), "Channel: invalid block header");
        uint32 blockNumber = ScaleHeader.decodeBlockNumberFromBlockHeader(blockHeader);
        require(
            blockNumber <= lightClientBridge.getFinalizedBlockNumber(),
            "Channel: block not finalized"
        );
        bytes32 messagesRoot = ScaleHeader.decodeMessagesRootFromBlockHeader(blockHeader);

        // Validate that the commitment matches the commitment contents
        require(
            validateMessagesMatchRoot(messages, messagesRoot),
            "Channel: invalid messages"
        );

        // Require there is enough gas to play all messages
        require(
            gasleft() >= messages.length * MAX_GAS_PER_MESSAGE,
            "Channel: insufficient gas for delivery of all messages"
        );

        return true;
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
}
