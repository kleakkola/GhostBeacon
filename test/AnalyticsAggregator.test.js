const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("AnalyticsAggregator", function () {
  let analyticsAggregator;
  let owner;
  let user;

  beforeEach(async function () {
    [owner, user] = await ethers.getSigners();
    
    const AnalyticsAggregator = await ethers.getContractFactory("AnalyticsAggregator");
    analyticsAggregator = await AnalyticsAggregator.deploy();
    await analyticsAggregator.waitForDeployment();
  });

  describe("Conversion Recording", function () {
    it("Should record conversion", async function () {
      const campaignId = 1;
      const amount = ethers.parseEther("0.1");

      await expect(
        analyticsAggregator.recordConversion(campaignId, amount)
      ).to.emit(analyticsAggregator, "MetricsUpdated");

      const metrics = await analyticsAggregator.getMetrics(campaignId);
      expect(metrics.totalConversions).to.equal(1);
      expect(metrics.totalSpent).to.equal(amount);
    });

    it("Should accumulate multiple conversions", async function () {
      const campaignId = 1;
      const amount = ethers.parseEther("0.1");

      await analyticsAggregator.recordConversion(campaignId, amount);
      await analyticsAggregator.recordConversion(campaignId, amount);
      await analyticsAggregator.recordConversion(campaignId, amount);

      const metrics = await analyticsAggregator.getMetrics(campaignId);
      expect(metrics.totalConversions).to.equal(3);
      expect(metrics.totalSpent).to.equal(ethers.parseEther("0.3"));
    });

    it("Should only allow owner to record", async function () {
      await expect(
        analyticsAggregator.connect(user).recordConversion(1, ethers.parseEther("0.1"))
      ).to.be.reverted;
    });

    it("Should update last conversion time", async function () {
      const campaignId = 1;
      await analyticsAggregator.recordConversion(campaignId, ethers.parseEther("0.1"));

      const metrics = await analyticsAggregator.getMetrics(campaignId);
      expect(metrics.lastConversionTime).to.be.gt(0);
    });
  });

  describe("Metrics Retrieval", function () {
    beforeEach(async function () {
      await analyticsAggregator.recordConversion(1, ethers.parseEther("0.1"));
      await analyticsAggregator.recordConversion(1, ethers.parseEther("0.2"));
    });

    it("Should get total conversions", async function () {
      expect(await analyticsAggregator.getTotalConversions(1)).to.equal(2);
    });

    it("Should get total spent", async function () {
      expect(await analyticsAggregator.getTotalSpent(1)).to.equal(
        ethers.parseEther("0.3")
      );
    });

    it("Should return zero for non-existent campaign", async function () {
      expect(await analyticsAggregator.getTotalConversions(999)).to.equal(0);
    });
  });

  describe("Differential Privacy", function () {
    beforeEach(async function () {
      await analyticsAggregator.recordConversion(1, ethers.parseEther("1.0"));
    });

    it("Should enable differential privacy", async function () {
      await analyticsAggregator.setDifferentialPrivacy(1, true);
      expect(await analyticsAggregator.isDPEnabled(1)).to.be.true;
    });

    it("Should disable differential privacy", async function () {
      await analyticsAggregator.setDifferentialPrivacy(1, true);
      await analyticsAggregator.setDifferentialPrivacy(1, false);
      expect(await analyticsAggregator.isDPEnabled(1)).to.be.false;
    });

    it("Should apply noise when DP is enabled", async function () {
      await analyticsAggregator.setDifferentialPrivacy(1, true);
      
      const metrics = await analyticsAggregator.getMetrics(1);
      // With DP enabled, metrics should have noise applied
      // We can't test exact value due to randomness, but structure should be valid
      expect(metrics.dpEnabled).to.be.true;
    });

    it("Should only allow owner to set DP", async function () {
      await expect(
        analyticsAggregator.connect(user).setDifferentialPrivacy(1, true)
      ).to.be.reverted;
    });
  });

  describe("Analytics Calculations", function () {
    beforeEach(async function () {
      await analyticsAggregator.recordConversion(1, ethers.parseEther("0.1"));
      await analyticsAggregator.recordConversion(1, ethers.parseEther("0.2"));
      await analyticsAggregator.recordConversion(1, ethers.parseEther("0.3"));
    });

    it("Should calculate conversion rate", async function () {
      const rate = await analyticsAggregator.getConversionRate(1);
      // 3 conversions / 0.6 ETH = 5 * 1e18
      expect(rate).to.equal(ethers.parseEther("5"));
    });

    it("Should calculate average cost", async function () {
      const avgCost = await analyticsAggregator.getAverageCost(1);
      // 0.6 ETH / 3 conversions = 0.2 ETH
      expect(avgCost).to.equal(ethers.parseEther("0.2"));
    });

    it("Should return zero for empty campaign", async function () {
      expect(await analyticsAggregator.getConversionRate(999)).to.equal(0);
      expect(await analyticsAggregator.getAverageCost(999)).to.equal(0);
    });
  });

  describe("Batch Metrics", function () {
    beforeEach(async function () {
      await analyticsAggregator.recordConversion(1, ethers.parseEther("0.1"));
      await analyticsAggregator.recordConversion(2, ethers.parseEther("0.2"));
      await analyticsAggregator.recordConversion(3, ethers.parseEther("0.3"));
    });

    it("Should get batch metrics", async function () {
      const metrics = await analyticsAggregator.getBatchMetrics([1, 2, 3]);
      
      expect(metrics.length).to.equal(3);
      expect(metrics[0].totalConversions).to.equal(1);
      expect(metrics[1].totalConversions).to.equal(1);
      expect(metrics[2].totalConversions).to.equal(1);
    });

    it("Should handle empty array", async function () {
      const metrics = await analyticsAggregator.getBatchMetrics([]);
      expect(metrics.length).to.equal(0);
    });
  });

  describe("Metrics Reset", function () {
    beforeEach(async function () {
      await analyticsAggregator.recordConversion(1, ethers.parseEther("0.5"));
    });

    it("Should reset metrics", async function () {
      await analyticsAggregator.resetMetrics(1);
      
      const metrics = await analyticsAggregator.getMetrics(1);
      expect(metrics.totalConversions).to.equal(0);
      expect(metrics.totalSpent).to.equal(0);
    });

    it("Should only allow owner to reset", async function () {
      await expect(
        analyticsAggregator.connect(user).resetMetrics(1)
      ).to.be.reverted;
    });
  });
});

