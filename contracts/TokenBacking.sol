// SPDX-License-Identifier: MIT

pragma solidity >=0.5.0 <0.6.0;

import "./common/Ownable.sol";
import "./common/Pausable.sol";
import "./interfaces/IRelay.sol";
import "./interfaces/IERC20.sol";
import "./interfaces/ISettingsRegistry.sol";

// import "./common/Input.sol";
import "./common/Scale.sol";
import "./common/SafeMath.sol";

pragma experimental ABIEncoderV2;

contract TokenBacking is Ownable, Pausable {
    using Input for Input.Data;

    event MintRingEvent(address recipient, uint256 value, bytes32 accountId);
    event MintKtonEvent(address recipient, uint256 value, bytes32 accountId);
    event MintTokenEvent(address token, address recipient, uint256 value, bytes32 accountId);

    ISettingsRegistry public registry;
    IRelay public relay;
    IERC20 public ring;
    IERC20 public kton;

    // Record the block height that has been verified
    mapping(uint32 => bool) history;

    function initializeContract(address _registry, address _relay) public onlyOwner {
        relay = IRelay(_relay);
        registry = ISettingsRegistry(_registry);

        // bytes32 CONTRACT_RING_ERC20_TOKEN = 0x434f4e54524143545f52494e475f45524332305f544f4b454e00000000000000;
        // bytes32 CONTRACT_KTON_ERC20_TOKEN = 0x434f4e54524143545f4b544f4e5f45524332305f544f4b454e00000000000000;

        // ring = IERC20(registry.addressOf(CONTRACT_RING_ERC20_TOKEN));
        // kton = IERC20(registry.addressOf(CONTRACT_KTON_ERC20_TOKEN));
    }

    function verifyProof(
        bytes32 root,
        uint32 MMRIndex,
        uint32 blockNumber,
        bytes memory blockHeader,
        bytes32[] memory peaks,
        bytes32[] memory siblings,
        bytes memory proofstr,
        bytes memory key
    ) 
      public
      whenNotPaused
    {
        require(!history[blockNumber], "TokenBacking:: verifyProof:  The block has been verifiee");

        bytes memory eventsData = relay.verifyAndDecodeReceipt(root, MMRIndex, blockNumber, blockHeader, peaks, siblings, proofstr, key);
        Input.Data memory data = Input.from(eventsData);
        
        Scale.LockEvent[] memory events = Scale.decodeLockEvents(data);

        uint256 len = events.length;

        for( uint i = 0; i < len; i++ ) {
          Scale.LockEvent memory item = events[i];
          if(item.token == 0) {
            // ring.mint(item.recipient, decimalsConverter(item.value));
            emit MintRingEvent(item.recipient, item.value, item.sender);
          }

          if (item.token == 1) {
            // kton.mint(item.recipient, decimalsConverter(item.value));
            emit MintKtonEvent(item.recipient, item.value, item.sender);
          }
        }

        history[blockNumber] = true;
    }

    // The token decimals in Crab, Darwinia Netowrk is 9, Ethereum is 18.
    function decimalsConverter(uint256 darwiniaValue) public pure returns (uint256) {
      return SafeMath.mul(darwiniaValue, 1000000000);
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function pause() public onlyOwner {
        _pause();
    }
}