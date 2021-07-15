pragma solidity ^0.4.24;

import "./DSAuth.sol";
import "./ERC20/ERC20.sol";
import "../interfaces/IBurnableERC20.sol";
import "../interfaces/ISettingsRegistry.sol";
import "./SettingIds.sol";

contract TokenBurnDrop is DSAuth, SettingIds {
    // claimedToken event
    event ClaimedTokens(address indexed token, address indexed owner, uint amount);

    // burndropTokens event
    event RingBurndropTokens(address indexed token, address indexed owner, uint amount, bytes data);

    event KtonBurndropTokens(address indexed token, address indexed owner, uint amount, bytes data);

    ISettingsRegistry public registry;

    byte public SS58_PREFIX_DARWINIA = 0x2a;

    function initializeContract(address _registry) public onlyOwner{
        registry = ISettingsRegistry(_registry);
    }

    /**
    * @dev ERC223 fallback function, make sure to check the msg.sender is from target token contracts
    * @param _from - person who transfer token in for deposits or claim deposit with penalty KTON.
    * @param _amount - amount of token.
    * @param _data - data which indicate the operations.
    */
    function tokenFallback(address _from, uint256 _amount, bytes _data) public {
        bytes32 darwiniaAddress;

        assembly {
            let ptr := mload(0x40)
            calldatacopy(ptr, 0, calldatasize)
            darwiniaAddress := mload(add(ptr, 133))
        }

        address ring = registry.addressOf(SettingIds.CONTRACT_RING_ERC20_TOKEN);
        address kryptonite = registry.addressOf(SettingIds.CONTRACT_KTON_ERC20_TOKEN);

        require((msg.sender == ring) || (msg.sender == kryptonite), "Permission denied");

        require(_data.length == 33, "The address (Darwinia Network) must be in a 33 bytes hexadecimal format");
        require(byte(_data[0]) == SS58_PREFIX_DARWINIA, "Darwinia Network Address ss58 prefix is 42");
        require(darwiniaAddress != bytes32(0x0), "Darwinia Network Address can't be empty");

        //  burndrop ring
        if(ring == msg.sender) {
            IBurnableERC20(ring).burn(address(this), _amount);
            emit RingBurndropTokens(msg.sender, _from, _amount, _data);
        }

        //  burndrop kton
        if (kryptonite == msg.sender) {
            IBurnableERC20(kryptonite).burn(address(this), _amount);
            emit KtonBurndropTokens(msg.sender, _from, _amount, _data);
        }
    }

    /// @notice This method can be used by the owner to extract mistakenly
    ///  sent tokens to this contract.
    /// @param _token The address of the token contract that you want to recover
    ///  set to 0 in case you want to extract ether.
    function claimTokens(address _token) public auth {
        if (_token == 0x0) {
            owner.transfer(address(this).balance);
            return;
        }
        ERC20 token = ERC20(_token);
        uint balance = token.balanceOf(address(this));
        token.transfer(owner, balance);

        emit ClaimedTokens(_token, owner, balance);
    }
}
