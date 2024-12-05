const hre = require("hardhat");

/**
 * Script to verify deployed contracts on block explorer
 */
async function main() {
  const deploymentInfo = {
    // Replace with your deployed addresses
    campaignRegistry: "0x...",
    conversionVerifier: "0x...",
    treasuryVault: "0x...",
    billingModule: "0x...",
    analyticsAggregator: "0x...",
    attributionGateway: "0x...",
    fraudDetector: "0x..."
  };

  console.log("Starting contract verification...\n");

  try {
    // Verify CampaignRegistry
    console.log("Verifying CampaignRegistry...");
    await hre.run("verify:verify", {
      address: deploymentInfo.campaignRegistry,
      constructorArguments: []
    });
    console.log("✓ CampaignRegistry verified\n");

    // Verify ConversionVerifier
    console.log("Verifying ConversionVerifier...");
    await hre.run("verify:verify", {
      address: deploymentInfo.conversionVerifier,
      constructorArguments: []
    });
    console.log("✓ ConversionVerifier verified\n");

    // Verify TreasuryVault
    console.log("Verifying TreasuryVault...");
    await hre.run("verify:verify", {
      address: deploymentInfo.treasuryVault,
      constructorArguments: []
    });
    console.log("✓ TreasuryVault verified\n");

    // Verify BillingModule
    console.log("Verifying BillingModule...");
    await hre.run("verify:verify", {
      address: deploymentInfo.billingModule,
      constructorArguments: [
        deploymentInfo.campaignRegistry,
        deploymentInfo.treasuryVault
      ]
    });
    console.log("✓ BillingModule verified\n");

    // Verify AnalyticsAggregator
    console.log("Verifying AnalyticsAggregator...");
    await hre.run("verify:verify", {
      address: deploymentInfo.analyticsAggregator,
      constructorArguments: []
    });
    console.log("✓ AnalyticsAggregator verified\n");

    // Verify AttributionGateway
    console.log("Verifying AttributionGateway...");
    await hre.run("verify:verify", {
      address: deploymentInfo.attributionGateway,
      constructorArguments: [
        deploymentInfo.conversionVerifier,
        deploymentInfo.campaignRegistry
      ]
    });
    console.log("✓ AttributionGateway verified\n");

    // Verify FraudDetector
    console.log("Verifying FraudDetector...");
    await hre.run("verify:verify", {
      address: deploymentInfo.fraudDetector,
      constructorArguments: []
    });
    console.log("✓ FraudDetector verified\n");

    console.log("✅ All contracts verified successfully!");
  } catch (error) {
    if (error.message.includes("Already Verified")) {
      console.log("Contract already verified");
    } else {
      console.error("Verification error:", error);
      process.exit(1);
    }
  }
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });

