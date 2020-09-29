pragma solidity >=0.5.0 <0.6.0;

import "./Blake2b.sol";
import "./common/Ownable.sol";
import "./common/Pausable.sol";

import "./MMR.sol";

contract POARelay is Ownable, Pausable {
    event UpdateRootEvent(address relayer, bytes32 root, uint256 width);
    event ResetRootEvent(address owner, bytes32 root, uint256 width);

    using Blake2b for Blake2b.Instance;
    mapping(uint256 => bytes32) public mmrRootPool;
    mapping(address => bool) public relayer;
    mapping(address => bool) public admin;
    uint256 public latestBlockNumber;

    modifier auth() {
        require(
            relayer[_msgSender()] == true || owner() == _msgSender(),
            "Ownable: caller is not the relayer or owner"
        );
        _;
    }

    function getMMR(uint256 _width) public returns (bytes32) {
        return mmrRootPool[_width];
    }

    function isRelayer(address _relayer) public returns (bool) {
        return relayer[_relayer];
    }

    function Blake2bHash(bytes memory input) private view returns (bytes32) {
        Blake2b.Instance memory instance = Blake2b.init(hex"", 32);
        return bytesToBytes32(instance.finalize(input), 0);
    }

    function bytesToBytes32(bytes memory b, uint256 offset)
        private
        pure
        returns (bytes32)
    {
        bytes32 out;

        for (uint256 i = 0; i < 32; i++) {
            out |= bytes32(b[offset + i] & 0xFF) >> (i * 8);
        }
        return out;
    }

    function inclusionProof(
        bytes32 root,
        uint256 width,
        uint256 index,
        bytes memory value,
        bytes32 valueHash,
        bytes32[] memory peaks,
        bytes32[] memory siblings
    ) private returns (bool) {
        return
            MMR.inclusionProof(
                root,
                width,
                index,
                value,
                valueHash,
                peaks,
                siblings
            );
    }

    function verifyReceiptProof() public returns (bool) {
        return true;
    }

    function updateRoot(uint256 width, bytes32 root) public auth whenNotPaused {
        require(mmrRootPool[width] == bytes32(0), "Width has been set");
        mmrRootPool[width] = root;
        emit UpdateRootEvent(_msgSender(), root, width);
    }

    function resetRoot(uint256 width, bytes32 root) public onlyOwner {
        _pause();
        mmrRootPool[width] = root;
        emit ResetRootEvent(_msgSender(), root, width);
    }

    function decodeCompactU8aOffset(bytes1 input0) public pure returns (uint8) {
        bytes1 flag = input0 & bytes1(hex"03");
        if (flag == hex"00") {
            return 1;
        } else if (flag == hex"01") {
            return 2;
        } else if (flag == hex"02") {
            return 4;
        }
        uint8 offset = (uint8(input0) >> 2) + 4 + 1;
        return offset;
    }

    function getStateRootFromBlockHeader(
        uint256 width,
        bytes memory encodedHeader
    ) public pure returns (bytes32) {
        // require(mmrRootPool[width] != bytes32(0x0), "Invalid width");
        // bytes32 inputHash = Blake2bHash(encodedHeader);
        bytes32 state_root;
        uint8 offset = decodeCompactU8aOffset(encodedHeader[32]);
        assembly {
            state_root := mload(add(add(encodedHeader, 0x40), offset))
        }
        return state_root;
    }

    function unpause() public {
        _unpause();
    }

    function pause() public {
        _pause();
    }
}
