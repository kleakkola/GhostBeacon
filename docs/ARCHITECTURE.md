# GhostBeacon Architecture

## System Overview

GhostBeacon is a zero-knowledge attribution and analytics protocol built on Polygon zkEVM and ZKsync. The system enables privacy-preserving conversion tracking for Web3 advertising campaigns.

## Core Components

### 1. Campaign Registry
- **Purpose**: Manages campaign lifecycle and budget allocation
- **Key Functions**:
  - Campaign creation and registration
  - Budget management and updates
  - Campaign activation/deactivation

### 2. Conversion Verifier
- **Purpose**: Verifies zero-knowledge proofs for conversion attribution
- **Technology**: Groth16/Halo2 proof system
- **Key Functions**:
  - ZK proof verification
  - Nullifier management (anti-replay)
  - Campaign root validation

### 3. Attribution Gateway
- **Purpose**: Main entry point for conversion submissions
- **Key Functions**:
  - Conversion request routing
  - Eligibility validation
  - Integration with verifier and billing modules

### 4. Billing Module
- **Purpose**: Handles conversion billing and settlement
- **Pricing Models**:
  - CPA (Cost Per Action)
  - CPL (Cost Per Lead)
  - CPI (Cost Per Install)
- **Key Functions**:
  - Fee calculation
  - Budget enforcement
  - Payment processing

### 5. Treasury Vault
- **Purpose**: Secure storage and management of campaign funds
- **Security Features**:
  - Authorization system for spenders
  - Timelock for large transfers
  - Pull-payment pattern
- **Key Functions**:
  - Fund deposits
  - Secured withdrawals
  - Payment processing

### 6. Analytics Aggregator
- **Purpose**: Campaign metrics and analytics
- **Privacy Features**:
  - Optional differential privacy
  - Aggregated metrics only
- **Key Functions**:
  - Conversion tracking
  - Spend monitoring
  - Performance metrics

### 7. Fraud Detector
- **Purpose**: Prevents fraudulent conversions
- **Detection Methods**:
  - User reputation scoring
  - Device fingerprinting
  - Rate limiting
  - Behavioral analysis
- **Key Functions**:
  - Fraud risk assessment
  - User blacklisting
  - Reputation management

## Data Flow

### Conversion Submission Flow

```
User Device
    │
    ├─→ Generate ZK Proof (off-chain)
    │
    ▼
Attribution Gateway
    │
    ├─→ Verify Campaign Active
    ├─→ Check Nullifier (anti-replay)
    │
    ▼
Conversion Verifier
    │
    ├─→ Validate Proof Structure
    ├─→ Verify ZK Proof
    │
    ▼
Billing Module
    │
    ├─→ Calculate Fee
    ├─→ Check Budget
    │
    ▼
Treasury Vault
    │
    ├─→ Process Payment
    │
    ▼
Analytics Aggregator
    │
    └─→ Record Metrics
```

## Security Model

### Privacy Guarantees
- **Zero-Knowledge**: User identity never exposed
- **Unlinkability**: Multiple conversions cannot be linked
- **Confidentiality**: User behavior remains private

### Anti-Fraud Measures
- **Nullifier System**: Prevents double-spending
- **Reputation Scoring**: Identifies suspicious patterns
- **Rate Limiting**: Prevents rapid-fire attacks
- **Proof Verification**: Ensures cryptographic validity

### Access Control
- **Owner**: Full system administration
- **Campaign Owners**: Campaign-specific management
- **Authorized Spenders**: Limited payment processing
- **Public**: Conversion submission only

## Gas Optimization

### Strategies
1. **Batch Operations**: Multiple conversions in single transaction
2. **Minimal Storage**: Only essential data on-chain
3. **Off-chain Computation**: ZK proof generation client-side
4. **Event-driven Analytics**: Use events instead of storage queries

## Upgrade Path

### Modularity
All core contracts are modular and can be upgraded independently:
- Registry → Gateway → Verifier → Billing → Vault
- Analytics and Fraud Detection are optional plugins

### Future Enhancements
- Cross-chain attribution
- zkTLS for full path privacy
- MPC-based fraud scoring
- Multi-token payment support

## Network Support

### Primary Networks
- **Polygon zkEVM**: Primary deployment target
- **ZKsync Era**: Alternative deployment

### Requirements
- EVM-compatible
- ZK-proof verification support
- Reasonable gas costs

