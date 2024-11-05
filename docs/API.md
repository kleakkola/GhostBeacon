# GhostBeacon API Reference

## Campaign Registry

### createCampaign
```solidity
function createCampaign(
    uint256 budget,
    uint8 pricingModel,
    string memory metadataCID
) external returns (uint256 campaignId)
```
Creates a new advertising campaign.

**Parameters:**
- `budget`: Campaign budget in wei
- `pricingModel`: 0=CPA, 1=CPL, 2=CPI
- `metadataCID`: IPFS content ID for campaign metadata

**Returns:**
- `campaignId`: Unique identifier for the campaign

### updateBudget
```solidity
function updateBudget(uint256 campaignId, uint256 newBudget) external
```
Updates campaign budget (owner only).

### closeCampaign
```solidity
function closeCampaign(uint256 campaignId) external
```
Deactivates a campaign (owner only).

### getCampaign
```solidity
function getCampaign(uint256 campaignId) external view returns (Campaign memory)
```
Retrieves campaign details.

## Conversion Verifier

### verifyConversionProof
```solidity
function verifyConversionProof(
    uint256 campaignId,
    bytes32 clickHash,
    bytes32 conversionHash,
    bytes32 nullifier,
    ProofData memory proof
) external view returns (bool)
```
Verifies a zero-knowledge conversion proof.

**Parameters:**
- `campaignId`: Target campaign ID
- `clickHash`: Hash of click event data
- `conversionHash`: Hash of conversion data
- `nullifier`: Unique identifier to prevent replays
- `proof`: ZK proof structure (Groth16)

**Returns:**
- `bool`: True if proof is valid

### isNullifierUsed
```solidity
function isNullifierUsed(bytes32 nullifier) external view returns (bool)
```
Checks if a nullifier has been used.

## Attribution Gateway

### submitConversion
```solidity
function submitConversion(
    uint256 campaignId,
    bytes32 clickHash,
    bytes32 conversionHash,
    bytes32 nullifier,
    IConversionVerifier.ProofData memory proof
) external returns (bool)
```
Submits a conversion with ZK proof for attribution.

**Events Emitted:**
- `ConversionSubmitted`: On successful submission
- `ConversionRejected`: On validation failure

### batchSubmitConversions
```solidity
function batchSubmitConversions(
    uint256[] memory campaignIds,
    bytes32[] memory clickHashes,
    bytes32[] memory conversionHashes,
    bytes32[] memory nullifiers,
    IConversionVerifier.ProofData[] memory proofs
) external returns (bool[] memory)
```
Batch submit multiple conversions for gas efficiency.

## Billing Module

### processConversion
```solidity
function processConversion(
    uint256 campaignId,
    bytes32 nullifier,
    uint256 weight
) external returns (bool)
```
Processes billing for a verified conversion.

### calculateFee
```solidity
function calculateFee(
    uint256 campaignId,
    uint256 weight
) external view returns (uint256)
```
Calculates conversion fee based on pricing model.

### getRemainingBudget
```solidity
function getRemainingBudget(uint256 campaignId) external view returns (uint256)
```
Gets remaining budget for a campaign.

## Treasury Vault

### deposit
```solidity
function deposit(uint256 campaignId) external payable
```
Deposits funds for a campaign.

### processPayment
```solidity
function processPayment(
    uint256 campaignId,
    address recipient,
    uint256 amount
) external returns (bool)
```
Processes a payment from campaign balance (authorized only).

### getCampaignBalance
```solidity
function getCampaignBalance(uint256 campaignId) external view returns (uint256)
```
Gets current balance for a campaign.

## Analytics Aggregator

### recordConversion
```solidity
function recordConversion(
    uint256 campaignId,
    uint256 amount
) external
```
Records a conversion for analytics (owner only).

### getMetrics
```solidity
function getMetrics(uint256 campaignId) external view returns (CampaignMetrics memory)
```
Retrieves campaign metrics.

**Returns:**
```solidity
struct CampaignMetrics {
    uint256 totalConversions;
    uint256 totalSpent;
    uint256 lastConversionTime;
    bool dpEnabled;
}
```

### getConversionRate
```solidity
function getConversionRate(uint256 campaignId) external view returns (uint256)
```
Calculates conversion rate (conversions per unit spent).

### getAverageCost
```solidity
function getAverageCost(uint256 campaignId) external view returns (uint256)
```
Calculates average cost per conversion.

## Fraud Detector

### checkFraud
```solidity
function checkFraud(
    address user,
    bytes32 deviceId
) external view returns (bool)
```
Checks if a user/device is likely fraudulent.

### recordConversion
```solidity
function recordConversion(
    address user,
    bytes32 deviceId,
    bool success
) external
```
Records conversion and updates reputation.

### getUserReputation
```solidity
function getUserReputation(address user) external view returns (UserReputation memory)
```
Gets user reputation details.

### blacklistUser
```solidity
function blacklistUser(address user) external
```
Blacklists a user (owner only).

## Events

### CampaignCreated
```solidity
event CampaignCreated(
    uint256 indexed campaignId,
    address indexed owner,
    uint256 budget,
    uint8 pricingModel
)
```

### ConversionSubmitted
```solidity
event ConversionSubmitted(
    uint256 indexed campaignId,
    bytes32 indexed nullifier,
    address indexed submitter,
    uint256 timestamp
)
```

### ConversionPaid
```solidity
event ConversionPaid(
    uint256 indexed campaignId,
    bytes32 indexed nullifier,
    uint256 amount,
    address recipient
)
```

### MetricsUpdated
```solidity
event MetricsUpdated(
    uint256 indexed campaignId,
    uint256 conversions,
    uint256 spent
)
```

## Error Codes

- `"Budget must be greater than 0"`: Campaign budget is invalid
- `"Invalid pricing model"`: Pricing model not in range 0-2
- `"Campaign not active"`: Campaign is closed or doesn't exist
- `"Nullifier already used"`: Conversion replay attempt detected
- `"Proof verification failed"`: ZK proof is invalid
- `"Insufficient budget"`: Campaign has insufficient funds
- `"Not authorized"`: Caller lacks required permissions

