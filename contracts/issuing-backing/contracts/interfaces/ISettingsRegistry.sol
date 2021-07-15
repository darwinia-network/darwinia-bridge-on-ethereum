// SPDX-License-Identifier: MIT
pragma solidity >=0.4.24;

interface ISettingsRegistry {
    function uintOf(bytes32 _propertyName) external view returns (uint256);
    function addressOf(bytes32 _propertyName) external view returns (address);
}
