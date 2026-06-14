const CategoryGroup = require('../models/categoryGroupModel');
const Category = require('../models/categoryModel');

// Render add group form
exports.loadAddGroup = async (req, res) => {
  const categories = await Category.find({});
  res.render('addCategoryGroup', { categories });
};

// Add group
exports.addGroup = async (req, res) => {
  const { displayName, categories } = req.body;
  const group = new CategoryGroup({
    displayName,
    categories: Array.isArray(categories) ? categories : [categories]
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
  const { id, displayName, categories } = req.body;
  await CategoryGroup.findByIdAndUpdate(id, {
    displayName,
    categories: Array.isArray(categories) ? categories : [categories]
  });
  res.redirect('/view-category-groups');
};

// List groups
exports.viewGroups = async (req, res) => {
  const groups = await CategoryGroup.find({}).populate('categories');
  res.render('viewCategoryGroups', { groups });
};

// Delete group
exports.deleteGroup = async (req, res) => {
  await CategoryGroup.findByIdAndDelete(req.query.id);
  res.redirect('/view-category-groups');
}; 