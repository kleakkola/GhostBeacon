const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("TreasuryVault", function () {
  let treasuryVault;
  let owner;
  let spender;
  let recipient;

  beforeEach(async function () {
    [owner, spender, recipient] = await ethers.getSigners();
    
    const TreasuryVault = await ethers.getContractFactory("TreasuryVault");
    treasuryVault = await TreasuryVault.deploy();
    await treasuryVault.waitForDeployment();
  });

  describe("Deposits", function () {
    it("Should accept deposits for campaigns", async function () {
      const campaignId = 1;
      const amount = ethers.parseEther("1.0");

      await expect(
        treasuryVault.deposit(campaignId, { value: amount })
      ).to.emit(treasuryVault, "Deposited").withArgs(campaignId, owner.address, amount);

      expect(await treasuryVault.getCampaignBalance(campaignId)).to.equal(amount);
    });

    it("Should reject zero deposits", async function () {
      await expect(
        treasuryVault.deposit(1, { value: 0 })
      ).to.be.revertedWith("Deposit amount must be > 0");
    });

    it("Should accept ETH through receive function", async function () {
      const amount = ethers.parseEther("0.5");
      
      await expect(
        owner.sendTransaction({
          to: await treasuryVault.getAddress(),
          value: amount
        })
      ).to.emit(treasuryVault, "Deposited");
    });
  });

  describe("Authorization", function () {
    it("Should authorize spender", async function () {
      await treasuryVault.authorizeSpender(spender.address);
      expect(await treasuryVault.isAuthorizedSpender(spender.address)).to.be.true;
    });

    it("Should revoke spender authorization", async function () {
      await treasuryVault.authorizeSpender(spender.address);
      await treasuryVault.revokeSpender(spender.address);
      expect(await treasuryVault.isAuthorizedSpender(spender.address)).to.be.false;
    });

    it("Should only allow owner to authorize", async function () {
      await expect(
        treasuryVault.connect(spender).authorizeSpender(spender.address)
      ).to.be.reverted;
    });
  });

  describe("Payments", function () {
    beforeEach(async function () {
      const campaignId = 1;
      const amount = ethers.parseEther("2.0");
      await treasuryVault.deposit(campaignId, { value: amount });
      await treasuryVault.authorizeSpender(spender.address);
    });

    it("Should process payment from authorized spender", async function () {
      const campaignId = 1;
      const paymentAmount = ethers.parseEther("0.5");

      await expect(
        treasuryVault.connect(spender).processPayment(campaignId, recipient.address, paymentAmount)
      ).to.emit(treasuryVault, "PaymentProcessed");

      const remainingBalance = await treasuryVault.getCampaignBalance(campaignId);
      expect(remainingBalance).to.equal(ethers.parseEther("1.5"));
    });

    it("Should reject payment from unauthorized address", async function () {
      const campaignId = 1;
      const paymentAmount = ethers.parseEther("0.5");

      await expect(
        treasuryVault.connect(recipient).processPayment(campaignId, recipient.address, paymentAmount)
      ).to.be.revertedWith("Not authorized");
    });

    it("Should reject payment exceeding campaign balance", async function () {
      const campaignId = 1;
      const paymentAmount = ethers.parseEther("5.0");

      await expect(
        treasuryVault.connect(spender).processPayment(campaignId, recipient.address, paymentAmount)
      ).to.be.revertedWith("Insufficient campaign balance");
    });
  });

  describe("Withdrawals", function () {
    beforeEach(async function () {
      await treasuryVault.deposit(1, { value: ethers.parseEther("1.0") });
    });

    it("Should allow owner to withdraw", async function () {
      const amount = ethers.parseEther("0.5");
      
      await expect(
        treasuryVault.withdraw(recipient.address, amount)
      ).to.emit(treasuryVault, "Withdrawn");
    });

    it("Should reject withdrawal from non-owner", async function () {
      await expect(
        treasuryVault.connect(spender).withdraw(recipient.address, ethers.parseEther("0.5"))
      ).to.be.reverted;
    });
  });

  describe("Timelock", function () {
    it("Should initialize timelock", async function () {
      const transferId = ethers.keccak256(ethers.toUtf8Bytes("transfer1"));
      await treasuryVault.initializeTimelock(transferId);
      
      expect(await treasuryVault.isTimelockExpired(transferId)).to.be.false;
    });
  });
});

