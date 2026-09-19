const cron = require("node-cron");
const UserPlan = require("../models/userPlanModel");

// 🔁 TESTING: Every 5 seconds
// cron.schedule("*/5 * * * * *", async () => {
cron.schedule("0 0 * * *", async () => {
  try {
    console.log("🔄 Expire Plan Cron Started");

    const now = new Date();

    // Expire individual subscriptions that have passed expiresAt
    await UserPlan.updateMany(
      {
        "subscriptions.planStatus": "active",
        "subscriptions.expiresAt": { $ne: null, $lte: now },
      },
      {
        $set: { "subscriptions.$[elem].planStatus": "expired" },
      },
      {
        arrayFilters: [{ "elem.planStatus": "active", "elem.expiresAt": { $ne: null, $lte: now } }],
      }
    );

    // Update overall planStatus
    const activePlans = await UserPlan.find({ planStatus: "active" });
    let expiredCount = 0;
    for (const up of activePlans) {
      const hasActiveSub = up.subscriptions && up.subscriptions.some(
        (s) => s.planStatus === "active" && (!s.expiresAt || new Date(s.expiresAt) > now)
      );
      if (!hasActiveSub && (up.expiresAt ? new Date(up.expiresAt) <= now : true)) {
        up.planStatus = "expired";
        await up.save();
        expiredCount++;
      }
    }

    console.log(`✅ Plans expired: ${expiredCount}`);
  } catch (error) {
    console.error("❌ Expire Plan Cron Error:", error);
  }
});
