// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title Events
 * @notice Event definitions for GhostBeacon contracts
 */
library Events {
    // Campaign Events
    event CampaignCreated(
        uint256 indexed campaignId,
        address indexed owner,
        uint256 budget,
        uint8 pricingModel,
        string metadataCID
    );

    event CampaignBudgetUpdated(
        uint256 indexed campaignId,
        uint256 oldBudget,
        uint256 newBudget
    );

    event CampaignStatusChanged(
        uint256 indexed campaignId,
        bool active
    );

    // Conversion Events
    event ConversionSubmitted(
        uint256 indexed campaignId,
        bytes32 indexed nullifier,
        address indexed submitter,
        uint256 timestamp
    );

    event ConversionVerified(
        uint256 indexed campaignId,
        bytes32 indexed nullifier,
        bool verified
    );

    event ConversionRejected(
        uint256 indexed campaignId,
        bytes32 indexed nullifier,
        string reason
    );

    // Billing Events
    event ConversionBilled(
        uint256 indexed campaignId,
        bytes32 indexed nullifier,
        uint256 amount
    );

    event PublisherPaid(
        uint256 indexed campaignId,
        address indexed publisher,
        uint256 amount
    );

    event BudgetExhausted(
        uint256 indexed campaignId,
        uint256 totalSpent
    );

    // Treasury Events
    event FundsDeposited(
        uint256 indexed campaignId,
        address indexed depositor,
        uint256 amount
    );

    event FundsWithdrawn(
        address indexed recipient,
        uint256 amount
    );

    event SpenderAuthorized(
        address indexed spender
    );

    event SpenderRevoked(
        address indexed spender
    );

    // Analytics Events
    event MetricsRecorded(
        uint256 indexed campaignId,
        uint256 totalConversions,
        uint256 totalSpent
    );

    event DifferentialPrivacyToggled(
        uint256 indexed campaignId,
        bool enabled
    );

    // Fraud Detection Events
    event UserReputationUpdated(
        address indexed user,
        uint256 newScore
    );

    event SuspiciousActivityDetected(
        address indexed user,
        string reason,
        uint256 timestamp
    );

    event UserBlacklistStatusChanged(
        address indexed user,
        bool blacklisted
    );

    event DeviceScoreUpdated(
        bytes32 indexed deviceId,
        uint256 score
    );
}

