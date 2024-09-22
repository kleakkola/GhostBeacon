// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "../interfaces/IAnalyticsAggregator.sol";

/**
 * @title AnalyticsAggregator
 * @notice Aggregates campaign metrics with optional differential privacy
 */
contract AnalyticsAggregator is IAnalyticsAggregator, Ownable {
    mapping(uint256 => CampaignMetrics) private _metrics;
    mapping(uint256 => bool) private _dpEnabled;

    uint256 public constant DP_NOISE_FACTOR = 5; // Noise percentage for DP

    constructor() Ownable(msg.sender) {}

    /**
     * @notice Records a conversion for analytics
     * @param campaignId Campaign ID
     * @param amount Amount spent on conversion
     */
    function recordConversion(
        uint256 campaignId,
        uint256 amount
    ) external override onlyOwner {
        CampaignMetrics storage metrics = _metrics[campaignId];
        
        metrics.totalConversions += 1;
        metrics.totalSpent += amount;
        metrics.lastConversionTime = block.timestamp;

        emit MetricsUpdated(campaignId, metrics.totalConversions, metrics.totalSpent);
    }

    /**
     * @notice Gets campaign metrics
     * @param campaignId Campaign ID
     * @return CampaignMetrics struct
     */
    function getMetrics(
        uint256 campaignId
    ) external view override returns (CampaignMetrics memory) {
        CampaignMetrics memory metrics = _metrics[campaignId];
        
        // Apply differential privacy noise if enabled
        if (_dpEnabled[campaignId]) {
            metrics.totalConversions = _applyDPNoise(metrics.totalConversions);
            metrics.totalSpent = _applyDPNoise(metrics.totalSpent);
        }
        
        return metrics;
    }

    /**
     * @notice Gets total conversions for a campaign
     * @param campaignId Campaign ID
     * @return uint256 Total conversions
     */
    function getTotalConversions(
        uint256 campaignId
    ) external view override returns (uint256) {
        uint256 conversions = _metrics[campaignId].totalConversions;
        
        if (_dpEnabled[campaignId]) {
            conversions = _applyDPNoise(conversions);
        }
        
        return conversions;
    }

    /**
     * @notice Gets total spent for a campaign
     * @param campaignId Campaign ID
     * @return uint256 Total spent
     */
    function getTotalSpent(uint256 campaignId) external view returns (uint256) {
        uint256 spent = _metrics[campaignId].totalSpent;
        
        if (_dpEnabled[campaignId]) {
            spent = _applyDPNoise(spent);
        }
        
        return spent;
    }

    /**
     * @notice Enables differential privacy for a campaign
     * @param campaignId Campaign ID
     * @param enabled Whether to enable DP
     */
    function setDifferentialPrivacy(
        uint256 campaignId,
        bool enabled
    ) external onlyOwner {
        _dpEnabled[campaignId] = enabled;
        _metrics[campaignId].dpEnabled = enabled;
    }

    /**
     * @notice Checks if DP is enabled for a campaign
     * @param campaignId Campaign ID
     * @return bool True if enabled
     */
    function isDPEnabled(uint256 campaignId) external view returns (bool) {
        return _dpEnabled[campaignId];
    }

    /**
     * @notice Gets conversion rate (conversions per unit spent)
     * @param campaignId Campaign ID
     * @return uint256 Conversion rate (scaled by 1e18)
     */
    function getConversionRate(uint256 campaignId) external view returns (uint256) {
        CampaignMetrics memory metrics = _metrics[campaignId];
        
        if (metrics.totalSpent == 0) {
            return 0;
        }
        
        return (metrics.totalConversions * 1e18) / metrics.totalSpent;
    }

    /**
     * @notice Gets average cost per conversion
     * @param campaignId Campaign ID
     * @return uint256 Average cost
     */
    function getAverageCost(uint256 campaignId) external view returns (uint256) {
        CampaignMetrics memory metrics = _metrics[campaignId];
        
        if (metrics.totalConversions == 0) {
            return 0;
        }
        
        return metrics.totalSpent / metrics.totalConversions;
    }

    /**
     * @notice Resets metrics for a campaign (admin only)
     * @param campaignId Campaign ID
     */
    function resetMetrics(uint256 campaignId) external onlyOwner {
        delete _metrics[campaignId];
    }

    /**
     * @notice Applies differential privacy noise to a value
     * @param value Original value
     * @return uint256 Noised value
     */
    function _applyDPNoise(uint256 value) private view returns (uint256) {
        if (value == 0) return 0;
        
        // Generate pseudo-random noise based on block data
        uint256 noise = uint256(
            keccak256(abi.encodePacked(block.timestamp, block.prevrandao, value))
        ) % DP_NOISE_FACTOR;
        
        // Apply noise (±noise%)
        uint256 adjustment = (value * noise) / 100;
        
        // Randomly add or subtract
        if (uint256(keccak256(abi.encodePacked(value, block.timestamp))) % 2 == 0) {
            return value + adjustment;
        } else {
            return value > adjustment ? value - adjustment : value;
        }
    }

    /**
     * @notice Gets metrics for multiple campaigns
     * @param campaignIds Array of campaign IDs
     * @return CampaignMetrics[] Array of metrics
     */
    function getBatchMetrics(
        uint256[] memory campaignIds
    ) external view returns (CampaignMetrics[] memory) {
        CampaignMetrics[] memory results = new CampaignMetrics[](campaignIds.length);
        
        for (uint256 i = 0; i < campaignIds.length; i++) {
            results[i] = _metrics[campaignIds[i]];
            
            if (_dpEnabled[campaignIds[i]]) {
                results[i].totalConversions = _applyDPNoise(results[i].totalConversions);
                results[i].totalSpent = _applyDPNoise(results[i].totalSpent);
            }
        }
        
        return results;
    }
}

