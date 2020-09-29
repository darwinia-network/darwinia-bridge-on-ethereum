pragma solidity >=0.5.0 <0.6.0;

/**
 MIT License
 Copyright (c) 2017 chriseth
 */

library D {
    struct Game {
        bytes32 mmrRoot;
        Block finalizedBlock;
        uint32[] samples;
        uint256 deadLineStep;
        mapping(uint32 => Proposal) proposalPool;
        /// (H100 => {})
        /// (H50a => {p: H100})
        /// (H50b => {p: H100})
        /// (H25 => {p: H75})
        /// (H75 => {p: H50})
        mapping(bytes32 => Block) blockPool;
        uint256 latestRoundIndex;
        Round[] rounds;
    }

    struct Round {
        uint256 deadline;
        uint256 activeProposalStart;
        uint256 activeProposalEnd;
        /// [H75]
        bytes32[] proposalLeafs;
        uint256[] samples; // [100, 50]
        bool close;
    }

    struct Block {
        bytes32 parent;
        bytes data;
    }

    struct Proposal {
        uint256 id;
        address sponsor;
        mapping(uint32 => Block) block;
    }
}

