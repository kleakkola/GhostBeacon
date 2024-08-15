// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title IConversionVerifier
 * @notice Interface for ZK conversion proof verification
 */
interface IConversionVerifier {
    struct ProofData {
        uint256[2] a;
        uint256[2][2] b;
        uint256[2] c;
        uint256[] publicInputs;
    }

    event ProofVerified(
        uint256 indexed campaignId,
        bytes32 indexed nullifier,
        bool success
    );

    function verifyConversionProof(
        uint256 campaignId,
        bytes32 clickHash,
        bytes32 conversionHash,
        bytes32 nullifier,
        ProofData memory proof
    ) external view returns (bool);

    function isNullifierUsed(bytes32 nullifier) external view returns (bool);
}

