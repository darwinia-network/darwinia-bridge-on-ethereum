pragma solidity ^0.4.24;

contract IAuthority {
    function canCall(
        address src, address dst, bytes4 sig
    ) public view returns (bool);
}