// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.7.0;

import "@openzeppelin/contracts/proxy/Initializable.sol";
import "@darwinia/contracts-utils/contracts/Blake2b.sol";
import "@darwinia/contracts-utils/contracts/Ownable.sol";
import "@darwinia/contracts-utils/contracts/Pausable.sol";
import "@darwinia/contracts-utils/contracts/ECDSA.sol";
import "@darwinia/contracts-utils/contracts/Hash.sol";
import "@darwinia/contracts-utils/contracts/SafeMath.sol";
import "@darwinia/contracts-utils/contracts/Input.sol";
import "@darwinia/contracts-utils/contracts/Bytes.sol";
import "@darwinia/contracts-verify/contracts/MMR.sol";
import "@darwinia/contracts-utils/contracts/Scale.sol";
import "@darwinia/contracts-verify/contracts/SimpleMerkleProof.sol";


pragma experimental ABIEncoderV2;

contract Relay is Ownable, Pausable, Initializable {
    using Bytes for bytes;

    event SetRootEvent(address relayer, bytes32 root, uint256 index);
    event SetAuthoritiesEvent(uint32 nonce, address[] authorities, bytes32 beneficiary);
    event ResetRootEvent(address owner, bytes32 root, uint256 index);
    event ResetAuthoritiesEvent(uint32 nonce, address[] authorities);

    ///
    /// Function: updateRelayer(bytes message, bytes[] signatures, bytes32 benefit)
    /// MethodID: 0xb4bcf497
    ///
    /// Function: appendRoot(bytes memory message,bytes[] memory signatures)
    /// MethodID: 0x479fbdf9
    ///

    struct Relayers {
        // Each time the relay set is updated, the nonce is incremented
        // After the first "updateRelayer" call, the nonce value is equal to 1,
        // which is different from the field "Term" at the node.
        address[] member;
        uint32 nonce;
        uint8 threshold;
    }

    Relayers relayers;

    // 'Crab', 'Darwinia', 'Pangolin'
    bytes private networkPrefix;

    // index => mmr root
    // In the Darwinia Network, the mmr root of block 1000
    // needs to be queried in Log-Other of block 1001.
    mapping(uint32 => bytes32) public mmrRootPool;

    // _MMRIndex - mmr index or block number corresponding to mmr root
    // _genesisMMRRoot - mmr root
    // _relayers - Keep the same as the "ethereumRelayAuthorities" module in darwinia network
    // _nonce - To prevent replay attacks
    // _threshold - The threshold for a given level can be set to any number from 0-100. This threshold is the amount of signature weight required to authorize an operation at that level.
    // _prefix - The known values are: "Pangolin", "Crab", "Darwinia"
    function initialize(
        uint32 _MMRIndex,
        bytes32 _genesisMMRRoot,
        address[] memory _relayers,
        uint32 _nonce,
        uint8 _threshold,
        bytes memory _prefix
    ) public initializer {
        ownableConstructor();
        pausableConstructor();

        _appendRoot(_MMRIndex, _genesisMMRRoot);
        _resetRelayer(_nonce, _relayers);
        _setNetworkPrefix(_prefix);
        _setRelayThreshold(_threshold);
    }

    /// ==== Getters ====
    function getRelayerCount() public view returns (uint256) {
        return relayers.member.length;
    }

    function getRelayerNonce() public view returns (uint32) {
        return relayers.nonce;
    }

    function getRelayer() public view returns (address[] memory) {
        return relayers.member;
    }

    function getNetworkPrefix() public view returns (bytes memory) {
        return networkPrefix;
    }

    function getRelayerThreshold() public view returns (uint8) {
        return relayers.threshold;
    }

    function getMMRRoot(uint32 index) public view returns (bytes32) {
        return mmrRootPool[index];
    }

    function getLockTokenReceipt(bytes32 root, bytes memory eventsProofStr, bytes memory key)
        public
        view
        whenNotPaused
        returns (bytes memory)
    {
        Input.Data memory data = Input.from(eventsProofStr);

        bytes[] memory proofs = Scale.decodeReceiptProof(data);
        bytes memory result = SimpleMerkleProof.getEvents(root, key, proofs);

        return result;
    }

    function isRelayer(address addr) public view returns (bool) {
        for (uint256 i = 0; i < relayers.member.length; i++) {
            if (addr == relayers.member[i]) {
                return true;
            }
        }
        return false;
    }

    function checkNetworkPrefix(bytes memory prefix) view public returns (bool) {
        return getNetworkPrefix().equals(prefix);
    }

    function checkRelayerNonce(uint32 nonce) view public returns (bool) {
      return nonce == getRelayerNonce();
    }

    /// ==== Setters ====

    // When the darwinia network authorities set is updated, bridger or other users need to submit the new authorities set to the reporter contract by calling this method.
    // message - prefix + nonce + [...relayers]
    // struct{vec<u8>, u32, vec<EthereumAddress>}
    // signatures - signed by personal_sign
    // beneficiary - Keeping the authorities set up-to-date is advocated between the relay contract contract and the darwinia network, and the darwinia network will give partial rewards to the benefit account. benefit is the public key of a darwinia network account
    function updateRelayer(
        bytes memory message,
        bytes[] memory signatures,
        bytes32 beneficiary
    ) public whenNotPaused {
        // verify hash, signatures (The number of signers must be greater than _threshold)
        require(
            _checkSignature(message, signatures),
            "Relay: Bad relayer signature"
        );

        // decode message, check nonce and relayer
        Input.Data memory data = Input.from(message);
        (bytes memory prefix, bytes4 methodID, uint32 nonce, address[] memory authorities) = Scale.decodeAuthorities(
            data
        );

        require(checkNetworkPrefix(prefix), "Relay: Bad network prefix");
        require(methodID == hex"b4bcf497", "Relay: Bad method ID");
        require(checkRelayerNonce(nonce), "Relay: Bad relayer set nonce");

        // update nonce,relayer
        _updateRelayer(nonce, authorities, beneficiary);
    }

    // Add a mmr root to the mmr root pool
    // message - bytes4 prefix + uint32 mmr-index + bytes32 mmr-root
    // struct{vec<u8>, u32, H256}
    // encode by scale codec
    // signatures - The signature for message
    // https://github.com/darwinia-network/darwinia-common/pull/381
    function appendRoot(
        bytes memory message,
        bytes[] memory signatures
    ) public whenNotPaused {
        // verify hash, signatures
        require(
            _checkSignature(message, signatures),
            "Relay: Bad relayer signature"
        );

        // decode message, check nonce and relayer
        Input.Data memory data = Input.from(message);
        (bytes memory prefix, bytes4 methodID, uint32 index, bytes32 root) = Scale.decodeMMRRoot(data);

        require(checkNetworkPrefix(prefix), "Relay: Bad network prefix");
        require(methodID == hex"479fbdf9", "Relay: Bad method ID");

        // append index, root
        _appendRoot(index, root);
    }

    function verifyRootAndDecodeReceipt(
        bytes32 root,
        uint32 MMRIndex,
        uint32 blockNumber,
        bytes memory blockHeader,
        bytes32[] memory peaks,
        bytes32[] memory siblings,
        bytes memory eventsProofStr,
        bytes memory key
    ) public view whenNotPaused returns (bytes memory){
        // verify block proof
        require(
            verifyBlockProof(root, MMRIndex, blockNumber, blockHeader, peaks, siblings),
            "Relay: Block header proof varification failed"
        );

        // get state root
        bytes32 stateRoot = Scale.decodeStateRootFromBlockHeader(blockHeader);

        return getLockTokenReceipt(stateRoot, eventsProofStr, key);
    }

    function verifyBlockProof(
        bytes32 root,
        uint32 MMRIndex,
        uint32 blockNumber,
        bytes memory blockHeader,
        bytes32[] memory peaks,
        bytes32[] memory siblings
    ) public view whenNotPaused returns (bool) {
        require(
            getMMRRoot(MMRIndex) != bytes32(0),
            "Relay: Not registered under this index"
        );
        require(
            getMMRRoot(MMRIndex) == root,
            "Relay: Root is different from the root pool"
        );

        return MMR.inclusionProof(root, MMRIndex + 1, blockNumber, blockHeader, peaks, siblings);
    }


    /// ==== onlyOwner ====
    function resetRoot(uint32 index, bytes32 root) public onlyOwner {
        _setRoot(index, root);
        emit ResetRootEvent(_msgSender(), root, index);
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function pause() public onlyOwner {
        _pause();
    }

    function resetNetworkPrefix(bytes memory _prefix) public onlyOwner {
        _setNetworkPrefix(_prefix);
    }

    function resetRelayerThreshold(uint8 _threshold) public onlyOwner {
        _setRelayThreshold(_threshold);
    }

    function resetRelayer(uint32 nonce, address[] memory accounts) public onlyOwner {
        _resetRelayer(nonce, accounts);
    }

    /// ==== Internal ====
    function _updateRelayer(uint32 nonce, address[] memory accounts, bytes32 beneficiary) internal {
        require(accounts.length > 0, "Relay: accounts is empty");

        emit SetAuthoritiesEvent(nonce, accounts, beneficiary);

        relayers.member = accounts;
        relayers.nonce = getRelayerNonce() + 1;
    }

    function _resetRelayer(uint32 nonce, address[] memory accounts) internal {
        require(accounts.length > 0, "Relay: accounts is empty");
        relayers.member = accounts;
        relayers.nonce = nonce;

        emit ResetAuthoritiesEvent(nonce, accounts);
    }

    function _appendRoot(uint32 index, bytes32 root) internal {
        require(getMMRRoot(index) == bytes32(0), "Relay: Index has been set");

        _setRoot(index, root);
    }

    function _setRoot(uint32 index, bytes32 root) internal {
        mmrRootPool[index] = root;
        emit SetRootEvent(_msgSender(), root, index);
    }

    function _setNetworkPrefix(bytes memory prefix) internal {
        networkPrefix = prefix;
    }

    function _setRelayThreshold(uint8 _threshold) internal {
        require(_threshold > 0, "Relay:: _setRelayThreshold: _threshold equal to 0");
        relayers.threshold = _threshold;
    }

    // This method verifies the content of msg by verifying the existing authority collection in the contract.
    // Ecdsa.recover can recover the signer’s address.
    // If the signer is matched "isRelayer", it will be counted as a valid signature
    // and all signatures will be restored.
    // If the number of qualified signers is greater than Equal to threshold,
    // the verification is considered successful, otherwise it fails
    function _checkSignature(
        bytes memory message,
        bytes[] memory signatures
    ) internal view returns (bool) {
        require(signatures.length != 0, "Relay:: _checkSignature: signatures is empty");
        bytes32 hash = keccak256(message);
        uint256 count;
        address[] memory signers = new address[](signatures.length);
        bytes32 ethSignedMessageHash = ECDSA.toEthSignedMessageHash(hash);

        for (uint256 i = 0; i < signatures.length; i++) {
            address signer = ECDSA.recover(ethSignedMessageHash, signatures[i]);
            signers[i] = signer;
        }

        require(!hasDuplicate(signers), "Relay:: hasDuplicate: Duplicate entries in list");

        for (uint256 i = 0; i < signatures.length; i++) {
            if (isRelayer(signers[i])) {
               count++;
            }
        }

        uint8 threshold = uint8(
            SafeMath.div(SafeMath.mul(count, 100), getRelayerCount())
        );

        return threshold >= getRelayerThreshold();
    }

    /**
    * Returns whether or not there's a duplicate. Runs in O(n^2).
    * @param A Array to search
    * @return Returns true if duplicate, false otherwise
    */
    function hasDuplicate(address[] memory A) internal pure returns (bool) {
        if (A.length == 0) {
            return false;
        }
        for (uint256 i = 0; i < A.length - 1; i++) {
            for (uint256 j = i + 1; j < A.length; j++) {
                if (A[i] == A[j]) {
                    return true;
                }
            }
        }
        return false;
    }
}
