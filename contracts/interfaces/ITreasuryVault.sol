// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title ITreasuryVault
 * @notice Interface for secure budget and payout management
 */
interface ITreasuryVault {
    event Deposited(
        uint256 indexed campaignId,
        address indexed depositor,
        uint256 amount
    );

    event Withdrawn(
        address indexed recipient,
        uint256 amount
    );

    event PaymentProcessed(
        uint256 indexed campaignId,
        address indexed recipient,
        uint256 amount
    );

    function deposit(uint256 campaignId) external payable;

    function withdraw(address recipient, uint256 amount) external;

    function processPayment(
        uint256 campaignId,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function getCampaignBalance(uint256 campaignId) external view returns (uint256);
}

