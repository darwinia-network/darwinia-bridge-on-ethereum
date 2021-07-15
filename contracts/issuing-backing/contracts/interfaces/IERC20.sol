// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.7.0;

interface IERC20 {
  function totalSupply() external view returns (uint256);
  function balanceOf(address _who) external view returns (uint256);
  function transfer(address _to, uint256 _value) external returns (bool);
  function transferFrom(address _from, address _to, uint256 _value) external returns (bool);
  function mint(address _to, uint256 _value) external;
  function burn(address _from, uint256 _value) external;
  event Transfer(address indexed from, address indexed to, uint256 value);
}
