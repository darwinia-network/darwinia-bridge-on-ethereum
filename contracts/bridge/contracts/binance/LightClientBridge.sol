// SPDX-License-Identifier: Apache-2.0

pragma solidity >=0.6.0 <0.7.0;
pragma experimental ABIEncoderV2;

import "@darwinia/contracts-utils/contracts/ECDSA.sol";
import "@darwinia/contracts-utils/contracts/Bitfield.sol";
import "@darwinia/contracts-verify/contracts/MerkleProof.sol";
import "@darwinia/contracts-verify/contracts/KeccakMMR.sol";
import "./ValidatorRegistry.sol";

contract LightClientBridge is Bitfield, ValidatorRegistry {

    /* Events */

    /**
     * @notice Notifies an observer that the prover's attempt at initital
     * verification was successful.
     * @dev Note that the prover must wait until `n` blocks have been mined
     * subsequent to the generation of this event before the 2nd tx can be sent
     * @param prover The address of the calling prover
     * @param blockNumber The blocknumber in which the initial validation
     * succeeded
     * @param id An identifier to provide disambiguation
     */
    event InitialVerificationSuccessful(
        address prover,
        uint256 blockNumber,
        uint256 id
    );

    /**
     * @notice Notifies an observer that the complete verification process has
     *  finished successfuly and the new commitmentHash will be accepted
     * @param prover The address of the successful prover
     * @param id the identifier used
     */
    event FinalVerificationSuccessful(
        address prover,
        uint256 id
    );

    event NewMMRRoot(bytes32 mmrRoot, uint256 blockNumber);

    /* Types */

    struct NextValidatorSet {
        uint64 id;
        uint32 len; 
        bytes32 root;
    }

    struct Payload {
        bytes32 mmr;
        NextValidatorSet nextValidatorSet; 
    }

    /**
     * The Commitment, with its payload, is the core thing we are trying to verify with this contract.
     * It contains a next validator set or not and a MMR root that commits to the darwinia history,
     * including past blocks and can be used to verify darwinia blocks. 
     * @param payload the payload of the new commitment in beefy justifications (in
     * our case, this is a next validator set and a new MMR root for all past darwinia blocks)
     * @param blockNumber block number for the given commitment
     * @param validatorSetId validator set id that signed the given commitment
     */
    struct Commitment {
        Payload payload;
        uint32 blockNumber;
        uint64 validatorSetId;
    }

    /**
     * The ValidatorProof is a collection of proofs used to verify the signatures from the validators signing
     * each new justification.
     * @param signatures an array of signatures from the randomly chosen validators
     * @param positions an array of the positions of the randomly chosen validators
     * @param signers an array of the address of each signer
     * @param signerProofs an array of merkle proofs from the chosen validators proving that their addresses
     * are in the validator set
     */
    struct ValidatorProof {
        bytes[] signatures;
        uint256[] positions;
        address[] signers;
        bytes32[][] signerProofs;
    }

    /**
     * The ValidationData is the set of data used to link each pair of initial and complete verification transactions.
     * @param senderAddress the sender of the initial transaction
     * @param commitmentHash the hash of the commitment they are claiming has been signed
     * @param blockNumber the block number for this commitment
     * @param validatorClaimsBitfield a bitfield signalling which validators they claim have signed
     */
    struct ValidationData {
        address senderAddress;
        bytes32 commitmentHash;
        uint256 blockNumber;
        uint256[] validatorClaimsBitfield;
    }

    /* State */

    uint256 public currentId;
    bytes32 public latestMMRRoot;
    uint256 public latestBlockNumber;
    mapping(uint256 => ValidationData) public validationData;

    /* Constants */

    uint256 public constant PICK_NUMERATOR = 1;
    uint256 public constant THRESHOLD_NUMERATOR = 2;
    uint256 public constant THRESHOLD_DENOMINATOR = 3;
    uint256 public constant BLOCK_WAIT_PERIOD = 12;

    /**
     * @notice Deploys the LightClientBridge contract
     * @param validatorSetId initial validator set id
     * @param numOfValidators number of initial validator set
     * @param validatorSetRoot initial validator set merkle tree root
     */
    constructor(uint256 validatorSetId, uint256 numOfValidators, bytes32 validatorSetRoot) public {
        _update(validatorSetId, numOfValidators, validatorSetRoot);
    }

    /* Public Functions */

    function getFinalizedBlockNumber() external view returns (uint256) {
        return latestBlockNumber;
    }

    function validatorBitfield(uint256 id) external view returns (uint256[] memory) {
        return validationData[id].validatorClaimsBitfield; 
    }

    function requiredNumberOfSignatures() public view returns (uint256) {
        return (numOfValidators * PICK_NUMERATOR) / THRESHOLD_DENOMINATOR;
    }

    function createRandomBitfield(uint256 id)
        public
        view
        returns (uint256[] memory)
    {
        ValidationData storage data = validationData[id];

        require(data.blockNumber > 0, "Bridge: invalid id");

        /**
         * @dev verify that block wait period has passed
         */
        require(
            block.number >= data.blockNumber + BLOCK_WAIT_PERIOD,
            "Bridge: Block wait period not over"
        );

        return
            randomNBitsWithPriorCheck(
                getSeed(data.blockNumber),
                data.validatorClaimsBitfield,
                requiredNumberOfSignatures(),
                numOfValidators
            );
    }

    function createInitialBitfield(uint256[] calldata bitsToSet, uint256 length)
        external
        pure
        returns (uint256[] memory)
    {
        return createBitfield(bitsToSet, length);
    }

    function createCommitmentHash(Commitment memory commitment)
        public
        pure 
        returns (bytes32)
    {
        /**
         * Encode and hash the commitment
         */
        return keccak256(
                abi.encodePacked(
                    commitment.payload.mmr,
                    commitment.payload.nextValidatorSet.id,
                    commitment.payload.nextValidatorSet.len,
                    commitment.payload.nextValidatorSet.root,
                    commitment.blockNumber,
                    commitment.validatorSetId
                )
            );
    }

    /**
     * @notice Executed by the apps in order to verify commitment
     * @param beefyMMRLeafHash contains the merkle leaf hash
     * @param beefyMMRLeafIndex contains the merkle leaf index
     * @param beefyMMRLeafCount contains the merkle leaf count
     * @param peaks contains the merkle maintain range peaks
     * @param siblings contains the merkle maintain range siblings
     */
    function verifyBeefyMerkleLeaf(
        bytes32 beefyMMRLeafHash,
        uint256 beefyMMRLeafIndex,
        uint256 beefyMMRLeafCount,
        bytes32[] calldata peaks,
        bytes32[] calldata siblings 
    ) external view returns (bool) {
        return
            KeccakMMR.inclusionProof(
                latestMMRRoot,
                beefyMMRLeafCount,
                beefyMMRLeafIndex,
                beefyMMRLeafHash,
                peaks,
                siblings
            );
    }

    /**
     * @notice Executed by the prover in order to begin the process of block
     * acceptance by the light client
     * @param commitmentHash contains the commitmentHash signed by the validator(s)
     * @param validatorClaimsBitfield a bitfield containing a membership status of each
     * validator who has claimed to have signed the commitmentHash
     * @param validatorSignature the signature of one validator
     * @param validatorPosition the position of the validator, index starting at 0
     * @param validatorAddress the public key of the validator
     * @param validatorAddressMerkleProof proof required for validation of the public key in the validator merkle tree
     */
    function newSignatureCommitment(
        bytes32 commitmentHash,
        uint256[] memory validatorClaimsBitfield,
        bytes memory validatorSignature,
        uint256 validatorPosition,
        address validatorAddress,
        bytes32[] memory validatorAddressMerkleProof
    ) public returns (uint256) {
        /**
         * @dev Check that the bitfield actually contains enough claims to be succesful, ie, > 2/3
         */
        require(
            countSetBits(validatorClaimsBitfield) >
                (numOfValidators * THRESHOLD_NUMERATOR) /
                    THRESHOLD_DENOMINATOR,
            "Bridge: Bitfield not enough validators"
        );

        verifyValidatorSignature(
            validatorSignature,
            validatorPosition,
            validatorAddress,
            validatorAddressMerkleProof,
            commitmentHash
        );

        /**
         * @todo Lock up the sender stake as collateral
         */
        // TODO

        // Accept and save the commitment
        validationData[currentId] = ValidationData(
            msg.sender,
            commitmentHash,
            block.number,
            validatorClaimsBitfield
        );

        emit InitialVerificationSuccessful(msg.sender, block.number, currentId);

        currentId = currentId + 1;
        return currentId;
    }

    /**
     * @notice Performs the second step in the validation logic
     * @param id an identifying value generated in the previous transaction
     * @param commitment contains the full commitment that was used for the commitmentHash
     * @param validatorProof a struct containing the data needed to verify all validator signatures
     */
    function completeSignatureCommitment(
        uint256 id,
        Commitment memory commitment,
        ValidatorProof memory validatorProof
    ) public {
        // only current epoch
        require(commitment.validatorSetId == validatorSetId, "Bridge: Invalid validator set id");

        verifyCommitment(id, commitment, validatorProof);

        processPayload(commitment.payload, commitment.blockNumber);

        /**
         * @dev We no longer need the data held in state, so delete it for a gas refund
         */
        delete validationData[id];

        emit FinalVerificationSuccessful(msg.sender, id);
    }

    /* Private Functions */

    function verifyCommitment(
        uint256 id,
        Commitment memory commitment,
        ValidatorProof memory proof
    ) private view {
        ValidationData storage data = validationData[id];

        /**
         * @dev verify that sender is the same as in `newSignatureCommitment`
         */
        require(
            msg.sender == data.senderAddress,
            "Bridge: Sender address does not match original validation data"
        );

        /**
         * verify that block wait period has passed
         */
        require(
            block.number >= data.blockNumber + BLOCK_WAIT_PERIOD,
            "Bridge: Block wait period not over"
        );

        uint256 requiredNumOfSignatures = requiredNumberOfSignatures();

        uint256[] memory randomBitfield = randomNBitsWithPriorCheck(
            getSeed(data.blockNumber),
            data.validatorClaimsBitfield,
            requiredNumOfSignatures,
            numOfValidators
        );

        // Encode and hash the commitment
        bytes32 commitmentHash = createCommitmentHash(commitment);

        require(
            commitmentHash == data.commitmentHash,
            "Bridge: Commitment must match commitment hash"
        );

        verifyValidatorProofSignatures(
            randomBitfield,
            proof,
            requiredNumOfSignatures,
            commitmentHash
        );
    }

    function verifyValidatorProofSignatures(
        uint256[] memory randomBitfield,
        ValidatorProof memory proof,
        uint256 requiredNumOfSignatures,
        bytes32 commitmentHash
    ) private view {

        verifyValidatorProofLengths(requiredNumOfSignatures, proof);

        /**
         *  @dev For each randomSignature, do:
         */
        for (uint256 i = 0; i < requiredNumOfSignatures; i++) {
            uint256 pos = proof.positions[i];
            /**
             * @dev Check if validator in randomBitfield
             */
            require(
                isSet(randomBitfield, pos),
                "Bridge: Validator must be once in bitfield"
            );

            /**
             * @dev Remove validator from randomBitfield such that no validator can appear twice in signatures
             */
            clear(randomBitfield, pos);

            verifyValidatorSignature(
                proof.signatures[i],
                pos,
                proof.signers[i],
                proof.signerProofs[i],
                commitmentHash
            );
        }
    }

    function verifyValidatorProofLengths(
        uint256 requiredNumOfSignatures,
        ValidatorProof memory proof
    ) private pure {
        /**
         * @dev verify that required number of signatures, positions, public keys and merkle proofs are
         * submitted
         */
        require(
            proof.signatures.length == requiredNumOfSignatures,
            "Bridge: Number of signatures does not match required"
        );
        require(
            proof.positions.length == requiredNumOfSignatures,
            "Bridge: Number of validator positions does not match required"
        );
        require(
            proof.signers.length == requiredNumOfSignatures,
            "Bridge: Number of validator public keys does not match required"
        );
        require(
            proof.signerProofs.length == requiredNumOfSignatures,
            "Bridge: Number of validator public keys does not match required"
        );
    }

    function verifyValidatorSignature(
        bytes memory signature,
        uint256 position,
        address signer,
        bytes32[] memory addrMerkleProof,
        bytes32 commitmentHash
    ) private view {

        /**
         * @dev Check if merkle proof is valid
         */
        require(
            checkValidatorInSet(
                signer,
                position,
                addrMerkleProof
            ),
            "Bridge: Validator must be in validator set at correct position"
        );

        /**
         * @dev Check if signature is correct
         */
        require(
            ECDSA.recover(commitmentHash, signature) == signer,
            "Bridge: Invalid Signature"
        );
    }

    /**
     * @notice Deterministically generates a seed from the block hash at the block number of creation of the validation
     * @dev Note that `blockhash(blockNum)` will only work for the 256 most recent blocks. If
     * `completeSignatureCommitment` is called too late, a new call to `newSignatureCommitment` is necessary to reset
     * validation data's block number
     * @param blockNumber block number
     * @return onChainRandNums an array storing the random numbers generated inside this function
     */
    function getSeed(uint256 blockNumber)
        private
        view
        returns (uint256)
    {
        uint256 randomSeedBlockNum = blockNumber + BLOCK_WAIT_PERIOD;
        // @note Create a hash seed from the block number
        bytes32 randomSeedBlockHash = blockhash(randomSeedBlockNum);

        return uint256(randomSeedBlockHash);
    }

    /**
     * @notice Perform some operation[s] using the payload
     * @param payload The payload variable passed in via the initial function
     * @param blockNumber The blockNumber variable passed in via the initial function
     */
    function processPayload(Payload memory payload, uint256 blockNumber) private {
        // Check the payload is newer than the latest
        // Check that payload.leaf.block_number is > last_known_block_number;
        require(blockNumber > latestBlockNumber, "Bridge: Import old block");

        latestMMRRoot = payload.mmr;
        latestBlockNumber = blockNumber;

        applyValidatorSetChanges(
            payload.nextValidatorSet.id,
            payload.nextValidatorSet.len,
            payload.nextValidatorSet.root
        );
        emit NewMMRRoot(latestMMRRoot, blockNumber);
    }

    /**
     * @notice Check if the payload includes a new validator set,
     * and if it does then update the new validator set
     * @dev This function should call out to the validator registry contract
     * @param nextValidatorSetId The id of the next validator set
     * @param nextValidatorSetLen The number of validators in the next validator set
     * @param nextValidatorSetRoot The merkle root of the merkle tree of the next validators
     */
    function applyValidatorSetChanges(
        uint64 nextValidatorSetId,
        uint32 nextValidatorSetLen,
        bytes32 nextValidatorSetRoot
    ) private {
        // TODO: check nextValidatorSet can null or not
        require(nextValidatorSetId == 0 || nextValidatorSetId == validatorSetId + 1, "Bridge: Invalid next validator set id");
        if (nextValidatorSetId == validatorSetId + 1) {
            _update(
                nextValidatorSetId,
                nextValidatorSetLen,
                nextValidatorSetRoot
            );
        }
    }

}
