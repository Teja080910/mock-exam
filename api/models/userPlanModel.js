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
    subscriptions: [
      {
        planId: {
          type: mongoose.Schema.Types.ObjectId,
          ref: "Plan",
        },
        planName: {
          type: String,
          default: "",
        },
        planCode: {
          type: String,
          default: "",
        },
        categoryGroupId: {
          type: mongoose.Schema.Types.ObjectId,
          ref: "CategoryGroup",
        },
        price: {
          type: Number,
          default: 0,
        },
        planStatus: {
          type: String,
          enum: ["active", "expired"],
          default: "active",
        },
        purchasedAt: {
          type: Date,
          default: Date.now,
        },
        expiresAt: {
          type: Date,
        },
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
