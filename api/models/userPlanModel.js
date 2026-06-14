const mongoose = require("mongoose");
const UserPlanSchema = new mongoose.Schema(
  {
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      unique: true,
      required: true,
    },
    categoryGroupIds: [
      {
        type: mongoose.Schema.Types.ObjectId,
        ref: "CategoryGroup",
      },
    ],
    planId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Plan",
    },
    price: {
      type: Number,
      default: 0,
    },
    isSelectedAll: {
      type: Boolean,
      default: false,
    },
    planStatus: {
      type: String,
      enum: ["active", "pending", "expired"],
      default: "pending",
    },
    expiresAt: {
      type: Date,
      index: true,
    },
  },

  { timestamps: true },
);

module.exports = mongoose.model("UserPlan", UserPlanSchema);
