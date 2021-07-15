// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0;

interface IWETH {
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint) external;
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address guy, uint wad) external returns (bool);
}
