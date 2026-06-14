const cron = require("node-cron");
const UserPlan = require("../models/userPlanModel");

// 🔁 TESTING: Every 5 seconds
// cron.schedule("*/5 * * * * *", async () => {
cron.schedule("0 0 * * *", async () => {
  try {
    console.log("🔄 Expire Plan Cron Started");

    const now = new Date();

    const result = await UserPlan.updateMany(
      {
        planStatus: "active",
        expiresAt: { $lte: now },
      },
      {
        $set: { planStatus: "expired" },
      },
    );

    console.log(`✅ Plans expired: ${result.modifiedCount}`);
  } catch (error) {
    console.error("❌ Expire Plan Cron Error:", error);
  }
});
