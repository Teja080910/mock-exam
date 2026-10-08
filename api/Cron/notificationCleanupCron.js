const cron = require("node-cron");
const fs = require("fs");
const path = require("path");
const CommonNotification = require("../models/commonNotificationModel");

const RETENTION_DAYS = 30;

// Deletes admin notifications older than 30 days (and their image files).
async function cleanupOldNotifications() {
  try {
    const cutoff = new Date(Date.now() - RETENTION_DAYS * 24 * 60 * 60 * 1000);
    const oldOnes = await CommonNotification.find({ createdAt: { $lt: cutoff } });

    if (oldOnes.length === 0) {
      console.log(`🧹 Notification cleanup: nothing older than ${RETENTION_DAYS} days`);
      return 0;
    }

    const imageDir = path.join(__dirname, "../public/assets/userImages");
    for (const n of oldOnes) {
      if (n.image) {
        try {
          const imgPath = path.join(imageDir, n.image);
          if (fs.existsSync(imgPath)) fs.unlinkSync(imgPath);
        } catch (e) {
          console.log("Notification image cleanup failed:", e.message);
        }
      }
    }

    const res = await CommonNotification.deleteMany({ _id: { $in: oldOnes.map((n) => n._id) } });
    console.log(`🧹 Notification cleanup: deleted ${res.deletedCount} notifications older than ${RETENTION_DAYS} days`);
    return res.deletedCount;
  } catch (error) {
    console.error("❌ Notification cleanup error:", error);
    return 0;
  }
}

// Run daily at 02:00 server time
cron.schedule("0 2 * * *", cleanupOldNotifications);

module.exports = { cleanupOldNotifications, RETENTION_DAYS };
