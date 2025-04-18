const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Library Tests", function () {
  describe("CampaignLib", function () {
    it("should validate pricing models correctly", async function () {
      // Testing via a contract that uses the library
      const CampaignRegistry = await ethers.getContractFactory("CampaignRegistry");
      const registry = await CampaignRegistry.deploy();
      await registry.waitForDeployment();

      // Valid pricing models: 0, 1, 2
      await expect(
        registry.createCampaign(ethers.parseEther("1"), 0, "QmTest")
      ).to.not.be.reverted;

      await expect(
        registry.createCampaign(ethers.parseEther("1"), 1, "QmTest")
      ).to.not.be.reverted;

      await expect(
        registry.createCampaign(ethers.parseEther("1"), 2, "QmTest")
      ).to.not.be.reverted;

      // Invalid pricing model
      await expect(
        registry.createCampaign(ethers.parseEther("1"), 5, "QmTest")
      ).to.be.revertedWith("Invalid pricing model");
    });
  });

  describe("ProofVerification", function () {
    let verifier;

    beforeEach(async function () {
      const ConversionVerifier = await ethers.getContractFactory("ConversionVerifier");
      verifier = await ConversionVerifier.deploy();
      await verifier.waitForDeployment();
    });

    it("should reject zero proof components", async function () {
      const clickHash = ethers.keccak256(ethers.toUtf8Bytes("click"));
      const conversionHash = ethers.keccak256(ethers.toUtf8Bytes("conversion"));
      const nullifier = ethers.keccak256(ethers.toUtf8Bytes("nullifier"));

      const invalidProof = {
        a: [0, 0],
        b: [[0, 0], [0, 0]],
        c: [0, 0],
        publicInputs: [1, 2, 3]
      };

      const result = await verifier.verifyConversionProof(
        1,
        clickHash,
        conversionHash,
        nullifier,
        invalidProof
      );

      expect(result).to.be.false;
    });
  });
});

