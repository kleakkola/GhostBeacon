# GhostBeacon

<div align="center">

**Zero-Knowledge Ad Attribution & Private Analytics Protocol**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Solidity](https://img.shields.io/badge/Solidity-0.8.20-blue)](https://soliditylang.org/)
[![Hardhat](https://img.shields.io/badge/Built%20with-Hardhat-yellow)](https://hardhat.org/)

</div>

## Overview

GhostBeacon is a zero-knowledge attribution and analytics protocol that enables Web3 advertisers to verify conversions and pay only for valid results—without revealing user identity, user path, or behavioral data. The system proves "a conversion happened and is linked to a campaign" but hides *who* converted and *how they behaved*.

## Key Features

- 🔒 **Zero-Knowledge Proofs**: User identity never exposed on-chain
- 🎯 **Verifiable Attribution**: Cryptographic proof of click→conversion linkage
- 🛡️ **Anti-Fraud**: Nullifier-based deduplication and reputation system
- 💰 **Performance-Based Billing**: Pay only for verified conversions
- 📊 **Privacy-Preserving Analytics**: Aggregated metrics with optional differential privacy
- 🔗 **Multi-Chain Support**: Polygon zkEVM and ZKsync Era

## Use Cases

- **CPA/CPL/CPI Campaigns**: Cost-per-action advertising with verifiable results
- **Web3 Game Marketing**: Privacy-preserving player acquisition tracking
- **dApp Growth Analytics**: User conversion funnels without identity tracking
- **Anti-Sybil Verification**: Cryptographic proof of unique conversions

## Architecture

### Core Contracts

1. **CampaignRegistry**: Campaign lifecycle and budget management
2. **ConversionVerifier**: Zero-knowledge proof verification
3. **AttributionGateway**: Conversion submission and routing
4. **BillingModule**: Multi-model billing (CPA/CPL/CPI)
5. **TreasuryVault**: Secure fund management with timelock
6. **AnalyticsAggregator**: Privacy-preserving metrics
7. **FraudDetector**: Reputation-based fraud prevention

### Data Flow

```
User → ZK Proof Generation → Attribution Gateway
  ↓
Conversion Verifier (validate proof)
  ↓
Billing Module (calculate & charge)
  ↓
Treasury Vault (process payment)
  ↓
Analytics Aggregator (record metrics)
```

## Quick Start

### Installation

```bash
npm install
```

### Compile Contracts

```bash
npx hardhat compile
```

### Run Tests

```bash
npx hardhat test
```

### Deploy

```bash
# Local deployment
npx hardhat run scripts/deploy.js

# Polygon zkEVM
npx hardhat run scripts/deploy.js --network polygonZkEVM

# ZKsync Era
npx hardhat run scripts/deploy.js --network zkSync
```

## Documentation

- [Architecture](docs/ARCHITECTURE.md) - System design and component overview
- [API Reference](docs/API.md) - Contract interfaces and functions
- [Deployment Guide](docs/DEPLOYMENT.md) - Step-by-step deployment instructions
- [Security Policy](docs/SECURITY.md) - Security considerations and reporting

## Technology Stack

- **Smart Contracts**: Solidity 0.8.20
- **Development**: Hardhat
- **Testing**: Chai, Ethers.js
- **ZK Proofs**: Groth16/Halo2 (circuit implementation pending)
- **Security**: OpenZeppelin Contracts
- **Networks**: Polygon zkEVM, ZKsync Era

## Pricing Models

- **CPA (Cost Per Action)**: Linear scaling based on conversion weight
- **CPL (Cost Per Lead)**: Fixed cost per qualified lead
- **CPI (Cost Per Install)**: Fixed cost per application install

## Security

GhostBeacon implements multiple layers of security:

- ✅ ReentrancyGuard on all payable functions
- ✅ Ownable access control
- ✅ Nullifier-based anti-replay
- ✅ Budget enforcement and limits
- ✅ Timelock for large transfers
- ✅ Reputation-based fraud detection

**Status**: Not yet audited. Do not use in production.

## Roadmap

### Phase 1: Core Protocol ✓
- [x] Smart contract implementation
- [x] Test suite development
- [x] Basic documentation

### Phase 2: ZK Integration (Q1 2025)
- [ ] Circuit design and implementation
- [ ] Proof generation SDK
- [ ] Browser/mobile client libraries

### Phase 3: Advanced Features (Q2 2025)
- [ ] zkTLS for full path privacy
- [ ] Cross-campaign frequency caps
- [ ] MPC-based fraud scoring
- [ ] Multi-token payment support

### Phase 4: Ecosystem (Q3 2025)
- [ ] Ad network integrations
- [ ] Unity/WebGL SDK
- [ ] Dashboard and analytics UI
- [ ] Subgraph indexing

## Contributing

We welcome contributions! Please follow these guidelines:

1. Fork the repository
2. Create a feature branch
3. Write tests for new functionality
4. Ensure all tests pass
5. Submit a pull request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contact

- GitHub: [@kleakkola](https://github.com/kleakkola)
- Project Repository: [GhostBeacon](https://github.com/kleakkola/GhostBeacon)

## Acknowledgments

- OpenZeppelin for secure contract libraries
- Hardhat for development framework
- ZK-SNARK research community

---

<div align="center">

**Built with ❤️ for Privacy-First Web3 Advertising**

</div>
