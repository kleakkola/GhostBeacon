# GhostBeacon Integration Guide

## Overview

This guide explains how to integrate GhostBeacon into your Web3 application for privacy-preserving conversion tracking.

## Integration Methods

### 1. Smart Contract Integration

#### For Advertisers

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@ghostbeacon/contracts/interfaces/ICampaignRegistry.sol";
import "@ghostbeacon/contracts/interfaces/ITreasuryVault.sol";

contract AdvertiserIntegration {
    ICampaignRegistry public campaignRegistry;
    ITreasuryVault public treasuryVault;

    function createAndFundCampaign(
        uint256 budget,
        uint8 pricingModel,
        string memory metadataCID
    ) external payable {
        // Create campaign
        uint256 campaignId = campaignRegistry.createCampaign(
            budget,
            pricingModel,
            metadataCID
        );

        // Fund campaign
        treasuryVault.deposit{value: msg.value}(campaignId);
    }
}
```

#### For Publishers

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@ghostbeacon/contracts/interfaces/IAttributionGateway.sol";

contract PublisherIntegration {
    IAttributionGateway public attributionGateway;

    function submitConversion(
        uint256 campaignId,
        bytes32 clickHash,
        bytes32 conversionHash,
        bytes32 nullifier,
        IConversionVerifier.ProofData memory proof
    ) external {
        attributionGateway.submitConversion(
            campaignId,
            clickHash,
            conversionHash,
            nullifier,
            proof
        );
    }
}
```

### 2. JavaScript SDK Integration

#### Installation

```bash
npm install @ghostbeacon/sdk
```

#### Basic Usage

```javascript
import { GhostBeacon } from '@ghostbeacon/sdk';

// Initialize
const ghostBeacon = new GhostBeacon({
  network: 'polygonZkEVM',
  contractAddresses: {
    attributionGateway: '0x...',
    campaignRegistry: '0x...',
  }
});

// Track click
await ghostBeacon.trackClick(campaignId, {
  referrer: window.location.href,
  timestamp: Date.now()
});

// Track conversion
await ghostBeacon.trackConversion(campaignId, {
  value: 100, // conversion value
  metadata: {
    product: 'NFT-001',
    quantity: 1
  }
});
```

### 3. Browser Extension Integration

For privacy-first tracking, use our browser extension:

```javascript
// Content script
if (window.ghostBeacon) {
  window.ghostBeacon.init({
    campaigns: ['campaign-id-1', 'campaign-id-2']
  });

  // Automatic click tracking
  document.addEventListener('click', (e) => {
    if (e.target.hasAttribute('data-campaign')) {
      window.ghostBeacon.trackClick(e.target.dataset.campaign);
    }
  });
}
```

## Use Cases

### Use Case 1: NFT Marketplace Referral

```javascript
// Track referral link click
const campaignId = 'nft-marketplace-001';
await ghostBeacon.trackClick(campaignId);

// On NFT purchase
await ghostBeacon.trackConversion(campaignId, {
  value: nftPrice,
  metadata: {
    tokenId: nft.tokenId,
    collection: nft.collection
  }
});
```

### Use Case 2: DApp User Acquisition

```javascript
// Track landing page visit
await ghostBeacon.trackClick(campaignId, {
  source: 'twitter-ad',
  medium: 'social'
});

// On wallet connection (conversion)
await ghostBeacon.trackConversion(campaignId, {
  event: 'wallet_connected',
  walletType: 'metamask'
});
```

### Use Case 3: GameFi Player Acquisition

```javascript
// Track game install
await ghostBeacon.trackClick(campaignId);

// On first in-game purchase
await ghostBeacon.trackConversion(campaignId, {
  value: purchaseAmount,
  metadata: {
    itemType: 'weapon',
    level: playerLevel
  }
});
```

## ZK Proof Generation

### Client-Side Proof Generation

```javascript
import { generateConversionProof } from '@ghostbeacon/zk';

// Generate proof locally
const proof = await generateConversionProof({
  clickHash,
  conversionHash,
  userSecret,
  campaignRoot
});

// Submit with proof
await attributionGateway.submitConversion(
  campaignId,
  clickHash,
  conversionHash,
  nullifier,
  proof
);
```

### Server-Side Proof Generation

```javascript
const { ProofGenerator } = require('@ghostbeacon/zk-server');

const generator = new ProofGenerator({
  circuitPath: './circuits/conversion.circom',
  provingKeyPath: './keys/proving_key.zkey'
});

const proof = await generator.generate({
  clickHash,
  conversionHash,
  secret
});
```

## Event Listening

### Campaign Events

```javascript
// Listen for campaign creation
campaignRegistry.on('CampaignCreated', (campaignId, owner, budget, pricingModel) => {
  console.log(`New campaign ${campaignId} created by ${owner}`);
});

// Listen for budget updates
campaignRegistry.on('BudgetUpdated', (campaignId, oldBudget, newBudget) => {
  console.log(`Campaign ${campaignId} budget updated`);
});
```

### Conversion Events

```javascript
// Listen for conversions
attributionGateway.on('ConversionSubmitted', (campaignId, nullifier, submitter, timestamp) => {
  console.log(`Conversion submitted for campaign ${campaignId}`);
});

// Listen for rejections
attributionGateway.on('ConversionRejected', (campaignId, nullifier, reason) => {
  console.error(`Conversion rejected: ${reason}`);
});
```

## Analytics Integration

### Fetch Campaign Metrics

```javascript
import { AnalyticsClient } from '@ghostbeacon/analytics';

const analytics = new AnalyticsClient({
  aggregatorAddress: '0x...'
});

// Get campaign metrics
const metrics = await analytics.getCampaignMetrics(campaignId);
console.log(`Conversions: ${metrics.totalConversions}`);
console.log(`Spent: ${metrics.totalSpent}`);
console.log(`Avg Cost: ${metrics.totalSpent / metrics.totalConversions}`);

// Get conversion rate
const rate = await analytics.getConversionRate(campaignId);
console.log(`Conversion rate: ${rate}`);
```

### Real-Time Dashboard

```javascript
// Subscribe to real-time updates
analytics.subscribe(campaignId, (update) => {
  console.log('New conversion:', update);
  updateDashboard(update);
});
```

## Security Best Practices

### 1. Key Management

```javascript
// Never expose private keys in client-side code
// Use environment variables for sensitive data
const provider = new ethers.providers.JsonRpcProvider(
  process.env.RPC_URL
);

const signer = new ethers.Wallet(
  process.env.PRIVATE_KEY,
  provider
);
```

### 2. Input Validation

```javascript
function validateCampaignData(data) {
  if (!data.campaignId || data.campaignId <= 0) {
    throw new Error('Invalid campaign ID');
  }
  
  if (!data.clickHash || data.clickHash.length !== 66) {
    throw new Error('Invalid click hash');
  }
  
  // Add more validation...
}
```

### 3. Rate Limiting

```javascript
const rateLimiter = new RateLimiter({
  maxRequests: 10,
  windowMs: 60000 // 1 minute
});

async function trackConversion(data) {
  if (!rateLimiter.check()) {
    throw new Error('Rate limit exceeded');
  }
  
  return await ghostBeacon.trackConversion(data);
}
```

## Testing

### Unit Tests

```javascript
describe('GhostBeacon Integration', () => {
  it('should track click', async () => {
    const result = await ghostBeacon.trackClick(campaignId);
    expect(result.success).to.be.true;
  });

  it('should generate valid proof', async () => {
    const proof = await generateConversionProof(testData);
    expect(proof.a).to.have.lengthOf(2);
    expect(proof.b).to.have.lengthOf(2);
    expect(proof.c).to.have.lengthOf(2);
  });
});
```

### Integration Tests

```javascript
describe('End-to-End Conversion', () => {
  it('should complete full conversion flow', async () => {
    // Track click
    const clickData = await ghostBeacon.trackClick(campaignId);
    
    // Generate proof
    const proof = await generateConversionProof({
      clickHash: clickData.hash,
      conversionHash: ethers.utils.id('conversion'),
      secret: userSecret
    });
    
    // Submit conversion
    const tx = await attributionGateway.submitConversion(
      campaignId,
      clickData.hash,
      conversionHash,
      nullifier,
      proof
    );
    
    await tx.wait();
    
    // Verify metrics updated
    const metrics = await analyticsAggregator.getMetrics(campaignId);
    expect(metrics.totalConversions).to.equal(1);
  });
});
```

## Troubleshooting

### Common Issues

#### Proof Verification Failed

- Ensure circuit parameters match deployed verifier
- Check public inputs are correctly formatted
- Verify nullifier hasn't been used

#### Transaction Reverted

- Check campaign is active
- Verify sufficient budget in treasury
- Ensure caller is authorized

#### Events Not Emitting

- Verify contract addresses are correct
- Check RPC connection is stable
- Ensure listening to correct network

## Support

- GitHub Issues: https://github.com/kleakkola/GhostBeacon/issues
- Documentation: https://docs.ghostbeacon.io
- Discord: [Coming Soon]

---

Last Updated: January 2025

