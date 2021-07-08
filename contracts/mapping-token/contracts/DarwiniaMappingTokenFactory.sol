// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "@openzeppelin/contracts/proxy/Initializable.sol";
import "@openzeppelin/contracts/proxy/TransparentUpgradeableProxy.sol";
import "@darwinia/contracts-utils/contracts/Ownable.sol";
import "./interfaces/IERC20.sol";

contract DarwiniaMappingTokenFactory is Initializable, Ownable {
    address public constant DISPATCH_ENCODER = 0x0000000000000000000000000000000000000018;
    address public constant DISPATCH         = 0x0000000000000000000000000000000000000019;
    struct TokenInfo {
        bytes4 eventReceiver;
        // 0 - Erc20Token
        // 1 - NativeToken
        // ...
        uint32  tokenType;
        address backing;
        address source;
    }
    address public admin;
    address[] public allTokens;
    mapping(bytes32 => address payable) public tokenMap;
    mapping(address => TokenInfo) public tokenToInfo;
    mapping(string => address) public logic;

    string constant LOGIC_ERC20 = "erc20";

    event NewLogicSetted(string name, address addr);
    event IssuingERC20Created(address indexed sender, address backing, address source, address token);

    receive() external payable {
    }

    function initialize() public initializer {
        ownableConstructor();
    }

    /**
     * @dev Throws if called by any account other than the system account defined by 0x0 address.
     */
    modifier onlySystem() {
        require(address(0) == msg.sender, "System: caller is not the system account");
        _;
    }

    function setAdmin(address _admin) external onlyOwner {
        admin = _admin;
    }

    function setERC20Logic(address _logic) external onlyOwner {
        logic[LOGIC_ERC20] = _logic;
        emit NewLogicSetted(LOGIC_ERC20, _logic);
    }

    function deploy(bytes32 salt, bytes memory code) internal returns (address payable addr) {
        bytes32 newsalt = keccak256(abi.encodePacked(salt, msg.sender));
        assembly {
            addr := create2(0, add(code, 0x20), mload(code), newsalt)
            if iszero(extcodesize(addr)) { revert(0, 0) }
        }
    }

    function createERC20Contract(
        bytes4 eventReceiver,
        uint32 tokenType,
        string memory name,
        string memory symbol,
        uint8 decimals,
        address backing,
        address source
    ) external onlySystem returns (address payable token) {
        bytes32 salt = keccak256(abi.encodePacked(backing, source));
        require(tokenMap[salt] == address(0), "contract has been deployed");
        bytes memory bytecode = type(TransparentUpgradeableProxy).creationCode;
        bytes memory erc20initdata =
            abi.encodeWithSignature("initialize(string,string,uint8)",
                                    name,
                                    symbol,
                                    decimals);
        bytes memory bytecodeWithInitdata = abi.encodePacked(bytecode, abi.encode(logic[LOGIC_ERC20], admin, erc20initdata));
        token = deploy(salt, bytecodeWithInitdata);
        tokenMap[salt] = token;
        allTokens.push(token);
        tokenToInfo[token] = TokenInfo(eventReceiver, tokenType, backing, source);

        (bool encodeSuccess, bytes memory encoded) = DISPATCH_ENCODER.call(
            abi.encodePacked(eventReceiver, bytes4(keccak256("registered(address,address,address)")),
                             abi.encode(backing, source, token)));
        require(encodeSuccess, "create: encode dispatch failed");

        (bool success, ) = DISPATCH.call(encoded);
        require(success, "create: call create erc20 precompile failed");
        emit IssuingERC20Created(msg.sender, backing, source, token);
    }

    function tokenLength() external view returns (uint) {
        return allTokens.length;
    }

    function mappingToken(address backing, address source) public view returns (address) {
        bytes32 salt = keccak256(abi.encodePacked(backing, source));
        return tokenMap[salt];
    }

    function crossReceive(address token, address recipient, uint256 amount) external onlySystem {
        require(amount > 0, "can not receive amount zero");
        TokenInfo memory info = tokenToInfo[token];
        require(info.source != address(0), "token is not created by factory");
        IERC20(token).mint(recipient, amount);
    }

    function crossTransfer(uint32 specVersion, uint64 weight, address token, bytes memory recipient, uint256 amount) external payable {
        require(amount > 0, "can not transfer amount zero");
        TokenInfo memory info = tokenToInfo[token];
        require(info.source != address(0), "token is not created by factory");
        require(IERC20(token).transferFrom(msg.sender, address(this), amount), "transfer token failed");
        IERC20(token).burn(address(this), amount);

        (bool encodeSuccess, bytes memory encoded) = DISPATCH_ENCODER.call(
            abi.encodePacked(info.eventReceiver, bytes4(keccak256("burned(address,address,address,address,uint256)")),
                           abi.encode(specVersion,
                                      weight,
                                      info.tokenType,
                                      info.backing,
                                      msg.sender,
                                      info.source,
                                      recipient,
                                      amount,
                                      msg.value)));
        require(encodeSuccess, "burn: encode dispatch failed");
        (bool success, ) = DISPATCH.call(encoded);
        require(success, "burn: call burn precompile failed");
    }
}

