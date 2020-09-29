pragma solidity >=0.5.0 <0.6.0;
pragma experimental ABIEncoderV2;

library RelayerGame {
    struct Game {
        bytes32 mmrRoot;
        Block finalizedBlock;
        uint32[] samples;
        uint256 deadLineStep;
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
        //  Included
        uint256 activeProposalStart;
        //  Include
        uint256 activeProposalEnd;
        /// [H75]
        bytes32[] proposalLeafs;
        uint256[] samples; // [100, 50]
        bool isClose;
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

    // Todo
    function checkSamples(Game storage game, uint256[] memory samples)
        public
        view
        returns (bool)
    {
        return true;
    }

    function checkProposalHash(Game storage game, uint256[] memory proposalHash)
        public
        view
        returns (bool)
    {
        return true;
    }

    function appendSamples(
        Game storage game,
        uint256 roundIndex,
        uint256[] memory samples
    ) private {
        require(checkSamples(game, samples), "Invalid Samples of the round.");

        for (uint256 i = 0; i < samples.length; i++) {
            game.rounds[roundIndex].samples.push(samples[i]);
        }
    }

    function setDeadLineStep(Game storage game, uint256 step) internal {
        require(step > 0, "Invalid step");
        game.deadLineStep = step;
    }

    function startGame(
        Game storage game,
        // uint roundIndex,
        /// 100
        uint256 sample,
        /// 0x0
        bytes32 parentProposalHash,
        /// [H100a]
        bytes32[] memory proposalHash,
        /// [100a]
        bytes[] memory proposalValue
    ) internal {
        // require(roundIndex >=0 && roundIndex < game.rounds.length, "Invalid roundIndex");
        // require(game.rounds[roundIndex].close, "round is closed");

        // uint[] memory _samples;
        // _samples.push(sample);

        //  uint[] storage _samples;
        // _samples.push(sample);
        Round memory _round = Round(
            block.number + game.deadLineStep,
            0,
            0,
            new bytes32[](0),
            new uint256[](0),
            false
        );

        game.rounds.push(_round);

        game.rounds[game.rounds.length - 1].samples.push(sample);
        game.rounds[game.rounds.length - 1].proposalLeafs.push(bytes32(0x00));
        game.rounds[game.rounds.length - 1].proposalLeafs.push(proposalHash[0]);

        game.blockPool[proposalHash[0]] = Block(
            bytes32(0x00),
            proposalValue[0]
        );
    }

    // function updateRound(
    //     Game storage game,
    //     uint256 roundIndex,
    //     bytes32 parentProposalHash,
    //     bytes32[] memory proposalHash,
    //     bytes[] memory proposalValue
    // ) internal {
    //     Round storage _round = game.rounds[roundIndex];

    //     //  Last round timed out...
    //     require(_round.deadline < block.number, "The last round is not over");

    //     _round.activeProposalStart = _round.activeProposalEnd + 1;
    //     _round.activeProposalEnd = _round.proposalLeafs.length - 1;

    //     //  update deadline + deadLineStep
    //     updateDeadline(game, _round);

    //     //  TODO _round.deadline + game.deadLineStep < block.number

    //     appendProposalByRound(
    //         game,
    //         roundIndex,
    //         parentProposalHash,
    //         proposalHash,
    //         proposalValue
    //     );
    // }

    function closeRound(
        Game storage game,
        uint256 roundIndex
    ) public {
        Round storage _round = game.rounds[roundIndex];

        require(!_round.isClose, "round is closed");
        require(_round.proposalLeafs.length - _round.activeProposalEnd == 2, "here was no decision.");
        require(_round.deadline < block.number, "The game has not reached the end time.");

        _round.isClose = true;
    }

    function appendProposalByRound(
        Game storage game,
        /// 0
        uint256 roundIndex,
        uint256 deadline,
        /// 50
        // uint samples,
        /// H100a
        /// H50b
        bytes32 parentProposalHash,
        /// [H50b]
        /// [H75e, H25j]
        bytes32[] memory proposalHash,
        /// [50b]
        bytes[] memory proposalValue
    ) internal {
        require(
            roundIndex >= 0 && roundIndex < game.rounds.length,
            "Invalid round"
        );
        require(!game.rounds[roundIndex].isClose, "round is closed");

        
        // require(
        //     deadline >= game.rounds[roundIndex].deadline,
        //     "invalid deadline"
        // );

        // appendSamples(game, roundIndex, samples);

        // Check the number of hashes
        // Check block legitimacy
        // require(checkProposalHash(proposalHash), "Invalid Proposal Hash of the round.");

        Round storage _round = game.rounds[roundIndex];

        if (_round.deadline + 1 == deadline) {
            require(
                _round.deadline < block.number,
                "The last round is not over"
            );
            //  update deadline + deadLineStep
            updateDeadline(game, _round);
            // _round.deadline = _round.deadline + game.deadLineStep;

            //  Last round timed out...
            require(
                _round.deadline > block.number,
                "New round deadline blow block.number"
            );

            _round.activeProposalStart = _round.activeProposalEnd + 1;
            _round.activeProposalEnd = _round.proposalLeafs.length - 1;
        }

        require(block.number <= _round.deadline, "The round has expired");

        // check parentProposalHash in [activeProposalStart, activeProposalEnd]
        bool validParentProposalHash;
        for (
            uint256 i = _round.activeProposalStart;
            i <= _round.activeProposalEnd;
            i++
        ) {
            if (_round.proposalLeafs[i] == parentProposalHash) {
                validParentProposalHash = true;
            }
        }
        require(validParentProposalHash, "Invalid parentProposalHash");

        // The last element is used as the proposal hash
        _round.proposalLeafs.push(proposalHash[proposalHash.length - 1]);

        // /// 1 => 0   5 => 4
        // _round.activeProposalIndex = _round.proposalLeafs.length - 1;

        // save proposal
        game.blockPool[proposalHash[0]] = Block(
            parentProposalHash,
            proposalValue[0]
        );

        for (uint256 i = 1; i < proposalHash.length; i++) {
            game.blockPool[proposalHash[i]] = Block(
                proposalHash[i - 1],
                proposalValue[i]
            );
        }
    }

    function updateDeadline(Game storage game, Round storage round) private {
        round.deadline = round.deadline + game.deadLineStep;
    }

    // function insertProposalValue(
    //     Game storage game,
    //     bytes32[] memory proposalHash,
    //     bytes memory proposalValue) {

    //     }

    // function checkProposalValue() {

    // }

    /// 1- [100],[H100a],[100a]
    /// 1- [100],[H100b],[100b]
    /// 2- [50],[H50a],[50a]
    /// 3- [25, 75],[H25a, H75a],[25a, 75a]
    function setProposal(
        Game storage game,
        uint256[] memory samples,
        bytes32 parentProposalHash,
        bytes32[] memory proposalHash,
        bytes[] memory proposalValue
    ) internal {
        // check the submisstion follows the samples
    }

}
