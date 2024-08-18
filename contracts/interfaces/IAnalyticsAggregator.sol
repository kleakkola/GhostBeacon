// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title IAnalyticsAggregator
 * @notice Interface for campaign metrics aggregation
 */
interface IAnalyticsAggregator {
    struct CampaignMetrics {
        uint256 totalConversions;
        uint256 totalSpent;
        uint256 lastConversionTime;
        bool dpEnabled; // Differential Privacy enabled
    }

    event MetricsUpdated(
        uint256 indexed campaignId,
        uint256 conversions,
        uint256 spent
    );

    function recordConversion(
        uint256 campaignId,
        uint256 amount
    ) external;

    function getMetrics(uint256 campaignId) external view returns (CampaignMetrics memory);

    function getTotalConversions(uint256 campaignId) external view returns (uint256);
}

