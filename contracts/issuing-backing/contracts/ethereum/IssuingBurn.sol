pragma solidity ^0.4.24;

import "./PausableDSAuth.sol";
import "./ERC20/ERC20.sol";
import "../interfaces/IBurnableERC20.sol";
import "../interfaces/ISettingsRegistry.sol";

contract Issuing is PausableDSAuth {
    // claimedToken event
    event ClaimedTokens(
        address indexed token,
        address indexed owner,
        uint256 amount
    );

    event BurnAndRedeem(
        address indexed token,
        address indexed from,
        uint256 amount,
        bytes receiver
    );

    ISettingsRegistry public registry;

    mapping(address => bool) public supportedTokens;

    constructor(address _registry) public {
        registry = ISettingsRegistry(_registry);
    }

    /**
     * @dev ERC223 fallback function, make sure to check the msg.sender is from target token contracts
     * @param _from - person who transfer token in for deposits or claim deposit with penalty KTON.
     * @param _amount - amount of token.
     * @param _data - data which indicate the operations.
     */
    function tokenFallback(
        address _from,
        uint256 _amount,
        bytes _data
    ) public whenNotPaused {
        bytes32 darwiniaAddress;

        assembly {
            let ptr := mload(0x40)
            calldatacopy(ptr, 0, calldatasize)
            darwiniaAddress := mload(add(ptr, 132))
        }

        //  Only supported tokens can be called
        require(supportedTokens[msg.sender], "Permission denied");
        require(
            _data.length == 32,
            "The address (Darwinia Network) must be in a 32 bytes hexadecimal format"
        );
        require(
            darwiniaAddress != bytes32(0),
            "Darwinia Network Address can't be empty"
        );

        // SettingIds.UINT_BRIDGE_FEE
        uint256 bridgeFee = registry.uintOf(
            0x55494e545f4252494447455f4645450000000000000000000000000000000000
        );

        // SettingIds.CONTRACT_BRIDGE_POOL
        address bridgePool = registry.addressOf(
            0x434f4e54524143545f4252494447455f504f4f4c000000000000000000000000
        );

        // SettingIds.CONTRACT_RING_ERC20_TOKEN
        address ring = registry.addressOf(
            0x434f4e54524143545f52494e475f45524332305f544f4b454e00000000000000
        );

        // BridgeFee will be paid to the relayer
        if (bridgeFee > 0) {
            require(
                ERC20(ring).transferFrom(_from, bridgePool, bridgeFee),
                "Error when paying transaction fees"
            );
        }

        IBurnableERC20(msg.sender).burn(address(this), _amount);
        emit BurnAndRedeem(msg.sender, _from, _amount, _data);
    }

    function addSupportedTokens(address _token) public auth {
        supportedTokens[_token] = true;
    }

    function removeSupportedTokens(address _token) public auth {
        supportedTokens[_token] = false;
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
        uint256 balance = token.balanceOf(address(this));
        token.transfer(owner, balance);

        emit ClaimedTokens(_token, owner, balance);
    }
}
