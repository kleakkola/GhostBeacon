// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./IConversionVerifier.sol";

/**
 * @title IAttributionGateway
 * @notice Interface for conversion submission and routing
 */
interface IAttributionGateway {
    event ConversionSubmitted(
        uint256 indexed campaignId,
        bytes32 indexed nullifier,
        address indexed submitter,
        uint256 timestamp
    );

    event ConversionRejected(
        uint256 indexed campaignId,
        bytes32 indexed nullifier,
        string reason
    );

    function submitConversion(
        uint256 campaignId,
        bytes32 clickHash,
        bytes32 conversionHash,
        bytes32 nullifier,
        IConversionVerifier.ProofData memory proof
    ) external returns (bool);
}

