const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("ConversionVerifier", function () {
  let conversionVerifier;
  let owner;
  let user;

  beforeEach(async function () {
    [owner, user] = await ethers.getSigners();
    
    const ConversionVerifier = await ethers.getContractFactory("ConversionVerifier");
    conversionVerifier = await ConversionVerifier.deploy();
    await conversionVerifier.waitForDeployment();
  });

  describe("Proof Verification", function () {
    it("Should verify valid proof structure", async function () {
      const campaignId = 1;
      const clickHash = ethers.keccak256(ethers.toUtf8Bytes("click123"));
      const conversionHash = ethers.keccak256(ethers.toUtf8Bytes("conversion123"));
      const nullifier = ethers.keccak256(ethers.toUtf8Bytes("nullifier123"));

      // Set campaign root
      const root = ethers.keccak256(ethers.toUtf8Bytes("root123"));
      await conversionVerifier.updateCampaignRoot(campaignId, root);

      const proof = {
        a: [1, 2],
        b: [[3, 4], [5, 6]],
        c: [7, 8],
        publicInputs: [
          BigInt(clickHash),
          BigInt(conversionHash),
          BigInt(root)
        ]
      };

      const result = await conversionVerifier.verifyConversionProof(
        campaignId,
        clickHash,
        conversionHash,
        nullifier,
        proof
      );

      expect(result).to.be.true;
    });

    it("Should reject used nullifier", async function () {
      const nullifier = ethers.keccak256(ethers.toUtf8Bytes("nullifier123"));
      
      await conversionVerifier.markNullifierUsed(nullifier);
      
      expect(await conversionVerifier.isNullifierUsed(nullifier)).to.be.true;
    });

    it("Should reject invalid proof structure", async function () {
      const campaignId = 1;
      const clickHash = ethers.keccak256(ethers.toUtf8Bytes("click123"));
      const conversionHash = ethers.keccak256(ethers.toUtf8Bytes("conversion123"));
      const nullifier = ethers.keccak256(ethers.toUtf8Bytes("nullifier456"));

      const proof = {
        a: [0, 0], // Invalid: zeros
        b: [[0, 0], [0, 0]],
        c: [0, 0],
        publicInputs: [1, 2, 3]
      };

      const result = await conversionVerifier.verifyConversionProof(
        campaignId,
        clickHash,
        conversionHash,
        nullifier,
        proof
      );

      expect(result).to.be.false;
    });
  });

  describe("Campaign Root Management", function () {
    it("Should update campaign root", async function () {
      const campaignId = 1;
      const root = ethers.keccak256(ethers.toUtf8Bytes("root123"));

      await expect(
        conversionVerifier.updateCampaignRoot(campaignId, root)
      ).to.emit(conversionVerifier, "CampaignRootUpdated");

      expect(await conversionVerifier.getCampaignRoot(campaignId)).to.equal(root);
    });

    it("Should only allow owner to update root", async function () {
      const campaignId = 1;
      const root = ethers.keccak256(ethers.toUtf8Bytes("root123"));

      await expect(
        conversionVerifier.connect(user).updateCampaignRoot(campaignId, root)
      ).to.be.reverted;
    });
  });

  describe("Batch Verification", function () {
    it("Should verify batch proofs", async function () {
      const campaignIds = [1, 2];
      const clickHashes = [
        ethers.keccak256(ethers.toUtf8Bytes("click1")),
        ethers.keccak256(ethers.toUtf8Bytes("click2"))
      ];
      const conversionHashes = [
        ethers.keccak256(ethers.toUtf8Bytes("conversion1")),
        ethers.keccak256(ethers.toUtf8Bytes("conversion2"))
      ];
      const nullifiers = [
        ethers.keccak256(ethers.toUtf8Bytes("null1")),
        ethers.keccak256(ethers.toUtf8Bytes("null2"))
      ];

      const root1 = ethers.keccak256(ethers.toUtf8Bytes("root1"));
      const root2 = ethers.keccak256(ethers.toUtf8Bytes("root2"));
      
      await conversionVerifier.updateCampaignRoot(1, root1);
      await conversionVerifier.updateCampaignRoot(2, root2);

      const proofs = [
        {
          a: [1, 2],
          b: [[3, 4], [5, 6]],
          c: [7, 8],
          publicInputs: [BigInt(clickHashes[0]), BigInt(conversionHashes[0]), BigInt(root1)]
        },
        {
          a: [1, 2],
          b: [[3, 4], [5, 6]],
          c: [7, 8],
          publicInputs: [BigInt(clickHashes[1]), BigInt(conversionHashes[1]), BigInt(root2)]
        }
      ];

      const results = await conversionVerifier.batchVerifyProofs(
        campaignIds,
        clickHashes,
        conversionHashes,
        nullifiers,
        proofs
      );

      expect(results.length).to.equal(2);
    });
  });
});

