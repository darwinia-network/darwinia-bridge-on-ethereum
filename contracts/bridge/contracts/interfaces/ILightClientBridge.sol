// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.7.0;
pragma experimental ABIEncoderV2;

interface ILightClientBridge {
    struct NextValidatorSet {
        bytes32 root;
        uint64 id;
        uint64 len;
    }

    struct Payload {
        bytes32 mmr;
        NextValidatorSet nextValidatorSet;
    }

    struct Commitment {
        Payload payload;
        uint64 blockNumber;
        uint64 validatorSetId;
    }

    function newSignatureCommitment(
        bytes32 commitmentHash,
        uint256[] calldata validatorClaimsBitfield,
        bytes calldata validatorSignature,
        uint256 validatorPosition,
        address validatorPublicKey,
        bytes32[] calldata validatorPublicKeyMerkleProof
    ) external;

    function completeSignatureCommitment(
        uint256 id,
        Commitment calldata commitment,
        bytes[] calldata signatures,
        uint256[] calldata validatorPositions,
        address[] calldata validatorPublicKeys,
        bytes32[][] calldata validatorPublicKeyMerkleProofs
    ) external;

    function verifyBeefyMerkleLeaf(
        bytes calldata beefyMMRLeaf,
        uint256 beefyMMRLeafIndex,
        uint256 beefyMMRLeafCount,
        bytes32[] calldata peaks,
        bytes32[] calldata siblings
    ) external view returns (bool);

    function getFinalizedBlockNumber() external view returns (uint256);
}
