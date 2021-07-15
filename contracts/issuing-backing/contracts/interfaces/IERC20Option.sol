// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

interface IERC20Option {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function mint(address _to, uint256 _value) external;
    function burn(address _from, uint256 _value) external;
}

