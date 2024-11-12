const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("FraudDetector", function () {
  let fraudDetector;
  let owner;
  let user1;
  let user2;

  beforeEach(async function () {
    [owner, user1, user2] = await ethers.getSigners();
    
    const FraudDetector = await ethers.getContractFactory("FraudDetector");
    fraudDetector = await FraudDetector.deploy();
    await fraudDetector.waitForDeployment();
  });

  describe("Fraud Detection", function () {
    it("Should allow legitimate user", async function () {
      const deviceId = ethers.keccak256(ethers.toUtf8Bytes("device1"));
      
      // Record successful conversion to build reputation
      await fraudDetector.recordConversion(user1.address, deviceId, true);
      
      expect(await fraudDetector.checkFraud(user1.address, deviceId)).to.be.true;
    });

    it("Should detect blacklisted user", async function () {
      const deviceId = ethers.keccak256(ethers.toUtf8Bytes("device1"));
      
      await fraudDetector.blacklistUser(user1.address);
      
      expect(await fraudDetector.checkFraud(user1.address, deviceId)).to.be.false;
    });

    it("Should detect low reputation user", async function () {
      const deviceId = ethers.keccak256(ethers.toUtf8Bytes("device1"));
      
      // Set low reputation score
      await fraudDetector.setUserScore(user1.address, 10);
      
      expect(await fraudDetector.checkFraud(user1.address, deviceId)).to.be.false;
    });
  });

  describe("Reputation Management", function () {
    it("Should initialize user with default reputation", async function () {
      const deviceId = ethers.keccak256(ethers.toUtf8Bytes("device1"));
      
      await fraudDetector.recordConversion(user1.address, deviceId, true);
      
      const reputation = await fraudDetector.getUserReputation(user1.address);
      expect(reputation.score).to.equal(51); // INITIAL_REPUTATION + 1
    });

    it("Should increase reputation on successful conversion", async function () {
      const deviceId = ethers.keccak256(ethers.toUtf8Bytes("device1"));
      
      await fraudDetector.setUserScore(user1.address, 50);
      await fraudDetector.recordConversion(user1.address, deviceId, true);
      
      const reputation = await fraudDetector.getUserReputation(user1.address);
      expect(reputation.score).to.equal(51);
    });

    it("Should decrease reputation on failed conversion", async function () {
      const deviceId = ethers.keccak256(ethers.toUtf8Bytes("device1"));
      
      await fraudDetector.setUserScore(user1.address, 50);
      await fraudDetector.recordConversion(user1.address, deviceId, false);
      
      const reputation = await fraudDetector.getUserReputation(user1.address);
      expect(reputation.score).to.equal(49);
    });

    it("Should emit event on reputation update", async function () {
      const deviceId = ethers.keccak256(ethers.toUtf8Bytes("device1"));
      
      await expect(
        fraudDetector.setUserScore(user1.address, 75)
      ).to.emit(fraudDetector, "UserScoreUpdated").withArgs(user1.address, 75);
    });
  });

  describe("Blacklist Management", function () {
    it("Should blacklist user", async function () {
      await expect(
        fraudDetector.blacklistUser(user1.address)
      ).to.emit(fraudDetector, "UserBlacklisted");
      
      expect(await fraudDetector.isBlacklisted(user1.address)).to.be.true;
    });

    it("Should whitelist user", async function () {
      await fraudDetector.blacklistUser(user1.address);
      await fraudDetector.whitelistUser(user1.address);
      
      expect(await fraudDetector.isBlacklisted(user1.address)).to.be.false;
    });

    it("Should only allow owner to blacklist", async function () {
      await expect(
        fraudDetector.connect(user1).blacklistUser(user2.address)
      ).to.be.reverted;
    });
  });

  describe("Device Scoring", function () {
    it("Should track device scores", async function () {
      const deviceId = ethers.keccak256(ethers.toUtf8Bytes("device1"));
      
      await fraudDetector.setDeviceScore(deviceId, 80);
      expect(await fraudDetector.getDeviceScore(deviceId)).to.equal(80);
    });

    it("Should reject score above maximum", async function () {
      const deviceId = ethers.keccak256(ethers.toUtf8Bytes("device1"));
      
      await expect(
        fraudDetector.setDeviceScore(deviceId, 101)
      ).to.be.revertedWith("Score too high");
    });
  });

  describe("Batch Operations", function () {
    it("Should get batch reputations", async function () {
      const deviceId = ethers.keccak256(ethers.toUtf8Bytes("device1"));
      
      await fraudDetector.setUserScore(user1.address, 70);
      await fraudDetector.setUserScore(user2.address, 80);
      
      const reputations = await fraudDetector.getBatchReputations([
        user1.address,
        user2.address
      ]);
      
      expect(reputations[0].score).to.equal(70);
      expect(reputations[1].score).to.equal(80);
    });
  });

  describe("Rate Limiting", function () {
    it("Should track conversion timestamps", async function () {
      const deviceId = ethers.keccak256(ethers.toUtf8Bytes("device1"));
      
      await fraudDetector.recordConversion(user1.address, deviceId, true);
      
      const reputation = await fraudDetector.getUserReputation(user1.address);
      expect(reputation.lastConversionTime).to.be.gt(0);
    });

    it("Should track conversion count", async function () {
      const deviceId = ethers.keccak256(ethers.toUtf8Bytes("device1"));
      
      await fraudDetector.recordConversion(user1.address, deviceId, true);
      await fraudDetector.recordConversion(user1.address, deviceId, true);
      
      const reputation = await fraudDetector.getUserReputation(user1.address);
      expect(reputation.conversions).to.equal(2);
    });
  });
});

