# Frequently Asked Questions (FAQ)

## General Questions

### What is GhostBeacon?

GhostBeacon is a zero-knowledge attribution protocol that enables Web3 advertisers to track and verify conversions without compromising user privacy. It uses ZK proofs to prove a conversion happened without revealing who converted or their behavior.

### Why use zero-knowledge proofs for advertising?

Traditional advertising tracking exposes user identity and behavior. ZK proofs allow verification of conversion events cryptographically while keeping all user data private.

### Which blockchains are supported?

Currently:
- Polygon zkEVM (primary)
- ZKsync Era (alternative)

Future support planned for other EVM-compatible ZK rollups.

### Is the code audited?

Not yet. The protocol is in active development. A security audit is planned before mainnet deployment. Do not use in production.

## Technical Questions

### How does the proof generation work?

1. User clicks an ad (tracked locally)
2. User converts (e.g., makes purchase)
3. Client generates ZK proof linking click to conversion
4. Proof submitted on-chain without revealing user identity

### What happens if I lose my secret?

The user secret is used to generate nullifiers. If lost, you won't be able to prove previous conversions, but new conversions can use a new secret. Best practice: back up secrets securely.

### Can conversions be double-spent?

No. Each conversion generates a unique nullifier that can only be used once. Attempting to reuse a nullifier will cause the transaction to revert.

###  What are the gas costs?

Gas costs vary by operation:
- Campaign creation: ~150k gas
- Conversion submission: ~200k gas
- Proof verification: ~250k gas

Batch operations can reduce per-conversion costs by 30-40%.

### Why use Groth16 instead of Halo2?

Both are supported. Groth16 offers:
- Smaller proof size
- Faster on-chain verification
- Wider tooling support

Halo2 offers:
- No trusted setup
- More flexible circuits
- Future-proof design

Choose based on your requirements.

## Integration Questions

### How do I integrate as an advertiser?

1. Deploy or connect to GhostBeacon contracts
2. Create a campaign with budget
3. Fund the campaign treasury
4. Provide campaign details to publishers
5. Monitor conversions via analytics

### How do I integrate as a publisher?

1. Add GhostBeacon SDK to your site
2. Track clicks with campaign IDs
3. Generate proofs client-side on conversion
4. Submit proofs to AttributionGateway
5. Receive payment from treasury

### Can I use GhostBeacon for mobile apps?

Yes! The SDK supports:
- React Native
- Flutter (community)
- Native iOS/Android (in development)

### Do users need wallets?

Users don't need wallets for tracking. However, proof generation happens client-side, so users need:
- JavaScript-enabled browser, or
- Mobile app with SDK integrated

### How do I generate ZK proofs?

Use our SDK:
```javascript
import { generateProof } from '@ghostbeacon/zk';

const proof = await generateProof({
  clickHash,
  conversionHash,
  secret
});
```

## Business Questions

### What pricing models are supported?

- CPA (Cost Per Action): Pay per verified action
- CPL (Cost Per Lead): Pay per qualified lead
- CPI (Cost Per Install): Pay per app install

### How is pricing calculated?

Base cost is 0.001 ETH per conversion. Final cost depends on:
- Pricing model selected
- Conversion weight (quality score)
- Network gas fees

### Can I set a campaign budget limit?

Yes. Campaigns have hard budget limits. Once exhausted, no more conversions are accepted until budget is increased.

### How do payouts work?

Payouts are automatic:
1. Conversion verified
2. Fee calculated based on pricing model
3. Payment sent from campaign treasury to publisher
4. Event emitted for tracking

### What happens to unused budget?

Campaign owners can:
- Increase budget at any time
- Close campaign and withdraw unused funds
- Transfer remaining budget to new campaign

## Privacy Questions

### What data is stored on-chain?

On-chain data includes:
- Campaign parameters (budget, pricing)
- Nullifiers (anonymous identifiers)
- Aggregate metrics (total conversions, spend)

User identity and behavior are never stored.

### Can conversions be linked to users?

No. The ZK proof system ensures:
- No user identifiers on-chain
- No linkage between multiple conversions
- No behavioral data exposed

### Is differential privacy used?

Optional. Campaign owners can enable differential privacy for analytics, which adds statistical noise to metrics.

### Who can see campaign metrics?

- Campaign owners: Full access to their campaigns
- Public: Aggregate metrics only (if DP enabled)
- Publishers: Conversion counts for campaigns they participate in

## Security Questions

### How is fraud prevented?

Multiple layers:
- Nullifier system prevents replay attacks
- Reputation scoring detects suspicious patterns
- Rate limiting prevents rapid-fire attacks
- Device fingerprinting identifies abnormal behavior

### What if a proof is forged?

ZK proofs are cryptographically secure. A forged proof would fail verification. The probability of successful forgery is negligible (2^-128 security).

### Can campaign funds be drained?

No. Protections include:
- Budget enforcement (hard limits)
- ReentrancyGuard on all payable functions
- Timelock for large transfers
- Access control on treasury

### What if a contract is upgraded?

Contracts use a modular design. Individual modules can be upgraded without affecting others. Critical upgrades require:
- Multisig approval
- Timelock delay
- Community notification

## Troubleshooting

### My conversion was rejected. Why?

Common reasons:
- Nullifier already used (duplicate)
- Campaign inactive or budget exhausted
- Invalid proof structure
- Mismatched public inputs
- Rate limit exceeded

### Transaction keeps reverting

Check:
- Campaign is active
- Sufficient budget in treasury
- Valid proof format
- Gas limit is adequate
- Contract addresses correct

### Proof generation is slow

Proof generation can take 5-10 seconds depending on:
- Circuit complexity
- Device performance
- Browser capabilities

Consider:
- Use Web Workers for async generation
- Cache proving keys
- Optimize circuit parameters

### Metrics don't match expectations

If using differential privacy, metrics include statistical noise for privacy. Disable DP for exact counts (reduces privacy).

## Support

Still have questions?

- GitHub Issues: https://github.com/kleakkola/GhostBeacon/issues
- Documentation: /docs
- Discord: [Coming Soon]

---

Last Updated: February 2025
