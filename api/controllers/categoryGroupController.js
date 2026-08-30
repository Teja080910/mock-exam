const CategoryGroup = require('../models/categoryGroupModel');
const Category = require('../models/categoryModel');
const fs = require('fs');
const path = require('path');

const normalizeScope = (value) => {
  const allowed = ['central', 'state', 'none'];
  return allowed.includes(value) ? value : 'none';
};

// Render add group form
exports.loadAddGroup = async (req, res) => {
  const categories = await Category.find({});
  res.render('addCategoryGroup', { categories });
};

// Add group
exports.addGroup = async (req, res) => {
  const { displayName, code, categories, scope } = req.body;
  const image = req.file ? req.file.filename : '';
  const group = new CategoryGroup({
    displayName,
    code: code || '',
    image,
    scope: normalizeScope(scope),
    categories: Array.isArray(categories) ? categories : (categories ? [categories] : [])
  });
  await group.save();
  res.redirect('/view-category-groups');
};

// Render edit group form
exports.loadEditGroup = async (req, res) => {
  const group = await CategoryGroup.findById(req.query.id).populate('categories');
  const categories = await Category.find({});
  res.render('editCategoryGroup', { group, categories });
};

// Update group
exports.updateGroup = async (req, res) => {
  const { id, displayName, code, categories, scope } = req.body;
  const updateData = {
    displayName,
    code: code || '',
    scope: normalizeScope(scope),
    categories: Array.isArray(categories) ? categories : (categories ? [categories] : [])
  };
  if (req.file) {
    // Delete old image
    const existing = await CategoryGroup.findById(id);
    if (existing && existing.image) {
      const oldPath = path.join(__dirname, '../public/assets/userImages', existing.image);
      if (fs.existsSync(oldPath)) fs.unlinkSync(oldPath);
    }
    updateData.image = req.file.filename;
  }
  await CategoryGroup.findByIdAndUpdate(id, updateData);
  res.redirect('/view-category-groups');
};

// List groups
exports.viewGroups = async (req, res) => {
  const groups = await CategoryGroup.find({}).populate('categories');
  res.render('viewCategoryGroups', { groups });
};

// Delete group
exports.deleteGroup = async (req, res) => {
  const group = await CategoryGroup.findById(req.query.id);
  if (group && group.image) {
    const imgPath = path.join(__dirname, '../public/assets/userImages', group.image);
    if (fs.existsSync(imgPath)) fs.unlinkSync(imgPath);
  }
  await CategoryGroup.findByIdAndDelete(req.query.id);
  res.redirect('/view-category-groups');
};
