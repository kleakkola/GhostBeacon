const hre = require("hardhat");

/**
 * Example script to interact with deployed contracts
 */
async function main() {
  const [deployer] = await hre.ethers.getSigners();
  console.log("Interacting with contracts using account:", deployer.address);

  // Replace with your deployed contract addresses
  const CAMPAIGN_REGISTRY_ADDRESS = "0x...";
  const ATTRIBUTION_GATEWAY_ADDRESS = "0x...";
  const TREASURY_VAULT_ADDRESS = "0x...";

  // Get contract instances
  const CampaignRegistry = await hre.ethers.getContractFactory("CampaignRegistry");
  const campaignRegistry = CampaignRegistry.attach(CAMPAIGN_REGISTRY_ADDRESS);

  const AttributionGateway = await hre.ethers.getContractFactory("AttributionGateway");
  const attributionGateway = AttributionGateway.attach(ATTRIBUTION_GATEWAY_ADDRESS);

  const TreasuryVault = await hre.ethers.getContractFactory("TreasuryVault");
  const treasuryVault = TreasuryVault.attach(TREASURY_VAULT_ADDRESS);

  console.log("\n=== Campaign Management ===");

  // Create a campaign
  console.log("\nCreating campaign...");
  const budget = hre.ethers.parseEther("1.0");
  const pricingModel = 0; // CPA
  const metadataCID = "QmExampleCID123";

  const tx = await campaignRegistry.createCampaign(budget, pricingModel, metadataCID);
  await tx.wait();
  console.log("Campaign created!");

  // Get total campaigns
  const totalCampaigns = await campaignRegistry.getTotalCampaigns();
  console.log("Total campaigns:", totalCampaigns.toString());

  // Get campaign details
  if (totalCampaigns > 0n) {
    const campaign = await campaignRegistry.getCampaign(1);
    console.log("\nCampaign 1 Details:");
    console.log("- Owner:", campaign.owner);
    console.log("- Budget:", hre.ethers.formatEther(campaign.budget), "ETH");
    console.log("- Spent:", hre.ethers.formatEther(campaign.spent), "ETH");
    console.log("- Pricing Model:", campaign.pricingModel);
    console.log("- Active:", campaign.active);
  }

  console.log("\n=== Treasury Management ===");

  // Deposit funds to campaign
  const campaignId = 1;
  const depositAmount = hre.ethers.parseEther("1.0");

  console.log("\nDepositing funds to campaign...");
  const depositTx = await treasuryVault.deposit(campaignId, { value: depositAmount });
  await depositTx.wait();
  console.log("Deposited", hre.ethers.formatEther(depositAmount), "ETH");

  // Check campaign balance
  const campaignBalance = await treasuryVault.getCampaignBalance(campaignId);
  console.log("Campaign balance:", hre.ethers.formatEther(campaignBalance), "ETH");

  // Check total vault balance
  const totalBalance = await treasuryVault.getTotalBalance();
  console.log("Total vault balance:", hre.ethers.formatEther(totalBalance), "ETH");

  console.log("\n=== Attribution Gateway ===");

  // Get conversion count
  const conversionCount = await attributionGateway.getCampaignConversionCount(campaignId);
  console.log("\nCampaign conversions:", conversionCount.toString());

  console.log("\n✅ Interaction complete!");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });

