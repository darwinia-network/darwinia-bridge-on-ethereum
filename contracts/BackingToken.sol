pragma solidity >=0.5.0 <0.6.0;

import "./common/Ownable.sol";

contract BackingToken is Ownable {
    event Backing(address indexed previousOwner, address indexed newOwner);

    mapping(address => bool) public supportedTokens;

    function addSupportedToken(address _token) public onlyOwner {
        supportedTokens[_token] = true;
    }

    function removeSupportedToken(address _token) public onlyOwner {
        supportedTokens[_token] = false;
    }
}
