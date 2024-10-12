const hre = require("hardhat");

async function main() {
  console.log("Deploying GhostBeacon contracts...");

  // Deploy CampaignRegistry
  const CampaignRegistry = await hre.ethers.getContractFactory("CampaignRegistry");
  const campaignRegistry = await CampaignRegistry.deploy();
  await campaignRegistry.waitForDeployment();
  console.log("CampaignRegistry deployed to:", await campaignRegistry.getAddress());

  // Deploy ConversionVerifier
  const ConversionVerifier = await hre.ethers.getContractFactory("ConversionVerifier");
  const conversionVerifier = await ConversionVerifier.deploy();
  await conversionVerifier.waitForDeployment();
  console.log("ConversionVerifier deployed to:", await conversionVerifier.getAddress());

  // Deploy TreasuryVault
  const TreasuryVault = await hre.ethers.getContractFactory("TreasuryVault");
  const treasuryVault = await TreasuryVault.deploy();
  await treasuryVault.waitForDeployment();
  console.log("TreasuryVault deployed to:", await treasuryVault.getAddress());

  // Deploy BillingModule
  const BillingModule = await hre.ethers.getContractFactory("BillingModule");
  const billingModule = await BillingModule.deploy(
    await campaignRegistry.getAddress(),
    await treasuryVault.getAddress()
  );
  await billingModule.waitForDeployment();
  console.log("BillingModule deployed to:", await billingModule.getAddress());

  // Deploy AnalyticsAggregator
  const AnalyticsAggregator = await hre.ethers.getContractFactory("AnalyticsAggregator");
  const analyticsAggregator = await AnalyticsAggregator.deploy();
  await analyticsAggregator.waitForDeployment();
  console.log("AnalyticsAggregator deployed to:", await analyticsAggregator.getAddress());

  // Deploy AttributionGateway
  const AttributionGateway = await hre.ethers.getContractFactory("AttributionGateway");
  const attributionGateway = await AttributionGateway.deploy(
    await conversionVerifier.getAddress(),
    await campaignRegistry.getAddress()
  );
  await attributionGateway.waitForDeployment();
  console.log("AttributionGateway deployed to:", await attributionGateway.getAddress());

  // Deploy FraudDetector
  const FraudDetector = await hre.ethers.getContractFactory("FraudDetector");
  const fraudDetector = await FraudDetector.deploy();
  await fraudDetector.waitForDeployment();
  console.log("FraudDetector deployed to:", await fraudDetector.getAddress());

  // Configure connections
  console.log("\nConfiguring contract connections...");
  
  await attributionGateway.setBillingModule(await billingModule.getAddress());
  console.log("Billing module configured in AttributionGateway");
  
  await attributionGateway.setAnalyticsAggregator(await analyticsAggregator.getAddress());
  console.log("Analytics aggregator configured in AttributionGateway");
  
  await treasuryVault.authorizeSpender(await billingModule.getAddress());
  console.log("Billing module authorized as spender in TreasuryVault");

  console.log("\n✅ Deployment complete!");
  
  // Save deployment addresses
  const deploymentInfo = {
    network: hre.network.name,
    campaignRegistry: await campaignRegistry.getAddress(),
    conversionVerifier: await conversionVerifier.getAddress(),
    treasuryVault: await treasuryVault.getAddress(),
    billingModule: await billingModule.getAddress(),
    analyticsAggregator: await analyticsAggregator.getAddress(),
    attributionGateway: await attributionGateway.getAddress(),
    fraudDetector: await fraudDetector.getAddress()
  };

  console.log("\nDeployment Info:");
  console.log(JSON.stringify(deploymentInfo, null, 2));
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });

