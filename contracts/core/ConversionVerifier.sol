// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "../interfaces/IConversionVerifier.sol";
import "../libraries/ProofVerification.sol";

/**
 * @title ConversionVerifier
 * @notice Verifies zero-knowledge proofs for conversion attribution
 */
contract ConversionVerifier is IConversionVerifier, Ownable {
    using ProofVerification for uint256[2];

    mapping(bytes32 => bool) private _usedNullifiers;
    mapping(uint256 => bytes32) private _campaignRoots;

    uint256 public constant EXPECTED_PUBLIC_INPUTS = 3;
    uint256 public totalVerifications;

    event NullifierUsed(bytes32 indexed nullifier, uint256 timestamp);
    event CampaignRootUpdated(uint256 indexed campaignId, bytes32 root);
    event ProofValidated(uint256 indexed campaignId, bytes32 indexed nullifier, bool success);

    constructor() Ownable(msg.sender) {}

    /**
     * @notice Verifies a conversion proof
     * @dev This function validates the ZK proof structure and checks nullifier uniqueness
     * @param campaignId Campaign ID
     * @param clickHash Hash of click data
     * @param conversionHash Hash of conversion data
     * @param nullifier Unique nullifier to prevent double-spending
     * @param proof ZK proof data
     * @return bool True if proof is valid
     */
    function verifyConversionProof(
        uint256 campaignId,
        bytes32 clickHash,
        bytes32 conversionHash,
        bytes32 nullifier,
        ProofData memory proof
    ) external view override returns (bool) {
        // Check nullifier hasn't been used
        if (_usedNullifiers[nullifier]) {
            return false;
        }

        // Validate proof structure
        if (!ProofVerification.validateProofStructure(proof.a, proof.b, proof.c)) {
            return false;
        }

        // Validate public inputs length
        if (!ProofVerification.validatePublicInputs(proof.publicInputs, EXPECTED_PUBLIC_INPUTS)) {
            return false;
        }

        // Verify public inputs match
        if (proof.publicInputs[0] != uint256(clickHash)) return false;
        if (proof.publicInputs[1] != uint256(conversionHash)) return false;
        if (proof.publicInputs[2] != uint256(_campaignRoots[campaignId])) return false;

        // In production, this would call the actual Groth16/Halo2 verifier
        // For now, we perform basic validation
        bool verified = _verifyProofInternal(proof);
        
        if (verified) {
            totalVerifications++;
        }
        
        emit ProofValidated(campaignId, nullifier, verified);
        
        return verified;
    }

    /**
     * @notice Marks a nullifier as used
     * @param nullifier Nullifier to mark
     */
    function markNullifierUsed(bytes32 nullifier) external onlyOwner {
        require(!_usedNullifiers[nullifier], "Nullifier already used");
        _usedNullifiers[nullifier] = true;
        emit NullifierUsed(nullifier, block.timestamp);
    }

    /**
     * @notice Checks if a nullifier has been used
     * @param nullifier Nullifier to check
     * @return bool True if used
     */
    function isNullifierUsed(bytes32 nullifier) external view override returns (bool) {
        return _usedNullifiers[nullifier];
    }

    /**
     * @notice Updates campaign root for Merkle verification
     * @param campaignId Campaign ID
     * @param root Merkle root
     */
    function updateCampaignRoot(uint256 campaignId, bytes32 root) external onlyOwner {
        _campaignRoots[campaignId] = root;
        emit CampaignRootUpdated(campaignId, root);
    }

    /**
     * @notice Gets campaign root
     * @param campaignId Campaign ID
     * @return bytes32 Campaign root
     */
    function getCampaignRoot(uint256 campaignId) external view returns (bytes32) {
        return _campaignRoots[campaignId];
    }

    /**
     * @notice Internal proof verification (placeholder for actual ZK verifier)
     * @param proof Proof data
     * @return bool True if valid
     */
    function _verifyProofInternal(ProofData memory proof) private pure returns (bool) {
        // This is a placeholder for the actual Groth16/Halo2 verification
        // In production, this would call a pre-compiled verifier contract
        
        // Basic validation: ensure proof components are non-zero
        if (proof.a[0] == 0 || proof.a[1] == 0) return false;
        if (proof.c[0] == 0 || proof.c[1] == 0) return false;
        
        // Simulate pairing check (in production, use actual pairing)
        // For demonstration purposes, we accept valid-looking proofs
        return true;
    }

    /**
     * @notice Batch verify multiple proofs (gas optimization)
     * @param campaignIds Array of campaign IDs
     * @param clickHashes Array of click hashes
     * @param conversionHashes Array of conversion hashes
     * @param nullifiers Array of nullifiers
     * @param proofs Array of proofs
     * @return bool[] Array of verification results
     */
    function batchVerifyProofs(
        uint256[] memory campaignIds,
        bytes32[] memory clickHashes,
        bytes32[] memory conversionHashes,
        bytes32[] memory nullifiers,
        ProofData[] memory proofs
    ) external view returns (bool[] memory) {
        require(campaignIds.length == proofs.length, "Length mismatch");
        require(clickHashes.length == proofs.length, "Length mismatch");
        require(conversionHashes.length == proofs.length, "Length mismatch");
        require(nullifiers.length == proofs.length, "Length mismatch");

        bool[] memory results = new bool[](proofs.length);

        for (uint256 i = 0; i < proofs.length; i++) {
            results[i] = this.verifyConversionProof(
                campaignIds[i],
                clickHashes[i],
                conversionHashes[i],
                nullifiers[i],
                proofs[i]
            );
        }

        return results;
    }
}

