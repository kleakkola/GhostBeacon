const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("BillingModule", function () {
  let billingModule;
  let campaignRegistry;
  let treasuryVault;
  let owner;
  let publisher;

  beforeEach(async function () {
    [owner, publisher] = await ethers.getSigners();
    
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

    // Authorize billing module
    await treasuryVault.authorizeSpender(await billingModule.getAddress());
  });

  describe("Initialization", function () {
    it("Should set campaign registry", async function () {
      expect(await billingModule.campaignRegistry()).to.equal(
        await campaignRegistry.getAddress()
      );
    });

    it("Should set treasury vault", async function () {
      expect(await billingModule.treasuryVault()).to.equal(
        await treasuryVault.getAddress()
      );
    });
  });

  describe("Fee Calculation", function () {
    let campaignId;

    beforeEach(async function () {
      await campaignRegistry.createCampaign(
        ethers.parseEther("1.0"),
        0, // CPA
        "QmTest"
      );
      campaignId = 1;
    });

    it("Should calculate fee for CPA model", async function () {
      const weight = 2;
      const fee = await billingModule.calculateFee(campaignId, weight);
      expect(fee).to.equal(ethers.parseEther("0.002")); // BASE_COST * weight
    });

    it("Should handle weight of 1", async function () {
      const fee = await billingModule.calculateFee(campaignId, 1);
      expect(fee).to.equal(ethers.parseEther("0.001"));
    });
  });

  describe("Publisher Management", function () {
    it("Should set publisher for campaign", async function () {
      await billingModule.setPublisher(1, publisher.address);
      expect(await billingModule.getPublisher(1)).to.equal(publisher.address);
    });

    it("Should reject zero address publisher", async function () {
      await expect(
        billingModule.setPublisher(1, ethers.ZeroAddress)
      ).to.be.revertedWith("Invalid publisher");
    });

    it("Should only allow owner to set publisher", async function () {
      await expect(
        billingModule.connect(publisher).setPublisher(1, publisher.address)
      ).to.be.reverted;
    });
  });

  describe("Batch Cost Estimation", function () {
    let campaignId;

    beforeEach(async function () {
      await campaignRegistry.createCampaign(
        ethers.parseEther("10.0"),
        0,
        "QmTest"
      );
      campaignId = 1;
    });

    it("Should estimate batch cost", async function () {
      const weights = [1, 2, 3];
      const totalCost = await billingModule.estimateBatchCost(campaignId, weights);
      
      // (1 + 2 + 3) * BASE_COST = 6 * 0.001 = 0.006
      expect(totalCost).to.equal(ethers.parseEther("0.006"));
    });

    it("Should handle empty array", async function () {
      const totalCost = await billingModule.estimateBatchCost(campaignId, []);
      expect(totalCost).to.equal(0);
    });
  });

  describe("Budget Validation", function () {
    let campaignId;

    beforeEach(async function () {
      await campaignRegistry.createCampaign(
        ethers.parseEther("0.005"),
        0,
        "QmTest"
      );
      campaignId = 1;
    });

    it("Should get remaining budget", async function () {
      const remaining = await billingModule.getRemainingBudget(campaignId);
      expect(remaining).to.equal(ethers.parseEther("0.005"));
    });
  });
});

