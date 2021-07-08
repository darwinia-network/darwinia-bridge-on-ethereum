// SPDX-License-Identifier: MIT

// Modified Merkle-Patricia Trie
//
// Note that for the following definitions, `|` denotes concatenation
//
// Branch encoding:
// NodeHeader | Extra partial key length | Partial Key | Value
// `NodeHeader` is a byte such that:
// most significant two bits of `NodeHeader`: 10 if branch w/o value, 11 if branch w/ value
// least significant six bits of `NodeHeader`: if len(key) > 62, 0x3f, otherwise len(key)
// `Extra partial key length` is included if len(key) > 63 and consists of the remaining key length
// `Partial Key` is the branch's key
// `Value` is: Children Bitmap | SCALE Branch node Value | Hash(Enc(Child[i_1])) | Hash(Enc(Child[i_2])) | ... | Hash(Enc(Child[i_n]))
//
// Leaf encoding:
// NodeHeader | Extra partial key length | Partial Key | Value
// `NodeHeader` is a byte such that:
// most significant two bits of `NodeHeader`: 01
// least significant six bits of `NodeHeader`: if len(key) > 62, 0x3f, otherwise len(key)
// `Extra partial key length` is included if len(key) > 63 and consists of the remaining key length
// `Partial Key` is the leaf's key
// `Value` is the leaf's SCALE encoded value

pragma solidity >=0.6.0 <0.7.0;
pragma experimental ABIEncoderV2;

import "@darwinia/contracts-utils/contracts/Input.sol";
import "@darwinia/contracts-utils/contracts/Memory.sol";
import "@darwinia/contracts-utils/contracts/Bytes.sol";
import "@darwinia/contracts-utils/contracts/Keccak.sol";
import "@darwinia/contracts-utils/contracts/Nibble.sol";
import "@darwinia/contracts-utils/contracts/Node.sol";

/**
 * @dev Verification of compact proofs for Modified Merkle-Patricia tries.
 */
contract CompactMerkleProof {
    using Bytes for bytes;
    using Keccak for bytes;
    using Input for Input.Data;

    uint8 internal constant NODEKIND_NOEXT_LEAF = 1;
    uint8 internal constant NODEKIND_NOEXT_BRANCH_NOVALUE = 2;
    uint8 internal constant NODEKIND_NOEXT_BRANCH_WITHVALUE = 3;

    struct StackEntry {
        bytes prefix; // The prefix is the nibble path to the node in the trie.
        uint8 kind; // The type of the trie node.
        bytes key; // The partail key of the trie node.
        bytes value; // The value associated with this trie node.
        Node.NodeHandle[16] children; // The child references to use in reconstructing the trie nodes.
        uint8 childIndex; // The child index is in [0, NIBBLE_LENGTH],
        bool isInline; // The trie node data less 32-byte is an isline node
    }

    struct ProofIter {
        bytes[] proof;
        uint256 offset;
    }

    struct ItemsIter {
        Item[] items;
        uint256 offset;
    }

    struct Item {
        bytes key;
        bytes value;
    }

    enum ValueMatch {MatchesLeaf, MatchesBranch, NotOmitted, NotFound, IsChild}

    enum Step {Descend, UnwindStack}

	/**
     * @dev Returns true if `keys ans values` can be proved to be a part of a Merkle tree
     * defined by `root`. For this, a `proof` must be provided, is a sequence of the subset
     * of nodes in the trie traversed while performing lookups on all keys. The trie nodes
     * are listed in pre-order traversal order with some values and internal hashes omitted.
     */
    function verify(
        bytes32 root,
        bytes[] memory proof,
        bytes[] memory keys,
        bytes[] memory values
    ) public pure returns (bool) {
        require(proof.length > 0, "no proof");
        require(keys.length > 0, "no keys");
        require(keys.length == values.length, "invalid pair");
        Item[] memory items = new Item[](keys.length);
        for (uint256 i = 0; i < keys.length; i++) {
            items[i] = Item({key: keys[i], value: values[i]});
        }
        return verify_proof(root, proof, items);
    }

    function verify_proof(
        bytes32 root,
        bytes[] memory proof,
        Item[] memory items
    ) internal pure returns (bool) {
        require(proof.length > 0, "no proof");
        require(items.length > 0, "no item");
        //TODO:: OPT
        uint256 maxDepth = proof.length;
        StackEntry[] memory stack = new StackEntry[](maxDepth);
        uint256 stackLen = 0;
        bytes memory rootNode = proof[0];
        StackEntry memory lastEntry = decodeNode(rootNode, hex"", false);
        ProofIter memory proofIter = ProofIter({proof: proof, offset: 1});
        ItemsIter memory itemsIter = ItemsIter({items: items, offset: 0});
        while (true) {
            Step step;
            bytes memory childPrefix;
            (step, childPrefix) = advanceItem(lastEntry, itemsIter);
            if (step == Step.Descend) {
                StackEntry memory nextEntry = advanceChildIndex(
                    lastEntry,
                    childPrefix,
                    proofIter
                );
                stack[stackLen] = lastEntry;
                stackLen++;
                lastEntry = nextEntry;
            } else if (step == Step.UnwindStack) {
                bytes memory childRef;
                {
                    bool isInline = lastEntry.isInline;
                    bytes memory nodeData = encodeNode(lastEntry);
                    if (isInline) {
                        require(
                            nodeData.length <= 32,
                            "invalid child reference"
                        );
                        childRef = nodeData;
                    } else {
                        childRef = Memory.toBytes(nodeData.hash());
                    }
                }
                {
                    if (stackLen > 0) {
                        lastEntry = stack[stackLen - 1];
                        stackLen--;
                        lastEntry.children[lastEntry.childIndex]
                            .data = childRef;
                    } else {
                        require(
                            proofIter.offset == proofIter.proof.length,
                            "exraneous proof"
                        );
                        require(
                            childRef.length == 32,
                            "root hash length should be 32"
                        );
                        bytes32 computedRoot = abi.decode(childRef, (bytes32));
                        if (computedRoot != root) {
                            return false;
                        }
                        break;
                    }
                }
            }
        }
        return true;
    }

    function advanceChildIndex(
        StackEntry memory entry,
        bytes memory childPrefix,
        ProofIter memory proofIter
    ) internal pure returns (StackEntry memory) {
        if (
            entry.kind == NODEKIND_NOEXT_BRANCH_NOVALUE ||
            entry.kind == NODEKIND_NOEXT_BRANCH_WITHVALUE
        ) {
            require(childPrefix.length > 0, "this is a branch");
            entry.childIndex = uint8(childPrefix[childPrefix.length - 1]);
            Node.NodeHandle memory child = entry.children[entry.childIndex];
            return makeChildEntry(proofIter, child, childPrefix);
        } else {
            revert("cannot have children");
        }
    }

    function makeChildEntry(
        ProofIter memory proofIter,
        Node.NodeHandle memory child,
        bytes memory prefix
    ) internal pure returns (StackEntry memory) {
        if (child.isInline) {
            if (child.data.length == 0) {
                require(
                    proofIter.offset < proofIter.proof.length,
                    "incomplete proof"
                );
                bytes memory nodeData = proofIter.proof[proofIter.offset];
                proofIter.offset++;
                return decodeNode(nodeData, prefix, false);
            } else {
                return decodeNode(child.data, prefix, true);
            }
        } else {
            require(child.data.length == 32, "invalid child reference");
            revert("extraneous hash reference");
        }
    }

    function advanceItem(StackEntry memory entry, ItemsIter memory itemsIter)
        internal
        pure
        returns (Step, bytes memory childPrefix)
    {
        while (itemsIter.offset < itemsIter.items.length) {
            Item memory item = itemsIter.items[itemsIter.offset];
            bytes memory k = Nibble.keyToNibbles(item.key);
            bytes memory v = item.value;
            if (startsWith(k, entry.prefix)) {
                ValueMatch vm;
                (vm, childPrefix) = matchKeyToNode(
                    k,
                    entry.prefix.length,
                    entry
                );
                if (ValueMatch.MatchesLeaf == vm) {
                    if (v.length == 0) {
                        revert("value mismatch");
                    }
                    entry.value = v;
                } else if (ValueMatch.MatchesBranch == vm) {
                    entry.value = v;
                } else if (ValueMatch.NotFound == vm) {
                    if (v.length > 0) {
                        revert("value mismatch");
                    }
                } else if (ValueMatch.NotOmitted == vm) {
                    revert("extraneouts value");
                } else if (ValueMatch.IsChild == vm) {
                    return (Step.Descend, childPrefix);
                }
                itemsIter.offset++;
                continue;
            }
            return (Step.UnwindStack, childPrefix);
        }
        return (Step.UnwindStack, childPrefix);
    }

    function matchKeyToNode(
        bytes memory k,
        uint256 prefixLen,
        StackEntry memory entry
    ) internal pure returns (ValueMatch vm, bytes memory childPrefix) {
        uint256 prefixPlufPartialLen = prefixLen + entry.key.length;
        if (entry.kind == NODEKIND_NOEXT_LEAF) {
            if (
                contains(k, entry.key, prefixLen) &&
                k.length == prefixPlufPartialLen
            ) {
                if (entry.value.length == 0) {
                    return (ValueMatch.MatchesLeaf, childPrefix);
                } else {
                    return (ValueMatch.NotOmitted, childPrefix);
                }
            } else {
                return (ValueMatch.NotFound, childPrefix);
            }
        } else if (
            entry.kind == NODEKIND_NOEXT_BRANCH_NOVALUE ||
            entry.kind == NODEKIND_NOEXT_BRANCH_WITHVALUE
        ) {
            if (contains(k, entry.key, prefixLen)) {
                if (prefixPlufPartialLen == k.length) {
                    if (entry.value.length == 0) {
                        return (ValueMatch.MatchesBranch, childPrefix);
                    } else {
                        return (ValueMatch.NotOmitted, childPrefix);
                    }
                } else {
                    uint8 index = uint8(k[prefixPlufPartialLen]);
                    if (entry.children[index].exist) {
                        childPrefix = k.substr(0, prefixPlufPartialLen + 1);
                        return (ValueMatch.IsChild, childPrefix);
                    } else {
                        return (ValueMatch.NotFound, childPrefix);
                    }
                }
            } else {
                return (ValueMatch.NotFound, childPrefix);
            }
        } else {
            revert("not support node type");
        }
    }

    function contains(
        bytes memory a,
        bytes memory b,
        uint256 offset
    ) internal pure returns (bool) {
        if (a.length < b.length + offset) {
            return false;
        }
        for (uint256 i = 0; i < b.length; i++) {
            if (a[i + offset] != b[i]) {
                return false;
            }
        }
        return true;
    }

    function startsWith(bytes memory a, bytes memory b)
        internal
        pure
        returns (bool)
    {
        if (a.length < b.length) {
            return false;
        }
        for (uint256 i = 0; i < b.length; i++) {
            if (a[i] != b[i]) {
                return false;
            }
        }
        return true;
    }

    /**
     * @dev Encode a Node.
     *      encoding has the following format:
     *      NodeHeader | Extra partial key length | Partial Key | Value
     * @param entry The stackEntry.
     * @return The encoded branch.
     */
    function encodeNode(StackEntry memory entry)
        internal
        pure
        returns (bytes memory)
    {
        if (entry.kind == NODEKIND_NOEXT_LEAF) {
            Node.Leaf memory l = Node.Leaf({
                key: entry.key,
                value: entry.value
            });
            return Node.encodeLeaf(l);
        } else if (
            entry.kind == NODEKIND_NOEXT_BRANCH_NOVALUE ||
            entry.kind == NODEKIND_NOEXT_BRANCH_WITHVALUE
        ) {
            Node.Branch memory b = Node.Branch({
                key: entry.key,
                value: entry.value,
                children: entry.children
            });
            return Node.encodeBranch(b);
        } else {
            revert("not support node kind");
        }
    }

    /**
     * @dev Decode a Node.
     *      encoding has the following format:
     *      NodeHeader | Extra partial key length | Partial Key | Value
     * @param nodeData The encoded trie node data.
     * @param prefix The nibble path to the node.
     * @param isInline The node is an in-line node or not.
     * @return entry The StackEntry.
     */
    function decodeNode(
        bytes memory nodeData,
        bytes memory prefix,
        bool isInline
    ) internal pure returns (StackEntry memory entry) {
        Input.Data memory data = Input.from(nodeData);
        uint8 header = data.decodeU8();
        uint8 kind = header >> 6;
        if (kind == NODEKIND_NOEXT_LEAF) {
            //Leaf
            Node.Leaf memory leaf = Node.decodeLeaf(data, header);
            entry.key = leaf.key;
            entry.value = leaf.value;
            entry.kind = kind;
            entry.prefix = prefix;
            entry.isInline = isInline;
        } else if (
            kind == NODEKIND_NOEXT_BRANCH_NOVALUE ||
            kind == NODEKIND_NOEXT_BRANCH_WITHVALUE
        ) {
            //BRANCH_WITHOUT_MASK_NO_EXT  BRANCH_WITH_MASK_NO_EXT
            Node.Branch memory branch = Node.decodeBranch(data, header);
            entry.key = branch.key;
            entry.value = branch.value;
            entry.kind = kind;
            entry.children = branch.children;
            entry.childIndex = 0;
            entry.prefix = prefix;
            entry.isInline = isInline;
        } else {
            revert("not support node kind");
        }
    }
}
