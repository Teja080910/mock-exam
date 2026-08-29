const mongoose = require('mongoose');

const categoryGroupSchema = new mongoose.Schema({
  displayName: { type: String, required: true },
  scope: { type: String, enum: ['central', 'state', 'none'], default: 'none' },
  categories: [{ type: mongoose.Schema.Types.ObjectId, ref: 'Category' }]
});

module.exports = mongoose.model('CategoryGroup', categoryGroupSchema);