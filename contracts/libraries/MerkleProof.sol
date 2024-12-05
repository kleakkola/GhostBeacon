// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title MerkleProof
 * @notice Library for Merkle tree verification
 */
library MerkleProof {
    /**
     * @notice Verifies a Merkle proof
     * @param proof Array of sibling hashes
     * @param root Merkle root
     * @param leaf Leaf to verify
     * @return bool True if proof is valid
     */
    function verify(
        bytes32[] memory proof,
        bytes32 root,
        bytes32 leaf
    ) internal pure returns (bool) {
        return processProof(proof, leaf) == root;
    }

    /**
     * @notice Processes a Merkle proof
     * @param proof Array of sibling hashes
     * @param leaf Leaf to process
     * @return bytes32 Computed hash
     */
    function processProof(
        bytes32[] memory proof,
        bytes32 leaf
    ) internal pure returns (bytes32) {
        bytes32 computedHash = leaf;
        
        for (uint256 i = 0; i < proof.length; i++) {
            computedHash = _hashPair(computedHash, proof[i]);
        }
        
        return computedHash;
    }

    /**
     * @notice Hashes a pair of nodes
     * @param a First node
     * @param b Second node
     * @return bytes32 Hash of pair
     */
    function _hashPair(bytes32 a, bytes32 b) private pure returns (bytes32) {
        return a < b ? _efficientHash(a, b) : _efficientHash(b, a);
    }

    /**
     * @notice Efficient keccak256 hash
     * @param a First value
     * @param b Second value
     * @return value Keccak256 hash
     */
    function _efficientHash(
        bytes32 a,
        bytes32 b
    ) private pure returns (bytes32 value) {
        assembly {
            mstore(0x00, a)
            mstore(0x20, b)
            value := keccak256(0x00, 0x40)
        }
    }

    /**
     * @notice Verifies multi-proof (for multiple leaves)
     * @param proof Array of sibling hashes
     * @param proofFlags Flags indicating proof path
     * @param root Merkle root
     * @param leaves Array of leaves to verify
     * @return bool True if all proofs are valid
     */
    function multiProofVerify(
        bytes32[] memory proof,
        bool[] memory proofFlags,
        bytes32 root,
        bytes32[] memory leaves
    ) internal pure returns (bool) {
        return processMultiProof(proof, proofFlags, leaves) == root;
    }

    /**
     * @notice Processes multi-proof
     * @param proof Array of sibling hashes
     * @param proofFlags Flags indicating proof path
     * @param leaves Array of leaves
     * @return bytes32 Computed root
     */
    function processMultiProof(
        bytes32[] memory proof,
        bool[] memory proofFlags,
        bytes32[] memory leaves
    ) internal pure returns (bytes32) {
        uint256 leavesLen = leaves.length;
        uint256 totalHashes = proofFlags.length;
        
        require(leavesLen + proof.length - 1 == totalHashes, "Invalid multi-proof");
        
        bytes32[] memory hashes = new bytes32[](totalHashes);
        uint256 leafPos = 0;
        uint256 hashPos = 0;
        uint256 proofPos = 0;
        
        for (uint256 i = 0; i < totalHashes; i++) {
            bytes32 a = leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++];
            bytes32 b = proofFlags[i]
                ? leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++]
                : proof[proofPos++];
            hashes[i] = _hashPair(a, b);
        }
        
        return hashes[totalHashes - 1];
    }
}

