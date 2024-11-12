const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("AttributionGateway", function () {
  let attributionGateway;
  let conversionVerifier;
  let campaignRegistry;
  let billingModule;
  let treasuryVault;
  let analyticsAggregator;
  let owner;
  let user;

  beforeEach(async function () {
    [owner, user] = await ethers.getSigners();
    
    // Deploy ConversionVerifier
    const ConversionVerifier = await ethers.getContractFactory("ConversionVerifier");
    conversionVerifier = await ConversionVerifier.deploy();
    await conversionVerifier.waitForDeployment();

    // Deploy CampaignRegistry
    const CampaignRegistry = await ethers.getContractFactory("CampaignRegistry");
    campaignRegistry = await CampaignRegistry.deploy();
    await campaignRegistry.waitForDeployment();

    // Deploy TreasuryVault
    const TreasuryVault = await ethers.getContractFactory("TreasuryVault");
    treasuryVault = await TreasuryVault.deploy();
    await treasuryVault.waitForDeployment();

    // Deploy BillingModule
    const BillingModule = await ethers.getContractFactory("BillingModule");
    billingModule = await BillingModule.deploy(
      await campaignRegistry.getAddress(),
      await treasuryVault.getAddress()
    );
    await billingModule.waitForDeployment();

    // Deploy AnalyticsAggregator
    const AnalyticsAggregator = await ethers.getContractFactory("AnalyticsAggregator");
    analyticsAggregator = await AnalyticsAggregator.deploy();
    await analyticsAggregator.waitForDeployment();

    // Deploy AttributionGateway
    const AttributionGateway = await ethers.getContractFactory("AttributionGateway");
    attributionGateway = await AttributionGateway.deploy(
      await conversionVerifier.getAddress(),
      await campaignRegistry.getAddress()
    );
    await attributionGateway.waitForDeployment();

    // Configure
    await attributionGateway.setBillingModule(await billingModule.getAddress());
    await attributionGateway.setAnalyticsAggregator(await analyticsAggregator.getAddress());
    await treasuryVault.authorizeSpender(await billingModule.getAddress());
  });

  describe("Configuration", function () {
    it("Should set billing module", async function () {
      expect(await attributionGateway.billingModule()).to.equal(
        await billingModule.getAddress()
      );
    });

    it("Should set analytics aggregator", async function () {
      expect(await attributionGateway.analyticsAggregator()).to.equal(
        await analyticsAggregator.getAddress()
      );
    });

    it("Should reject zero address for billing module", async function () {
      await expect(
        attributionGateway.setBillingModule(ethers.ZeroAddress)
      ).to.be.revertedWith("Invalid address");
    });
  });

  describe("Conversion Submission", function () {
    let campaignId;

    beforeEach(async function () {
      // Create campaign
      const tx = await campaignRegistry.createCampaign(
        ethers.parseEther("10.0"),
        0,
        "QmTest"
      );
      await tx.wait();
      campaignId = 1;

      // Fund campaign
      await treasuryVault.deposit(campaignId, { value: ethers.parseEther("10.0") });

      // Setup verifier
      const root = ethers.keccak256(ethers.toUtf8Bytes("root"));
      await conversionVerifier.updateCampaignRoot(campaignId, root);
    });

    it("Should reject conversion for inactive campaign", async function () {
      await campaignRegistry.closeCampaign(campaignId);

      const clickHash = ethers.keccak256(ethers.toUtf8Bytes("click"));
      const conversionHash = ethers.keccak256(ethers.toUtf8Bytes("conversion"));
      const nullifier = ethers.keccak256(ethers.toUtf8Bytes("nullifier"));
      const root = await conversionVerifier.getCampaignRoot(campaignId);

      const proof = {
        a: [1, 2],
        b: [[3, 4], [5, 6]],
        c: [7, 8],
        publicInputs: [BigInt(clickHash), BigInt(conversionHash), BigInt(root)]
      };

      const result = await attributionGateway.submitConversion(
        campaignId,
        clickHash,
        conversionHash,
        nullifier,
        proof
      );

      expect(result).to.be.false;
    });

    it("Should track conversion count", async function () {
      const initialCount = await attributionGateway.getCampaignConversionCount(campaignId);
      expect(initialCount).to.equal(0);
    });

    it("Should detect processed nullifier", async function () {
      const nullifier = ethers.keccak256(ethers.toUtf8Bytes("test-nullifier"));
      expect(await attributionGateway.isNullifierProcessed(nullifier)).to.be.false;
    });
  });

  describe("Batch Operations", function () {
    it("Should reject batch with mismatched arrays", async function () {
      await expect(
        attributionGateway.batchSubmitConversions([1], [], [], [], [])
      ).to.be.revertedWith("Length mismatch");
    });
  });
});

