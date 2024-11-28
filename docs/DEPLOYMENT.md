# GhostBeacon Deployment Guide

## Prerequisites

- Node.js v18 or higher
- npm or yarn
- Hardhat
- Network RPC endpoints (Polygon zkEVM / ZKsync)
- Private key with sufficient funds for deployment

## Installation

```bash
npm install
```

## Configuration

1. Copy the environment template:
```bash
cp .env.example .env
```

2. Fill in your environment variables:
```env
POLYGON_ZKEVM_RPC=https://...
ZKSYNC_RPC=https://...
PRIVATE_KEY=your_private_key_here
ETHERSCAN_API_KEY=your_api_key
```

## Compilation

Compile all contracts:
```bash
npm run compile
```

## Testing

Run the full test suite:
```bash
npm test
```

Run specific test file:
```bash
npx hardhat test test/CampaignRegistry.test.js
```

## Deployment

### Local Deployment (Hardhat Network)

```bash
npx hardhat run scripts/deploy.js
```

### Polygon zkEVM Deployment

```bash
npx hardhat run scripts/deploy.js --network polygonZkEVM
```

### ZKsync Deployment

```bash
npx hardhat run scripts/deploy.js --network zkSync
```

## Post-Deployment Configuration

After deployment, you need to configure the contract connections:

1. **Authorize Billing Module as Spender:**
```javascript
await treasuryVault.authorizeSpender(billingModuleAddress);
```

2. **Set Billing Module in Attribution Gateway:**
```javascript
await attributionGateway.setBillingModule(billingModuleAddress);
```

3. **Set Analytics Aggregator in Attribution Gateway:**
```javascript
await attributionGateway.setAnalyticsAggregator(analyticsAggregatorAddress);
```

4. **Update Campaign Roots in Verifier:**
```javascript
await conversionVerifier.updateCampaignRoot(campaignId, merkleRoot);
```

## Contract Verification

Verify contracts on block explorer:

```bash
npx hardhat verify --network polygonZkEVM CONTRACT_ADDRESS [CONSTRUCTOR_ARGS]
```

Example:
```bash
npx hardhat verify --network polygonZkEVM 0x123... 0xABC... 0xDEF...
```

## Deployed Addresses

After deployment, save the contract addresses for reference:

```json
{
  "network": "polygonZkEVM",
  "campaignRegistry": "0x...",
  "conversionVerifier": "0x...",
  "treasuryVault": "0x...",
  "billingModule": "0x...",
  "analyticsAggregator": "0x...",
  "attributionGateway": "0x...",
  "fraudDetector": "0x..."
}
```

## Security Considerations

### Before Mainnet Deployment

1. **Audit**: Get contracts audited by reputable security firm
2. **Test Coverage**: Ensure >95% code coverage
3. **Gas Optimization**: Review and optimize gas costs
4. **Access Control**: Verify all ownership and permissions
5. **Upgrade Path**: Plan for contract upgrades if needed
6. **Monitoring**: Set up event monitoring and alerting

### Recommended Steps

1. Deploy on testnet first
2. Run integration tests
3. Perform security review
4. Deploy to mainnet with timelock
5. Transfer ownership to multisig
6. Monitor for first 24-48 hours

## Troubleshooting

### Compilation Errors

If you encounter compilation errors:
```bash
npx hardhat clean
npx hardhat compile
```

### Deployment Failures

- Check gas price and network congestion
- Verify RPC endpoint is responsive
- Ensure sufficient ETH for gas fees
- Check constructor arguments are correct

### Transaction Reverts

- Review error messages in transaction logs
- Check contract state and permissions
- Verify input parameters are valid
- Ensure contracts are properly configured

## Mainnet Checklist

- [ ] All tests passing
- [ ] Security audit completed
- [ ] Gas costs optimized
- [ ] Deployment script tested on testnet
- [ ] Multisig wallet prepared
- [ ] Emergency procedures documented
- [ ] Monitoring setup complete
- [ ] Contract verification ready
- [ ] Documentation updated
- [ ] Team notified of deployment

## Support

For deployment support:
- GitHub Issues
- Documentation: /docs
- Discord Community (if available)

