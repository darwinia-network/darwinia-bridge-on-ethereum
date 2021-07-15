// SPDX-License-Identifier: Apache-2.0

pragma solidity >=0.6.0 <0.7.0;
pragma experimental ABIEncoderV2;

import "@darwinia/contracts-verify/contracts/MerkleProof.sol";

/**
 * @title A contract storing state on the current validator set
 * @dev Stores the validator set as a Merkle root
 */
contract ValidatorRegistry {
    /* Events */

    event ValidatorRegistryUpdated(uint256 id, uint256 len, bytes32 root);

    /* State */

    uint256 public validatorSetId;
    uint256 public numOfValidators;
    bytes32 public validatorSetRoot;

    /**
     * @notice Updates the validator set
     * @param _validatorSetId The new validator set id
     * @param _numOfValidators The new number of validator set
     * @param _validatorSetRoot The new validator set root
     */
    function _update(uint256 _validatorSetId, uint256 _numOfValidators, bytes32 _validatorSetRoot) internal {
        validatorSetId = _validatorSetId;
        numOfValidators = _numOfValidators;
        validatorSetRoot = _validatorSetRoot;
        emit ValidatorRegistryUpdated(_validatorSetId, _numOfValidators, validatorSetRoot);
    }

    /**
     * @notice Checks if a validators address is a member of the merkle tree
     * @param addr The address of the validator to check
     * @param pos The position of the validator to check, index starting at 0
     * @param proof Merkle proof required for validation of the address
     * @return Returns true if the validator is in the set
     */
    function checkValidatorInSet(
        address addr,
        uint256 pos,
        bytes32[] memory proof
    ) public view returns (bool) {
        bytes32 hashedLeaf = keccak256(abi.encodePacked(addr));
        return
            MerkleProof.verifyMerkleLeafAtPosition(
                validatorSetRoot,
                hashedLeaf,
                pos,
                numOfValidators,
                proof
            );
    }
}
