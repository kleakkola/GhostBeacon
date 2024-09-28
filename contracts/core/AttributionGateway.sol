// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "../interfaces/IAttributionGateway.sol";
import "../interfaces/IConversionVerifier.sol";
import "../interfaces/ICampaignRegistry.sol";
import "../interfaces/IBillingModule.sol";
import "../interfaces/IAnalyticsAggregator.sol";

/**
 * @title AttributionGateway
 * @notice Main gateway for conversion submission and verification
 */
contract AttributionGateway is IAttributionGateway, Ownable, ReentrancyGuard {
    IConversionVerifier public immutable verifier;
    ICampaignRegistry public immutable campaignRegistry;
    IBillingModule public billingModule;
    IAnalyticsAggregator public analyticsAggregator;

    mapping(bytes32 => bool) private _processedNullifiers;
    mapping(uint256 => uint256) private _campaignConversionCount;

    uint256 public constant DEFAULT_WEIGHT = 1;

    event ConversionProcessed(
        uint256 indexed campaignId,
        bytes32 indexed nullifier,
        uint256 timestamp,
        uint256 weight
    );

    constructor(
        address _verifier,
        address _campaignRegistry
    ) Ownable(msg.sender) {
        require(_verifier != address(0), "Invalid verifier");
        require(_campaignRegistry != address(0), "Invalid registry");
        
        verifier = IConversionVerifier(_verifier);
        campaignRegistry = ICampaignRegistry(_campaignRegistry);
    }

    /**
     * @notice Submits a conversion with ZK proof
     * @param campaignId Campaign ID
     * @param clickHash Hash of click data
     * @param conversionHash Hash of conversion data
     * @param nullifier Unique nullifier
     * @param proof ZK proof data
     * @return bool True if successful
     */
    function submitConversion(
        uint256 campaignId,
        bytes32 clickHash,
        bytes32 conversionHash,
        bytes32 nullifier,
        IConversionVerifier.ProofData memory proof
    ) external override nonReentrant returns (bool) {
        // Check campaign is active
        if (!campaignRegistry.isCampaignActive(campaignId)) {
            emit ConversionRejected(campaignId, nullifier, "Campaign not active");
            return false;
        }

        // Check nullifier hasn't been used
        if (_processedNullifiers[nullifier] || verifier.isNullifierUsed(nullifier)) {
            emit ConversionRejected(campaignId, nullifier, "Nullifier already used");
            return false;
        }

        // Verify ZK proof
        bool verified = verifier.verifyConversionProof(
            campaignId,
            clickHash,
            conversionHash,
            nullifier,
            proof
        );

        if (!verified) {
            emit ConversionRejected(campaignId, nullifier, "Proof verification failed");
            return false;
        }

        // Mark nullifier as processed
        _processedNullifiers[nullifier] = true;

        // Process billing if module is set
        if (address(billingModule) != address(0)) {
            try billingModule.processConversion(campaignId, nullifier, DEFAULT_WEIGHT) {
                // Billing successful
            } catch {
                emit ConversionRejected(campaignId, nullifier, "Billing failed");
                return false;
            }
        }

        // Record analytics if aggregator is set
        if (address(analyticsAggregator) != address(0)) {
            uint256 cost = billingModule.calculateFee(campaignId, DEFAULT_WEIGHT);
            analyticsAggregator.recordConversion(campaignId, cost);
        }

        // Update conversion count
        _campaignConversionCount[campaignId] += 1;

        emit ConversionSubmitted(campaignId, nullifier, msg.sender, block.timestamp);
        emit ConversionProcessed(campaignId, nullifier, block.timestamp, DEFAULT_WEIGHT);

        return true;
    }

    /**
     * @notice Sets billing module address
     * @param _billingModule Billing module address
     */
    function setBillingModule(address _billingModule) external onlyOwner {
        require(_billingModule != address(0), "Invalid address");
        billingModule = IBillingModule(_billingModule);
    }

    /**
     * @notice Sets analytics aggregator address
     * @param _analyticsAggregator Analytics aggregator address
     */
    function setAnalyticsAggregator(address _analyticsAggregator) external onlyOwner {
        require(_analyticsAggregator != address(0), "Invalid address");
        analyticsAggregator = IAnalyticsAggregator(_analyticsAggregator);
    }

    /**
     * @notice Checks if nullifier has been processed
     * @param nullifier Nullifier to check
     * @return bool True if processed
     */
    function isNullifierProcessed(bytes32 nullifier) external view returns (bool) {
        return _processedNullifiers[nullifier];
    }

    /**
     * @notice Gets conversion count for a campaign
     * @param campaignId Campaign ID
     * @return uint256 Conversion count
     */
    function getCampaignConversionCount(uint256 campaignId) external view returns (uint256) {
        return _campaignConversionCount[campaignId];
    }

    /**
     * @notice Batch submit conversions for gas efficiency
     * @param campaignIds Array of campaign IDs
     * @param clickHashes Array of click hashes
     * @param conversionHashes Array of conversion hashes
     * @param nullifiers Array of nullifiers
     * @param proofs Array of proofs
     * @return bool[] Array of success flags
     */
    function batchSubmitConversions(
        uint256[] memory campaignIds,
        bytes32[] memory clickHashes,
        bytes32[] memory conversionHashes,
        bytes32[] memory nullifiers,
        IConversionVerifier.ProofData[] memory proofs
    ) external nonReentrant returns (bool[] memory) {
        require(campaignIds.length == proofs.length, "Length mismatch");
        require(clickHashes.length == proofs.length, "Length mismatch");
        require(conversionHashes.length == proofs.length, "Length mismatch");
        require(nullifiers.length == proofs.length, "Length mismatch");

        bool[] memory results = new bool[](proofs.length);

        for (uint256 i = 0; i < proofs.length; i++) {
            results[i] = this.submitConversion(
                campaignIds[i],
                clickHashes[i],
                conversionHashes[i],
                nullifiers[i],
                proofs[i]
            );
        }

        return results;
    }

    /**
     * @notice Emergency pause functionality
     */
    function pause() external onlyOwner {
        // Implementation for pause functionality
    }
}

