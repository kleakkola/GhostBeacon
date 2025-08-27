// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "../interfaces/IBillingModule.sol";
import "../interfaces/ICampaignRegistry.sol";
import "../interfaces/ITreasuryVault.sol";
import "../libraries/CampaignLib.sol";

/**
 * @title BillingModule
 * @notice Handles conversion billing and budget management
 */
contract BillingModule is IBillingModule, Ownable, ReentrancyGuard {
    using CampaignLib for uint8;

    ICampaignRegistry public immutable campaignRegistry;
    ITreasuryVault public immutable treasuryVault;

    uint256 public constant BASE_COST = 0.001 ether;
    uint256 public constant MAX_WEIGHT = 100;
    uint256 public constant MIN_WEIGHT = 1;

    mapping(uint256 => address) public campaignPublishers;

    modifier onlyActiveGateway() {
        require(msg.sender == address(this) || msg.sender == owner(), "Not authorized");
        _;
    }

    constructor(
        address _campaignRegistry,
        address _treasuryVault
    ) Ownable(msg.sender) {
        require(_campaignRegistry != address(0), "Invalid registry");
        require(_treasuryVault != address(0), "Invalid vault");
        
        campaignRegistry = ICampaignRegistry(_campaignRegistry);
        treasuryVault = ITreasuryVault(_treasuryVault);
    }

    /**
     * @notice Processes a conversion and handles billing
     * @param campaignId Campaign ID
     * @param nullifier Conversion nullifier
     * @param weight Conversion weight (quality score)
     * @return bool True if successful
     */
    function processConversion(
        uint256 campaignId,
        bytes32 nullifier,
        uint256 weight
    ) external override onlyActiveGateway nonReentrant returns (bool) {
        require(weight > 0 && weight <= MAX_WEIGHT, "Invalid weight");

        ICampaignRegistry.Campaign memory campaign = campaignRegistry.getCampaign(campaignId);
        require(campaign.active, "Campaign not active");

        uint256 fee = calculateFee(campaignId, weight);
        
        require(
            CampaignLib.hasSufficientBudget(campaign.budget, campaign.spent, fee),
            "Insufficient budget"
        );

        // Get publisher for this campaign
        address publisher = campaignPublishers[campaignId];
        if (publisher == address(0)) {
            publisher = owner(); // Fallback to owner if no publisher set
        }

        // Process payment from treasury
        bool success = treasuryVault.processPayment(campaignId, publisher, fee);
        require(success, "Payment failed");

        emit ConversionPaid(campaignId, nullifier, fee, publisher);

        // Check if campaign is exhausted
        if (campaign.spent + fee >= campaign.budget) {
            emit CampaignExhausted(campaignId);
        }

        return true;
    }

    /**
     * @notice Calculates conversion fee based on pricing model
     * @dev Fee calculation varies by pricing model: CPA scales with weight, CPL/CPI fixed
     * @param campaignId Campaign ID
     * @param weight Conversion weight
     * @return uint256 Fee amount
     */
    function calculateFee(
        uint256 campaignId,
        uint256 weight
    ) public view override returns (uint256) {
        ICampaignRegistry.Campaign memory campaign = campaignRegistry.getCampaign(campaignId);
        
        return CampaignLib.calculateConversionCost(
            BASE_COST,
            weight,
            campaign.pricingModel
        );
    }

    /**
     * @notice Gets remaining budget for a campaign
     * @param campaignId Campaign ID
     * @return uint256 Remaining budget
     */
    function getRemainingBudget(
        uint256 campaignId
    ) external view override returns (uint256) {
        ICampaignRegistry.Campaign memory campaign = campaignRegistry.getCampaign(campaignId);
        
        if (campaign.spent >= campaign.budget) {
            return 0;
        }
        
        return campaign.budget - campaign.spent;
    }

    /**
     * @notice Sets publisher address for a campaign
     * @param campaignId Campaign ID
     * @param publisher Publisher address
     */
    function setPublisher(uint256 campaignId, address publisher) external onlyOwner {
        require(publisher != address(0), "Invalid publisher");
        campaignPublishers[campaignId] = publisher;
    }

    /**
     * @notice Gets publisher for a campaign
     * @param campaignId Campaign ID
     * @return address Publisher address
     */
    function getPublisher(uint256 campaignId) external view returns (address) {
        return campaignPublishers[campaignId];
    }

    /**
     * @notice Estimates total cost for multiple conversions
     * @param campaignId Campaign ID
     * @param weights Array of conversion weights
     * @return uint256 Total estimated cost
     */
    function estimateBatchCost(
        uint256 campaignId,
        uint256[] memory weights
    ) external view returns (uint256) {
        uint256 totalCost = 0;
        
        for (uint256 i = 0; i < weights.length; i++) {
            totalCost += calculateFee(campaignId, weights[i]);
        }
        
        return totalCost;
    }
}

