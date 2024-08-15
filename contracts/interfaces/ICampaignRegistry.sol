// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title ICampaignRegistry
 * @notice Interface for campaign registration and management
 */
interface ICampaignRegistry {
    struct Campaign {
        address owner;
        uint256 budget;
        uint256 spent;
        uint8 pricingModel; // 0: CPA, 1: CPL, 2: CPI
        string metadataCID;
        bool active;
        uint256 createdAt;
    }

    event CampaignCreated(
        uint256 indexed campaignId,
        address indexed owner,
        uint256 budget,
        uint8 pricingModel
    );

    event BudgetUpdated(
        uint256 indexed campaignId,
        uint256 oldBudget,
        uint256 newBudget
    );

    event CampaignClosed(uint256 indexed campaignId);

    function createCampaign(
        uint256 budget,
        uint8 pricingModel,
        string memory metadataCID
    ) external returns (uint256 campaignId);

    function updateBudget(uint256 campaignId, uint256 newBudget) external;

    function closeCampaign(uint256 campaignId) external;

    function getCampaign(uint256 campaignId) external view returns (Campaign memory);

    function isCampaignActive(uint256 campaignId) external view returns (bool);
}

