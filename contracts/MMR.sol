pragma solidity >=0.4.21 <0.6.0;

import "./Blake2b.sol";

/**
 * @author Wanseob Lim <email@wanseob.com>
 * @title Merkle Mountain Range solidity library
 *
 * @dev The index of this MMR implementation starts from 1 not 0.
 *      And it uses Blake2bHash for its hash function instead of blake2b
 */
library MMR {
    using Blake2b for Blake2b.Instance;

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


    function bytes32Concat(bytes32 b1, bytes32 b2) public pure returns (bytes memory)
    {
        bytes memory result = new bytes(64);
        assembly {
            mstore(add(result, 32), b1)
            mstore(add(result, 64), b2)
        }
        return result;
    }

    function Blake2bHash(bytes memory input) view public returns (bytes32) {
      Blake2b.Instance memory instance = Blake2b.init(hex"", 32);
      return bytesToBytes32(instance.finalize(input), 0);
    }

    function getSize(uint width) public pure returns (uint256) {
        return (width << 1) - numOfPeaks(width);
    }

    function peakBagging(uint256 width, bytes32[] memory peaks) view public returns (bytes32) {
        uint size = getSize(width);
        // require(numOfPeaks(width) == peaks.length, "Received invalid number of peaks");
        bytes32 mergeHash = peaks[0];
        for(uint i = peaks.length-1; i >= 1; i = i - 1) {
            bytes32 r;
            if(i == peaks.length-1) {
                r = peaks[i];
            } else {
                r = mergeHash;
            }
            bytes32 l = peaks[i-1];
            mergeHash = hashBranch(0, r, l);
        }

        return mergeHash;
    }

    function peaksToPeakMap(uint width, bytes32[] memory peaks) public pure returns (bytes32[255] memory peakMap) {
        uint bitIndex;
        uint peakRef;
        uint count = peaks.length;
        for(uint height = 1; height <= 255; height++) {
            // Index starts from the right most bit
            bitIndex = 255 - height;
            peakRef = 1 << (height - 1);
            if((width & peakRef) != 0) {
                peakMap[bitIndex] = peaks[--count];
            } else {
                peakMap[bitIndex] = bytes32(0);
            }
        }
        require(count == 0, "Invalid number of peaks");
    }

    function peakMapToPeaks(uint width, bytes32[255] memory peakMap) public pure returns (bytes32[] memory peaks) {
        uint arrLength = numOfPeaks(width);
        peaks = new bytes32[](arrLength);
        uint count = 0;
        for(uint i = 0; i < 255; i++) {
            if(peakMap[i] != bytes32(0)) {
                peaks[count++] = peakMap[i];
            }
        }
        require(count == arrLength, "Invalid number of peaks");
    }

    /** Pure functions */

    /**
     * @dev It returns true when the given params verifies that the given value exists in the tree or reverts the transaction.
     */
    function inclusionProof(
        bytes32 root,
        uint256 width,
        uint256 index,
        bytes memory value,
        bytes32 valueHash,
        bytes32[] memory peaks,
        bytes32[] memory siblings
    ) view public returns (bool) {
        uint size = getSize(width);
        require(size >= index, "Index is out of range");
        // Check the root equals the peak bagging hash
        require(root == peakBagging(width, peaks), "Invalid root hash from the peaks");

        // Find the mountain where the target index belongs to
        uint256 cursor;
        bytes32 targetPeak;
        uint256[] memory peakIndexes = getPeakIndexes(width);
        for (uint i = 0; i < peakIndexes.length; i++) {
            if (peakIndexes[i] >= index) {
                targetPeak = peaks[i];
                cursor = peakIndexes[i];
                break;
            }
        }
        require(targetPeak != bytes32(0), "Target is not found");

        // Find the path climbing down
        uint256[] memory path = new uint256[](siblings.length + 1);
        uint256 left;
        uint256 right;
        uint8 height = uint8(siblings.length) + 1;
        while (height > 0) {
            // Record the current cursor and climb down
            path[--height] = cursor;
            if (cursor == index) {
                // On the leaf node. Stop climbing down
                break;
            } else {
                // On the parent node. Go left or right
                (left, right) = getChildren(cursor);
                cursor = index > left ? right : left;
                continue;
            }
        }

        // Calculate the summit hash climbing up again
        bytes32 node;
        while (height < path.length) {
            // Move cursor
            cursor = path[height];
            if (height == 0) {
                // cursor is on the leaf
                // node = hashLeaf(cursor, Blake2bHash(value));
                node = valueHash;
            } else if (cursor - 1 == path[height - 1]) {
                // cursor is on a parent and a sibling is on the left
                node = hashBranch(cursor, siblings[height - 1], node);
            } else {
                // cursor is on a parent and a sibling is on the right
                node = hashBranch(cursor, node, siblings[height - 1]);
            }
            // Climb up
            height++;
        }

        // Computed hash value of the summit should equal to the target peak hash
        require(node == targetPeak, "Hashed peak is invalid");
        return true;
    }

    /**
     * @dev It returns true when the given params verifies that the given value exists in the tree or reverts the transaction.
     */
    function verifyProof(
        bytes32 root,
        uint256 width,
        uint256 index,
        bytes memory value,
        bytes32 valueHash,
        bytes32[] memory peaks,
        bytes32[] memory siblings
    ) view public returns (uint8) {
        uint size = getSize(width);
        if(size < index) {
            return 5;
        }
   
        // Check the root equals the peak bagging hash
        if(root != peakBagging(width, peaks)) {
            return 4;
        }

        // Find the mountain where the target index belongs to
        uint256 cursor;
        bytes32 targetPeak;
        uint256[] memory peakIndexes = getPeakIndexes(width);
        for (uint i = 0; i < peakIndexes.length; i++) {
            if (peakIndexes[i] >= index) {
                targetPeak = peaks[i];
                cursor = peakIndexes[i];
                break;
            }
        }

        if(targetPeak == bytes32(0)) {
            return 3;
        }

        // Find the path climbing down
        uint256[] memory path = new uint256[](siblings.length + 1);
        uint256 left;
        uint256 right;
        uint8 height = uint8(siblings.length) + 1;

        while (height > 0) {
            // Record the current cursor and climb down
            path[--height] = cursor;
            if (cursor == index) {
                // On the leaf node. Stop climbing down
                break;
            } else {
                // On the parent node. Go left or right
                (left, right) = getChildren(cursor);
                cursor = index > left ? right : left;
                continue;
            }
        }

        // Calculate the summit hash climbing up again
        bytes32 node;
        while (height < path.length) {
            // Move cursor
            cursor = path[height];
            if (height == 0) {
                // cursor is on the leaf
                // node = hashLeaf(cursor, Blake2bHash(value));
                node = valueHash;
            } else if (cursor - 1 == path[height - 1]) {
                // cursor is on a parent and a sibling is on the left
                node = hashBranch(cursor, siblings[height - 1], node);
            } else {
                // cursor is on a parent and a sibling is on the right
                node = hashBranch(cursor, node, siblings[height - 1]);
            }
            // Climb up
            height++;
        }

        // Computed hash value of the summit should equal to the target peak hash
        if(node != targetPeak) {
            return 2;
        }
        return 0;
    }

    /**
     * @dev It returns the hash a parent node with hash(M | Left child | Right child)
     *      M is the index of the node
     */
    function hashBranch(uint256 index, bytes32 left, bytes32 right) view public returns (bytes32) {
        // return Blake2bHash(abi.encodePacked(index, left, right));
        return Blake2bHash(bytes32Concat(left, right));
    }

    /**
     * @dev it returns the hash of a leaf node with hash(M | DATA )
     *      M is the index of the node
     */
    function hashLeaf(uint256 index, bytes32 dataHash) view public returns (bytes32) {
        return Blake2bHash(abi.encodePacked(index, dataHash));
    }

    /**
     * @dev It returns the height of the highest peak
     */
    function mountainHeight(uint256 size) public pure returns (uint8) {
        uint8 height = 1;
        while (uint256(1) << height <= size + height) {
            height++;
        }
        return height - 1;
    }

    /**
     * @dev It returns the height of the index
     */
    function heightAt(uint256 index) public pure returns (uint8 height) {
        uint256 reducedIndex = index;
        uint256 peakIndex;
        // If an index has a left mountain subtract the mountain
        while (reducedIndex > peakIndex) {
            reducedIndex -= (uint256(1) << height) - 1;
            height = mountainHeight(reducedIndex);
            peakIndex = (uint256(1) << height) - 1;
        }
        // Index is on the right slope
        height = height - uint8((peakIndex - reducedIndex));
    }

    /**
     * @dev It returns whether the index is the leaf node or not
     */
    function isLeaf(uint256 index) public pure returns (bool) {
        return heightAt(index) == 1;
    }

    /**
     * @dev It returns the children when it is a parent node
     */
    function getChildren(uint256 index) public pure returns (uint256 left, uint256 right) {
        left = 0;
        right = 0;
        left = index - (uint256(1) << (heightAt(index) - 1));
        right = index - 1;
        require(left != right, "Not a parent");
        return (left, right);
    }

    /**
     * @dev It returns all peaks of the smallest merkle mountain range tree which includes
     *      the given index(size)
     */
    function getPeakIndexes(uint256 width) public pure returns (uint256[] memory peakIndexes) {
        peakIndexes = new uint256[](numOfPeaks(width));
        uint count;
        uint size;
        for(uint i = 255; i > 0; i--) {
            if(width & (1 << (i - 1)) != 0) {
                // peak exists
                size = size + (1 << i) - 1;
                peakIndexes[count++] = size;
            }
        }
        require(count == peakIndexes.length, "Invalid bit calculation");
    }

    function numOfPeaks(uint256 width) public pure returns (uint num) {
        uint256 bits = width;
        while(bits > 0) {
            if(bits % 2 == 1) num++;
            bits = bits >> 1;
        }
        return num;
    }
}