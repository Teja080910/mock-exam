const randomstring = require("randomstring");
const User = require("../models/userModel");

/**
 * Generates a unique 8-character uppercase alphanumeric referral code.
 */
async function generateUniqueReferralCode() {
  let referralCode = "";
  let isUnique = false;
  let attempts = 0;
  const maxAttempts = 50;

  while (!isUnique && attempts < maxAttempts) {
    attempts++;
    referralCode = randomstring.generate({
      length: 8,
      charset: "alphanumeric",
      capitalization: "uppercase",
    });
    const existing = await User.findOne({ referral_code: referralCode });
    if (!existing) {
      isUnique = true;
    }
  }

  if (!isUnique) {
    // Fallback in case of collision
    referralCode = "REF" + Date.now().toString().slice(-5);
  }

  return referralCode;
}

/**
 * Ensures that a user document has a valid referral code.
 * If missing, generates one, persists it to DB, and returns it.
 */
async function ensureReferralCode(user) {
  if (!user) return "";

  if (user.referral_code && typeof user.referral_code === "string" && user.referral_code.trim()) {
    return user.referral_code.trim().toUpperCase();
  }

  const code = await generateUniqueReferralCode();
  user.referral_code = code;
  try {
    await user.save();
    console.log(`[ReferralHelper] Generated and saved referral code ${code} for user ${user._id}`);
  } catch (err) {
    console.error(`[ReferralHelper] Error saving referral code for user ${user._id}:`, err);
  }
  return code;
}

/**
 * Scans MongoDB for any users without a referral code and assigns them one.
 */
async function backfillReferralCodes() {
  try {
    const usersWithoutCode = await User.find({
      $or: [
        { referral_code: { $exists: false } },
        { referral_code: null },
        { referral_code: "" },
      ],
    });

    if (!usersWithoutCode || usersWithoutCode.length === 0) {
      return 0;
    }

    console.log(`[ReferralHelper] Found ${usersWithoutCode.length} users without referral codes. Backfilling...`);
    let count = 0;

    for (const user of usersWithoutCode) {
      const code = await generateUniqueReferralCode();
      user.referral_code = code;
      await user.save();
      count++;
    }

    console.log(`[ReferralHelper] Successfully backfilled ${count} users with referral codes.`);
    return count;
  } catch (err) {
    console.error("[ReferralHelper] Error during referral code backfill:", err);
    return 0;
  }
}

module.exports = {
  generateUniqueReferralCode,
  ensureReferralCode,
  backfillReferralCodes,
};
