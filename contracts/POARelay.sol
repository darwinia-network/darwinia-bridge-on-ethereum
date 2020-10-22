// SPDX-License-Identifier: MIT

pragma solidity >=0.5.0 <0.6.0;

import "./Blake2b.sol";
import "./common/Ownable.sol";
import "./common/Timelock.sol";
import "./common/Pausable.sol";


import "./MMR.sol";

contract POARelay is Ownable, Pausable, Timelock {
    event InsertRootEvent(address relayer, bytes32 root, uint256 width);
    event SetRootEvent(address relayer, bytes32 root, uint256 width);
    event ResetRootEvent(address owner, bytes32 root, uint256 width);
    event ResetLatestWidthEvent(address owner, uint256 width);

    using Blake2b for Blake2b.Instance;

    struct CandidateRoot {
        uint256 width;
        uint256 time;
        bytes32 data;
        bool dispute;
    }

    mapping(uint256 => bytes32) public mmrRootPool;
    
    mapping(address => bool) public relayer;
    mapping(address => bool) public supervisor;

    CandidateRoot public candidateRoot;

    // uint256 public latestBlockNumber;
    uint256 public latestWidth;

    constructor (uint256 _width, bytes32 _genesisMMRRoot, uint256 _minDelay, address[] memory _relayer, address[] memory _supervisor) public {
        _appendRoot(_width, _genesisMMRRoot);
        _updateDelay(_minDelay);

        for (uint256 i = 0; i < _relayer.length; ++i) {
            _setRelayer(_relayer[i]);
        }

        for (uint256 i = 0; i < _supervisor.length; ++i) {
            _setSupervisor(_supervisor[i]);
        }

    }

    modifier isRelayer() {
        require(
            relayer[_msgSender()] || owner() == _msgSender(),
            "POARelay: caller is not the relayer or owner"
        );
        _;
    }

    modifier isSupervisor() {
        require(
            supervisor[_msgSender()] || owner() == _msgSender(),
            "POARelay: caller is not the supervisor or owner"
        );
        _;
    }

    function _setRelayer(address account) internal { relayer[account] = true; }

    function _removeRelayer(address account) internal { relayer[account] = false; }

    function _setSupervisor(address account) internal { supervisor[account] = true; }

    function _removeSupervisor(address account) internal { supervisor[account] = false; }

    function _setCandidateRoot(uint256 width, uint256 time, bytes32 data) internal {
        candidateRoot.width = width;
        candidateRoot.time = time;
        candidateRoot.data = data;
        candidateRoot.dispute = false;
    }

    function _disputeCadidateRoot() internal {
        candidateRoot.dispute = true;
    }

    function _appendRoot(uint256 width, bytes32 root) internal {
        require(mmrRootPool[width] == bytes32(0), "POARelay: Width has been set");
        require(latestWidth < width, "POARelay: There are already higher blocks");

        _setRoot(width, root);
        _setLatestWidth(width);
    }

    function _setRoot(uint256 width, bytes32 root) internal {
        mmrRootPool[width] = root;
        emit SetRootEvent(_msgSender(), root, width);
    }

    function _setLatestWidth(uint256 width) internal {
        latestWidth = width;
    }

    function verify() public {

    }

    function getMMRRoot(uint256 width) public view returns (bytes32) {
        return mmrRootPool[width];
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

    function verifyBlockProof(
        bytes32 root,
        uint256 width,
        uint256 index,
        bytes memory value,
        bytes32 valueHash,
        bytes32[] memory peaks,
        bytes32[] memory siblings
    ) public view whenNotPaused returns (bool) {
        require(getMMRRoot(width) == bytes32(0), "POARelay: Not registered under this width");
        require(getMMRRoot(width) == root, "POARelay: Root is different from the root pool");

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

    function verifyReceiptProof() public view whenNotPaused returns (bool) {
        return true;
    }

    function appendRoot(uint256 width, bytes32 root) public isRelayer whenNotPaused {
        bool isDone = isOperationDone(candidateRoot.time);
        require(isDone || candidateRoot.dispute , "POARelay: The previous one is still pending or no dispute");

        // A valid candidate root should submit to the root pool
        if(isDone && !candidateRoot.dispute && getMMRRoot(candidateRoot.width) == bytes32(0)) {
            _appendRoot(width, root);
        }

        _setCandidateRoot(width, now, root);
    }

    function disputeRoot() public isSupervisor whenNotPaused {
        _disputeCadidateRoot();
    }

    function resetRoot(uint256 width, bytes32 root) public onlyOwner {
        _setRoot(width, root);
        emit ResetRootEvent(_msgSender(), root, width);
    }

    function resetLatestWidth(uint256 width) public onlyOwner {
        _setLatestWidth(width);
        emit ResetLatestWidthEvent(_msgSender(), width);
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

    function unpause() private onlyOwner{
        _unpause();
    }

    function pause() private onlyOwner{
        _pause();
    }
}
