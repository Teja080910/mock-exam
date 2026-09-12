const CategoryGroup = require('../models/categoryGroupModel');
const Category = require('../models/categoryModel');
const fs = require('fs');
const path = require('path');

const normalizeScope = (value) => {
  const allowed = ['central', 'state', 'none'];
  return allowed.includes(value) ? value : 'none';
};

// Parse categories from form: handles string, comma-separated string, array of strings, or array of comma-separated strings
function parseCatIds(categories) {
  if (!categories) return [];
  let ids = [];
  if (Array.isArray(categories)) {
    categories.forEach(function(item) {
      if (typeof item === 'string') {
        item.split(',').forEach(function(s) { if (s.trim()) ids.push(s.trim()); });
      }
    });
  } else if (typeof categories === 'string') {
    categories.split(',').forEach(function(s) { if (s.trim()) ids.push(s.trim()); });
  }
  return ids;
}

// Render add group form
exports.loadAddGroup = async (req, res) => {
  const categories = await Category.find({});
  res.render('addCategoryGroup', { categories });
};

// Add group
exports.addGroup = async (req, res) => {
  const { displayName, code, categories, scope } = req.body;
  const image = req.file ? req.file.filename : '';
  const catIds = parseCatIds(categories);
  const group = new CategoryGroup({
    displayName,
    code: code || '',
    image,
    scope: normalizeScope(scope),
    categories: catIds
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
  const catIds = parseCatIds(categories);
  const updateData = {
    displayName,
    code: code || '',
    scope: normalizeScope(scope),
    categories: catIds
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
  const page = Math.max(1, parseInt(req.query.page, 10) || 1);
  const limit = 20;

  const filter = {};
  if (req.query.scope && ['central', 'state', 'none'].includes(req.query.scope)) {
    filter.scope = req.query.scope;
  }
  if (req.query.categoryId) {
    filter.categories = req.query.categoryId;
  }
  if (req.query.search && String(req.query.search).trim()) {
    const term = String(req.query.search).trim();
    filter.$or = [
      { displayName: { $regex: term, $options: 'i' } },
      { code: { $regex: term, $options: 'i' } },
    ];
  }

  const totalItems = await CategoryGroup.countDocuments(filter);
  const totalPages = Math.max(1, Math.ceil(totalItems / limit));

  const groups = await CategoryGroup.find(filter)
    .populate('categories')
    .sort({ displayName: 1 })
    .skip((page - 1) * limit)
    .limit(limit);

  const allCategories = await Category.find({}).sort({ name: 1 });

  res.render('viewCategoryGroups', {
    groups,
    currentPage: page,
    totalPages,
    totalItems,
    limit,
    allCategories,
    filters: {
      scope: req.query.scope || '',
      categoryId: req.query.categoryId || '',
      search: req.query.search || '',
    }
  });
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
