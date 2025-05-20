// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title CampaignLib
 * @notice Library for campaign management utilities
 */
library CampaignLib {
    uint8 constant PRICING_MODEL_CPA = 0;
    uint8 constant PRICING_MODEL_CPL = 1;
    uint8 constant PRICING_MODEL_CPI = 2;

    /**
     * @notice Validates pricing model
     * @param pricingModel Pricing model type
     * @return bool True if valid
     */
    function isValidPricingModel(uint8 pricingModel) internal pure returns (bool) {
        return pricingModel <= PRICING_MODEL_CPI;
    }

    /**
     * @notice Calculates conversion cost based on pricing model
     * @param baseCost Base cost for conversion
     * @param weight Weight multiplier (for weighted conversions)
     * @param pricingModel Pricing model type
     * @return uint256 Final cost
     */
    function calculateConversionCost(
        uint256 baseCost,
        uint256 weight,
        uint8 pricingModel
    ) internal pure returns (uint256) {
        if (weight == 0) weight = 1;
        
        if (pricingModel == PRICING_MODEL_CPA) {
            // Cost Per Action - linear scaling
            return baseCost * weight;
        } else if (pricingModel == PRICING_MODEL_CPL) {
            // Cost Per Lead - fixed cost
            return baseCost;
        } else if (pricingModel == PRICING_MODEL_CPI) {
            // Cost Per Install - fixed cost with minimum threshold
            return baseCost;
        }
        
        return baseCost;
    }

    /**
     * @notice Calculates campaign efficiency score
     * @param conversions Number of conversions
     * @param spend Total amount spent
     * @return uint256 Efficiency score (scaled by 1e18)
     */
    function calculateEfficiency(
        uint256 conversions,
        uint256 spend
    ) internal pure returns (uint256) {
        if (spend == 0) return 0;
        return (conversions * 1e18) / spend;
    }

    /**
     * @notice Checks if campaign has sufficient budget
     * @param budget Campaign budget
     * @param spent Already spent amount
     * @param cost Cost to spend
     * @return bool True if sufficient
     */
    function hasSufficientBudget(
        uint256 budget,
        uint256 spent,
        uint256 cost
    ) internal pure returns (bool) {
        return (spent + cost) <= budget;
    }
}

