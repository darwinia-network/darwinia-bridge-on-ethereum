// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.7.0;

import "@openzeppelin/contracts/proxy/Initializable.sol";
import "@darwinia/contracts-utils/contracts/Ownable.sol";
import "@darwinia/contracts-utils/contracts/Pausable.sol";
import "@darwinia/contracts-utils/contracts/DailyLimit.sol";
import "@darwinia/contracts-bridge/contracts/interfaces/IRelay.sol";
import "@darwinia/contracts-utils/contracts/Scale.sol";
import "@darwinia/contracts-utils/contracts/SafeMath.sol";
import { ScaleStruct } from "@darwinia/contracts-utils/contracts/Scale.struct.sol";
import "../interfaces/IERC20.sol";
import "../interfaces/ISettingsRegistry.sol";

pragma experimental ABIEncoderV2;

contract TokenIssuing is DailyLimit, Ownable, Pausable, Initializable {

    event MintRingEvent(address recipient, uint256 value, bytes32 accountId);
    event MintKtonEvent(address recipient, uint256 value, bytes32 accountId);
    event MintTokenEvent(address token, address recipient, uint256 value, bytes32 accountId);
    event VerifyProof(uint32 darwiniaBlockNumber);

    bytes public storageKey;

    ISettingsRegistry public registry;
    IRelay public relay;

    // Record the block height that has been verified
    mapping(uint32 => bool) history;

    function initialize(address _registry, address _relay, bytes memory _key) public initializer {
        ownableConstructor();
        pausableConstructor();

        relay = IRelay(_relay);
        registry = ISettingsRegistry(_registry);

        storageKey = _key;
    }

    function getHistory(uint32 blockNumber) public view returns (bool) {
      return history[blockNumber];
    }

    // The last step of the cross-chain of darwinia to ethereum, the user needs to collect some signatures and proofs after the darwinia network lock token.
    // This call will append mmr root and verify mmr proot, events proof, and mint token by decoding events. If this mmr root is already included in the relay contract, the contract will skip verifying mmr root msg, saving gas.

    // message - bytes4 prefix + uint32 mmr-index + bytes32 mmr-root
    // signatures - the signatures for mmr-root msg
    // root, MMRIndex - mmr root for the block
    // blockNumber, blockHeader - The block where the lock token event occurred in darwinia network
    // can be fetched by api.rpc.chain.getHeader('block hash') 
    // peaks, siblings - mmr proof for the blockNumber
    // eventsProofStr - mpt proof for events
    // Vec<Vec<u8>> encoded by Scale codec
    function appendRootAndVerifyProof(
        bytes memory message,
        bytes[] memory signatures,
        bytes32 root,
        uint32 MMRIndex,
        bytes memory blockHeader,
        bytes32[] memory peaks,
        bytes32[] memory siblings,
        bytes memory eventsProofStr
    )
      public
      whenNotPaused
    {
      // If the root of this index already exists in the mmr root pool, 
      // skip append root to save gas
      if(relay.getMMRRoot(MMRIndex) == bytes32(0)) {
        relay.appendRoot(message, signatures);
      }

      verifyProof(root, MMRIndex, blockHeader, peaks, siblings, eventsProofStr);
    }

    function verifyProof(
        bytes32 root,
        uint32 MMRIndex,
        bytes memory blockHeader,
        bytes32[] memory peaks,
        bytes32[] memory siblings,
        bytes memory eventsProofStr
    ) 
      public
      whenNotPaused
    {
        uint32 blockNumber = Scale.decodeBlockNumberFromBlockHeader(blockHeader);

        require(!history[blockNumber], "TokenIssuing:: verifyProof:  The block has been verified");

        Input.Data memory data = Input.from(relay.verifyRootAndDecodeReceipt(root, MMRIndex, blockNumber, blockHeader, peaks, siblings, eventsProofStr, storageKey));
        
        ScaleStruct.LockEvent[] memory events = Scale.decodeLockEvents(data);

        address ring = registry.addressOf(bytes32("CONTRACT_RING_ERC20_TOKEN"));
        address kton = registry.addressOf(bytes32("CONTRACT_KTON_ERC20_TOKEN"));

        uint256 len = events.length;

        for( uint i = 0; i < len; i++ ) {
          ScaleStruct.LockEvent memory item = events[i];
          uint256 value = decimalsConverter(item.value);
          if(item.token == ring) {
            expendDailyLimit(ring, value);
            IERC20(ring).mint(item.recipient, value);

            emit MintRingEvent(item.recipient, value, item.sender);
          }

          if (item.token == kton) {
            expendDailyLimit(kton, value);
            IERC20(kton).mint(item.recipient, value);

            emit MintKtonEvent(item.recipient, value, item.sender);
          }
        }

        history[blockNumber] = true;
        emit VerifyProof(blockNumber);
    }

    // The token decimals in Crab, Darwinia Netowrk is 9, in Ethereum Network is 18.
    function decimalsConverter(uint256 darwiniaValue) public pure returns (uint256) {
      return SafeMath.mul(darwiniaValue, 1000000000);
    }

    /// ==== onlyOwner ==== 
    function setStorageKey(bytes memory key) public onlyOwner {
      storageKey = key;
    } 

    function unpause() public onlyOwner {
        _unpause();
    }

    function pause() public onlyOwner {
        _pause();
    }

    function setDailyLimit(address token, uint amount) public onlyOwner  {
        _setDailyLimit(token, amount);
    }

    function changeDailyLimit(address token, uint amount) public onlyOwner  {
        _changeDailyLimit(token, amount);
    }
}
