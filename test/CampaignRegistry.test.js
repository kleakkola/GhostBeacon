const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("CampaignRegistry", function () {
  let campaignRegistry;
  let owner;
  let advertiser;

  beforeEach(async function () {
    [owner, advertiser] = await ethers.getSigners();
    
    const CampaignRegistry = await ethers.getContractFactory("CampaignRegistry");
    campaignRegistry = await CampaignRegistry.deploy();
    await campaignRegistry.waitForDeployment();
  });

  describe("Campaign Creation", function () {
    it("Should create a campaign successfully", async function () {
      const budget = ethers.parseEther("1.0");
      const pricingModel = 0; // CPA
      const metadataCID = "QmTest123";

      await expect(
        campaignRegistry.connect(advertiser).createCampaign(budget, pricingModel, metadataCID)
      ).to.emit(campaignRegistry, "CampaignCreated");

      const campaign = await campaignRegistry.getCampaign(1);
      expect(campaign.owner).to.equal(advertiser.address);
      expect(campaign.budget).to.equal(budget);
      expect(campaign.pricingModel).to.equal(pricingModel);
    });

    it("Should reject campaign with zero budget", async function () {
      await expect(
        campaignRegistry.createCampaign(0, 0, "QmTest")
      ).to.be.revertedWith("Budget must be greater than 0");
    });

    it("Should reject campaign with invalid pricing model", async function () {
      await expect(
        campaignRegistry.createCampaign(ethers.parseEther("1.0"), 5, "QmTest")
      ).to.be.revertedWith("Invalid pricing model");
    });
  });

  describe("Campaign Management", function () {
    beforeEach(async function () {
      await campaignRegistry.connect(advertiser).createCampaign(
        ethers.parseEther("1.0"),
        0,
        "QmTest"
      );
    });

    it("Should update campaign budget", async function () {
      const newBudget = ethers.parseEther("2.0");
      
      await expect(
        campaignRegistry.connect(advertiser).updateBudget(1, newBudget)
      ).to.emit(campaignRegistry, "BudgetUpdated");

      const campaign = await campaignRegistry.getCampaign(1);
      expect(campaign.budget).to.equal(newBudget);
    });

    it("Should close campaign", async function () {
      await expect(
        campaignRegistry.connect(advertiser).closeCampaign(1)
      ).to.emit(campaignRegistry, "CampaignClosed");

      expect(await campaignRegistry.isCampaignActive(1)).to.be.false;
    });

    it("Should reject budget update from non-owner", async function () {
      await expect(
        campaignRegistry.connect(owner).updateBudget(1, ethers.parseEther("2.0"))
      ).to.be.revertedWith("Not campaign owner");
    });
  });

  describe("View Functions", function () {
    it("Should return campaigns by owner", async function () {
      await campaignRegistry.connect(advertiser).createCampaign(
        ethers.parseEther("1.0"),
        0,
        "QmTest1"
      );
      await campaignRegistry.connect(advertiser).createCampaign(
        ethers.parseEther("2.0"),
        1,
        "QmTest2"
      );

      const campaigns = await campaignRegistry.getCampaignsByOwner(advertiser.address);
      expect(campaigns.length).to.equal(2);
    });

    it("Should return total campaigns count", async function () {
      await campaignRegistry.createCampaign(ethers.parseEther("1.0"), 0, "QmTest");
      expect(await campaignRegistry.getTotalCampaigns()).to.equal(1);
    });
  });
});

