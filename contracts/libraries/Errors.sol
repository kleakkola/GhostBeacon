// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title Errors
 * @notice Custom error definitions for GhostBeacon contracts
 */
library Errors {
    // Campaign Registry Errors
    error InvalidBudget();
    error InvalidPricingModel();
    error MetadataCIDRequired();
    error CampaignNotFound();
    error NotCampaignOwner();
    error CampaignNotActive();
    error CampaignAlreadyClosed();
    error InsufficientBudgetIncrease();

    // Conversion Verifier Errors
    error NullifierAlreadyUsed();
    error InvalidProofStructure();
    error InvalidPublicInputsLength();
    error ProofVerificationFailed();
    error InvalidCampaignRoot();

    // Attribution Gateway Errors
    error InvalidVerifierAddress();
    error InvalidRegistryAddress();
    error InvalidBillingModuleAddress();
    error InvalidAnalyticsAddress();
    error ConversionAlreadyProcessed();
    error ArrayLengthMismatch();

    // Billing Module Errors
    error InvalidWeight();
    error InsufficientCampaignBudget();
    error PaymentProcessingFailed();
    error InvalidPublisherAddress();

    // Treasury Vault Errors
    error ZeroDepositAmount();
    error InvalidRecipientAddress();
    error InsufficientVaultBalance();
    error InsufficientCampaignBalance();
    error TransferFailed();
    error NotAuthorizedSpender();
    error TimelockNotExpired();

    // Analytics Aggregator Errors
    error InvalidCampaignId();
    error DPAlreadyEnabled();
    error DPAlreadyDisabled();

    // Fraud Detector Errors
    error UserBlacklisted();
    error ReputationBelowThreshold();
    error RateLimitExceeded();
    error InvalidDeviceId();
    error ScoreOutOfRange();
    error UserAlreadyBlacklisted();
    error UserNotBlacklisted();
}

