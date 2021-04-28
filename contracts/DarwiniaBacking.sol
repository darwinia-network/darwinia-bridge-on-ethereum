// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "@openzeppelin/contracts/proxy/Initializable.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "./common/Ownable.sol";
import "./interfaces/IERC20Option.sol";

contract DarwiniaBacking is Initializable, Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    address public constant BACKING_PRECOMPILE = 0x0000000000000000000000000000000000000018;

    // token-address => timestamp
    mapping(address => uint256) public assets;

    struct Fee {
        address token;
        uint256 fee;
    }
    Fee public registerFee;
    Fee public transferFee;

    event NewTokenRegistered(address indexed token, string name, string symbol, uint8 decimals);
    event BackingLock(uint32 indexed chainId, address indexed token, address receiver, uint256 amount);
    event BackingUnlock(address token, address recipient, uint256 amount);

    function initialize(address _registerFeeToken, address _transferFeeToken) public initializer {
        ownableConstructor();
        registerFee = Fee(_registerFeeToken, 0);
        transferFee = Fee(_transferFeeToken, 0);
    }

    /**
     * @dev Throws if called by any account other than the system account defined by 0x0 address.
     */
    modifier onlySystem() {
        require(address(0) == msg.sender, "System: caller is not the system account");
        _;
    }

    function setRegisterFee(address token, uint256 fee) external onlyOwner {
        registerFee.token = token;
        registerFee.fee = fee;
    }

    function setTransferFee(address token, uint256 fee) external onlyOwner {
        transferFee.token = token;
        transferFee.fee = fee;
    }

    function registerToken(address token) external {
        require(assets[token] == 0, "asset has been registered");
        if (registerFee.fee > 0) {
            IERC20(registerFee.token).safeTransferFrom(msg.sender, address(this), registerFee.fee);
            IERC20Option(registerFee.token).burn(address(this), registerFee.fee);
        }
        assets[token] = block.timestamp;

        string memory name = IERC20Option(token).name();
        string memory symbol = IERC20Option(token).symbol();
        uint8 decimals = IERC20Option(token).decimals();
        (bool success, ) = BACKING_PRECOMPILE.call(abi.encode(bytes4(keccak256("register(address)")), token, name, symbol, uint256(decimals)));
        require(success, "register: call backing precompile failed");
        emit NewTokenRegistered(
            token,
            name,
            symbol,
            decimals
        );
    }

    function lock(uint32 chainId, address token, address recipient, uint256 amount) external {
        require(amount > 0, "balance is zero");
        require(assets[token] != 0, "asset has not been registered");
        IERC20(token).safeTransferFrom(msg.sender, address(this), amount);
        if (transferFee.fee > 0) {
            IERC20(transferFee.token).safeTransferFrom(msg.sender, address(this), transferFee.fee);
            IERC20Option(transferFee.token).burn(address(this), transferFee.fee);
        }
        (bool success, ) = BACKING_PRECOMPILE.call(abi.encode(bytes4(keccak256("lock(uint32,address,address,uint256)")), chainId, token, recipient, amount));
        require(success, "lock: call backing precompile failed");
        emit BackingLock(chainId, token, recipient, amount);
    }

    // the unlock proof has been verified by system pallet
    function unlock(address token, address recipient, uint256 amount) external onlySystem {
        require(amount > 0, "balance is zero");
        IERC20(token).safeTransferFrom(address(this), recipient, amount);
        emit BackingUnlock(token, recipient, amount);
    }
}
