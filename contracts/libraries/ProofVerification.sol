// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title ProofVerification
 * @notice Library for ZK proof verification utilities
 */
library ProofVerification {
    struct Proof {
        uint256[2] a;
        uint256[2][2] b;
        uint256[2] c;
    }

    /**
     * @notice Validates proof structure
     * @param a Proof component A
     * @param b Proof component B
     * @param c Proof component C
     * @return bool True if structure is valid
     */
    function validateProofStructure(
        uint256[2] memory a,
        uint256[2][2] memory b,
        uint256[2] memory c
    ) internal pure returns (bool) {
        // Check that proof components are not zero
        if (a[0] == 0 && a[1] == 0) return false;
        if (c[0] == 0 && c[1] == 0) return false;
        if (b[0][0] == 0 && b[0][1] == 0 && b[1][0] == 0 && b[1][1] == 0) return false;
        
        return true;
    }

    /**
     * @notice Computes nullifier hash
     * @param clickHash Hash of click data
     * @param userSecret User's secret value
     * @return bytes32 Nullifier hash
     */
    function computeNullifier(
        bytes32 clickHash,
        bytes32 userSecret
    ) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(clickHash, userSecret));
    }

    /**
     * @notice Validates public inputs
     * @param publicInputs Array of public inputs
     * @param expectedLength Expected length of inputs
     * @return bool True if valid
     */
    function validatePublicInputs(
        uint256[] memory publicInputs,
        uint256 expectedLength
    ) internal pure returns (bool) {
        return publicInputs.length == expectedLength;
    }

    /**
     * @notice Checks if value is within valid field
     * @param value Value to check
     * @return bool True if valid field element
     */
    function isValidFieldElement(uint256 value) internal pure returns (bool) {
        // BN254 curve order (simplified check)
        return value < 21888242871839275222246405745257275088548364400416034343698204186575808495617;
    }
}

