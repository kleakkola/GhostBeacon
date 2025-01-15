// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "../interfaces/ICampaignRegistry.sol";
import "../libraries/CampaignLib.sol";

/**
 * @title CampaignRegistry
 * @notice Manages campaign registration, budgets, and lifecycle
 */
contract CampaignRegistry is ICampaignRegistry, Ownable, ReentrancyGuard {
    using CampaignLib for uint8;

    uint256 private _campaignIdCounter;
    mapping(uint256 => Campaign) private _campaigns;
    mapping(address => uint256[]) private _ownerCampaigns;

    modifier onlyCampaignOwner(uint256 campaignId) {
        require(_campaigns[campaignId].owner == msg.sender, "Not campaign owner");
        _;
    }

    modifier campaignExists(uint256 campaignId) {
        require(_campaigns[campaignId].owner != address(0), "Campaign does not exist");
        _;
    }

    constructor() Ownable(msg.sender) {
        _campaignIdCounter = 1;
    }

    /**
     * @notice Creates a new campaign
     * @param budget Campaign budget in wei
     * @param pricingModel Pricing model (0: CPA, 1: CPL, 2: CPI)
     * @param metadataCID IPFS CID for campaign metadata
     * @return campaignId The ID of the created campaign
     */
    function createCampaign(
        uint256 budget,
        uint8 pricingModel,
        string memory metadataCID
    ) external override nonReentrant returns (uint256 campaignId) {
        require(budget > 0, "Budget must be greater than 0");
        require(CampaignLib.isValidPricingModel(pricingModel), "Invalid pricing model");
        require(bytes(metadataCID).length > 0, "Metadata CID required");

        campaignId = _campaignIdCounter++;

        _campaigns[campaignId] = Campaign({
            owner: msg.sender,
            budget: budget,
            spent: 0,
            pricingModel: pricingModel,
            metadataCID: metadataCID,
            active: true,
            createdAt: block.timestamp
        });

        _ownerCampaigns[msg.sender].push(campaignId);

        emit CampaignCreated(campaignId, msg.sender, budget, pricingModel);
    }

    /**
     * @notice Updates campaign budget
     * @param campaignId Campaign ID
     * @param newBudget New budget amount
     */
    function updateBudget(
        uint256 campaignId,
        uint256 newBudget
    ) external override onlyCampaignOwner(campaignId) campaignExists(campaignId) {
        Campaign storage campaign = _campaigns[campaignId];
        require(campaign.active, "Campaign is not active");
        require(newBudget >= campaign.spent, "New budget must be >= spent amount");

        uint256 oldBudget = campaign.budget;
        campaign.budget = newBudget;

        emit BudgetUpdated(campaignId, oldBudget, newBudget);
    }

    /**
     * @notice Closes a campaign
     * @param campaignId Campaign ID
     */
    function closeCampaign(
        uint256 campaignId
    ) external override onlyCampaignOwner(campaignId) campaignExists(campaignId) {
        Campaign storage campaign = _campaigns[campaignId];
        require(campaign.active, "Campaign already closed");

        campaign.active = false;

        emit CampaignClosed(campaignId);
    }

    /**
     * @notice Gets campaign details
     * @param campaignId Campaign ID
     * @return Campaign struct
     */
    function getCampaign(
        uint256 campaignId
    ) external view override campaignExists(campaignId) returns (Campaign memory) {
        return _campaigns[campaignId];
    }

    /**
     * @notice Checks if campaign is active
     * @param campaignId Campaign ID
     * @return bool True if active
     */
    function isCampaignActive(uint256 campaignId) external view override returns (bool) {
        return _campaigns[campaignId].active;
    }

    /**
     * @notice Gets campaigns owned by an address
     * @param owner Owner address
     * @return uint256[] Array of campaign IDs
     */
    function getCampaignsByOwner(address owner) external view returns (uint256[] memory) {
        return _ownerCampaigns[owner];
    }

    /**
     * @notice Internal function to update spent amount
     * @param campaignId Campaign ID
     * @param amount Amount to add to spent
     */
    function _updateSpent(uint256 campaignId, uint256 amount) internal {
        _campaigns[campaignId].spent += amount;
    }

    /**
     * @notice Gets campaign spent amount
     * @param campaignId Campaign ID
     * @return uint256 Spent amount
     */
    function getCampaignSpent(uint256 campaignId) external view returns (uint256) {
        return _campaigns[campaignId].spent;
    }

    /**
     * @notice Gets campaign remaining budget
     * @param campaignId Campaign ID
     * @return uint256 Remaining budget
     */
    function getCampaignRemainingBudget(uint256 campaignId) external view returns (uint256) {
        Campaign memory campaign = _campaigns[campaignId];
        if (campaign.spent >= campaign.budget) {
            return 0;
        }
        return campaign.budget - campaign.spent;
    }

    /**
     * @notice Gets total number of campaigns
     * @return uint256 Total campaigns created
     */
    function getTotalCampaigns() external view returns (uint256) {
        return _campaignIdCounter - 1;
    }
}

