// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title IBillingModule
 * @notice Interface for campaign billing and settlement
 */
interface IBillingModule {
    event ConversionPaid(
        uint256 indexed campaignId,
        bytes32 indexed nullifier,
        uint256 amount,
        address recipient
    );

    event CampaignExhausted(uint256 indexed campaignId);

    function processConversion(
        uint256 campaignId,
        bytes32 nullifier,
        uint256 weight
    ) external returns (bool);

    function calculateFee(
        uint256 campaignId,
        uint256 weight
    ) external view returns (uint256);

    function getRemainingBudget(uint256 campaignId) external view returns (uint256);
}

