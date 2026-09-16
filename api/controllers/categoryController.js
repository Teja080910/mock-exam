const fs = require("fs");
const path = require('path')
const userimages = path.join('./public/assets/userImages/');
const { verifyAdminAccess } = require('../config/verification');
const Category = require("../models/categoryModel");
const CategoryGroup = require("../models/categoryGroupModel");
const Quiz = require("../models/quizModel");
const Admin = require("../models/adminModel");
const Subcategory = require("../models/subcategoryModel");

// Load category
const loadCategory = async (req, res) => {
    try {
        const groups = await CategoryGroup.find({}).sort({ displayName: 1 });
        res.render('addCategory', { groups });
    } catch (error) {
        console.log(error.message);
    }
}

// Add category
const addcategory = async (req, res) => {
    try {
        let loginData = await Admin.findById({_id:req.session.user_id});
        if (loginData.is_admin == 1) {
            const categoryData = new Category({
                name: req.body.name,
                displayName: req.body.displayName,
                parentCategory: req.body.parentCategory || null,
                image: req.file.filename,
                is_feature: req.body.is_feature == "on" ? 1 : 0,
                is_active: req.body.is_active == "on" ? 1 : 0
            });
            const savecategory = await categoryData.save();
            if (savecategory) {
                if (req.body.categoryGroupId) {
                    await CategoryGroup.findByIdAndUpdate(req.body.categoryGroupId, {
                        $addToSet: { categories: savecategory._id }
                    });
                }
                const groups = await CategoryGroup.find({}).sort({ displayName: 1 });
                res.render('addCategory', { message: "Category Added SuccessFully..!!", groups });
            }
            else {
                const groups = await CategoryGroup.find({}).sort({ displayName: 1 });
                res.render('addCategory', { message: "Category Not Added..!!*", groups });
            }
        }
        else {
            req.flash('error', 'You have no access to add category , You are not super admin !! *');
            return res.redirect('back');
        }
    } catch (error) {
        console.log(error.message);
    }
}

// View category
const viewCategory = async (req, res) => {
    try {
        await verifyAdminAccess(req, res, async () => {
            let loginData = await Admin.findById({_id:req.session.user_id});
            const page = Math.max(1, parseInt(req.query.page, 10) || 1);
            const limit = 20;
            const skip = (page - 1) * limit;

            const filter = {};
            if (req.query.is_active !== undefined && req.query.is_active !== '') {
                filter.is_active = parseInt(req.query.is_active, 10);
            }
            if (req.query.is_feature !== undefined && req.query.is_feature !== '') {
                filter.is_feature = parseInt(req.query.is_feature, 10);
            }
            if (req.query.search && String(req.query.search).trim() !== '') {
                const term = String(req.query.search).trim().replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
                filter.$or = [
                    { name: { $regex: term, $options: 'i' } },
                    { displayName: { $regex: term, $options: 'i' } }
                ];
            }

            const totalItems = await Category.countDocuments(filter);
            const totalPages = Math.max(1, Math.ceil(totalItems / limit));
            const allCategory = await Category.find(filter).sort({ updatedAt: -1 }).skip(skip).limit(limit);
            
            const categoryIds = allCategory.map(c => c._id);
            const quizCounts = await Quiz.aggregate([
                { $match: { categoryId: { $in: categoryIds } } },
                { $group: { _id: "$categoryId", count: { $sum: 1 } } }
            ]);
            const quizCountMap = {};
            quizCounts.forEach(qc => {
                if (qc._id) quizCountMap[qc._id.toString()] = qc.count;
            });

            // Backward compatibility
            const quiz = await Quiz.find({ categoryId: { $in: categoryIds } }).populate('categoryId');

            const params = [];
            if (req.query.is_active !== undefined && req.query.is_active !== '') params.push(`is_active=${encodeURIComponent(req.query.is_active)}`);
            if (req.query.is_feature !== undefined && req.query.is_feature !== '') params.push(`is_feature=${encodeURIComponent(req.query.is_feature)}`);
            if (req.query.search) params.push(`search=${encodeURIComponent(req.query.search)}`);
            const extraParams = params.length > 0 ? '&' + params.join('&') : '';

            res.render('viewCategory', {
                category: allCategory,
                loginData: loginData,
                quiz: quiz,
                quizCountMap: quizCountMap,
                currentPage: page,
                totalPages: totalPages,
                totalItems: totalItems,
                limit: limit,
                extraParams: extraParams,
                filters: {
                    is_active: req.query.is_active !== undefined ? req.query.is_active : '',
                    is_feature: req.query.is_feature !== undefined ? req.query.is_feature : '',
                    search: req.query.search || ''
                }
            });
        });
    } catch (error) {
        console.log(error.message);
    }
}

// Edit category
const editCategory = async (req, res) => {
    try {
        const id = req.query.id;
        const returnUrl = req.query.returnUrl || req.get('Referrer') || '/view-category';
        const editData = await Category.findById({ _id: id });
        const groups = await CategoryGroup.find({}).sort({ displayName: 1 });
        const currentGroup = await CategoryGroup.findOne({ categories: id });
        if (editData) {
            res.render('editCategory', { category: editData, groups, currentGroupId: currentGroup ? currentGroup._id : null, returnUrl: returnUrl });
        }
        else {
            res.render('editCategory', { message: 'Category Not Added', groups, currentGroupId: null, returnUrl: returnUrl });
        }
    } catch (error) {
        console.log(error.message);
    }
}

// Update category
const UpdateCategory = async (req, res) => {
    try {
        let loginData = await Admin.findById({_id:req.session.user_id});
        if (loginData.is_admin == 1) {
            const id = req.body.id;
            const returnUrl = req.body.returnUrl || req.query.returnUrl || '/view-category';
            const currentCategory = await Category.findById(id);
            const categoryIdObj = require('mongoose').Types.ObjectId(id);
            if (req.file) {
                if (currentCategory) {
                    if (fs.existsSync(userimages + currentCategory.image)) {
                        fs.unlinkSync(userimages + currentCategory.image)
                    }
                }
                await Category.findByIdAndUpdate({ _id: id },
                    {
                        $set: {
                            name: req.body.name,
                            displayName: req.body.displayName,
                            parentCategory: req.body.parentCategory || null,
                            image: req.file.filename
                        }
                    });
            }
            else {
                await Category.findByIdAndUpdate({ _id: id },
                    {
                        $set: {
                            name: req.body.name,
                            displayName: req.body.displayName,
                            parentCategory: req.body.parentCategory || null
                        }
                    });
            }
            if (req.body.categoryGroupId) {
                await CategoryGroup.updateMany({ categories: categoryIdObj }, { $pull: { categories: categoryIdObj } });
                await CategoryGroup.findByIdAndUpdate(req.body.categoryGroupId, { $addToSet: { categories: categoryIdObj } });
            }
            res.redirect(returnUrl);
        }
        else {
            req.flash('error', 'You have no access to edit category , You are not super admin !! *');
            return res.redirect('back');
        }
    } catch (error) {
        console.log(error.message);
    }
}

// Feature status
const featureStatus = async (req, res) => {
    try {
        const { id } = req.params;
        const returnUrl = req.body.returnUrl || req.get('Referrer') || '/view-category';
        const status = await Category.findById(id);
        const is_feature = req.body.is_feature ? req.body.is_feature : "false";
        if (!status) {
            return res.sendStatus(404);
        }
        status.is_feature = !status.is_feature;
        await status.save();
        res.redirect(returnUrl);

    } catch (err) {
        console.error(err);
        res.sendStatus(500);

    }
}

// Active status
const activeStatus = async (req, res) => {
    try {
        const { id } = req.params;
        const returnUrl = req.body.returnUrl || req.get('Referrer') || '/view-category';
        const status = await Category.findById(id);
        const is_active = req.body.is_active ? req.body.is_active : "false";
        console.log(status);
        if (!status) {
            return res.sendStatus(404);
        }
        status.is_active = !status.is_active;
        console.log(status.is_active);
        await status.save();
        res.redirect(returnUrl);
    } catch (err) {
        console.error(err);
        res.sendStatus(500);
    }
}

// Delete category
const deleteCategory = async (req, res) => {
    try {
        const id = req.query.id;
        const returnUrl = req.query.returnUrl || req.get('Referrer') || '/view-category';
        const categoryIdObj = require('mongoose').Types.ObjectId(id);
        const currentCategory = await Category.findById(id);
        if (currentCategory) {
            if (fs.existsSync(userimages + currentCategory.image)) {
                fs.unlinkSync(userimages + currentCategory.image)
            }
        }
        await CategoryGroup.updateMany({ categories: categoryIdObj }, { $pull: { categories: categoryIdObj } });
        await Category.deleteOne({ _id: id });
        res.redirect(returnUrl);
    } catch (error) {
        console.log(error.message);
    }
}

// Featured category
const featuredCategory = async (req, res) => {
    try {
        let loginData = await Admin.findById({_id:req.session.user_id});
        const allCategory = await Category.find({ is_feature: 1 }).sort({ updatedAt: -1 });
        if (allCategory) {
            res.render('featuredCategory', { category: allCategory, loginData: loginData });
        }
        else {
            console.log(error.message);
        }
    } catch (error) {
        console.log(error.message);
    }
}

// Load subcategory
const loadSubcategory = async (req, res) => {
    try {
        const categories = await Category.find({ is_active: 1 });
        res.render('addSubcategory', { categories });
    } catch (error) {
        console.log(error.message);
    }
}

// Add subcategory
const addSubcategory = async (req, res) => {
    try {
        let loginData = await Admin.findById({ _id: req.session.user_id });
        if (loginData.is_admin == 1) {
            const subcategoryData = new Subcategory({
                name: req.body.name,
                image: req.file.filename,
                categoryId: req.body.categoryId,
                is_feature: req.body.is_feature == "on" ? 1 : 0,
                is_active: req.body.is_active == "on" ? 1 : 0
            });
            const saveSubcategory = await subcategoryData.save();
            if (saveSubcategory) {
                res.render('addSubcategory', { message: "Subcategory Added SuccessFully..!!", categories: await Category.find({ is_active: 1 }) });
            } else {
                res.render('addSubcategory', { message: "Subcategory Not Added..!!*", categories: await Category.find({ is_active: 1 }) });
            }
        } else {
            req.flash('error', 'You have no access to add subcategory, You are not super admin !! *');
            return res.redirect('back');
        }
    } catch (error) {
        console.log(error.message);
    }
}

// View subcategories
const viewSubcategory = async (req, res) => {
    try {
        let loginData = await Admin.findById({ _id: req.session.user_id });
        const page = Math.max(1, parseInt(req.query.page, 10) || 1);
        const limit = 20;
        const skip = (page - 1) * limit;

        const filter = {};
        if (req.query.categoryId && req.query.categoryId.trim() !== '') {
            filter.categoryId = req.query.categoryId.trim();
        }
        if (req.query.is_active !== undefined && req.query.is_active !== '') {
            filter.is_active = parseInt(req.query.is_active, 10);
        }
        if (req.query.is_feature !== undefined && req.query.is_feature !== '') {
            filter.is_feature = parseInt(req.query.is_feature, 10);
        }
        if (req.query.search && String(req.query.search).trim() !== '') {
            const term = String(req.query.search).trim().replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
            filter.name = { $regex: term, $options: 'i' };
        }

        const categories = await Category.find().sort({ name: 1 });
        const totalItems = await Subcategory.countDocuments(filter);
        const totalPages = Math.max(1, Math.ceil(totalItems / limit));
        const allSubcategory = await Subcategory.find(filter).populate('categoryId').sort({ updatedAt: -1 }).skip(skip).limit(limit);

        const params = [];
        if (req.query.categoryId) params.push(`categoryId=${encodeURIComponent(req.query.categoryId)}`);
        if (req.query.is_active !== undefined && req.query.is_active !== '') params.push(`is_active=${encodeURIComponent(req.query.is_active)}`);
        if (req.query.is_feature !== undefined && req.query.is_feature !== '') params.push(`is_feature=${encodeURIComponent(req.query.is_feature)}`);
        if (req.query.search) params.push(`search=${encodeURIComponent(req.query.search)}`);
        const extraParams = params.length > 0 ? '&' + params.join('&') : '';

        res.render('viewSubcategory', {
            subcategory: allSubcategory,
            category: categories,
            loginData: loginData,
            currentPage: page,
            totalPages: totalPages,
            totalItems: totalItems,
            limit: limit,
            extraParams: extraParams,
            filters: {
                categoryId: req.query.categoryId || '',
                is_active: req.query.is_active !== undefined ? req.query.is_active : '',
                is_feature: req.query.is_feature !== undefined ? req.query.is_feature : '',
                search: req.query.search || ''
            }
        });
    } catch (error) {
        console.log('Error in viewSubcategory:', error.message);
        res.render('viewSubcategory', { subcategory: [], category: [], loginData: null, currentPage: 1, totalPages: 0, totalItems: 0, limit: 20, extraParams: '', filters: {} });
    }
}

// Edit subcategory
const editSubcategory = async (req, res) => {
    try {
        console.log('=== EDIT SUBCATEGORY CALLED ===');
        const id = req.query.id;
        const returnUrl = req.query.returnUrl || req.get('Referrer') || '/view-subcategory';
        console.log('Subcategory ID:', id);
        
        const editData = await Subcategory.findById({ _id: id });
        console.log('Edit data found:', !!editData);
        console.log('Edit data:', editData);
        
        const categories = await Category.find({ is_active: 1 });
        console.log('Categories found:', categories.length);
        
        if (editData) {
            res.render('editSubcategory', { subcategory: editData, categories, returnUrl: returnUrl });
        } else {
            console.log('Subcategory not found');
            res.render('editSubcategory', { message: 'Subcategory Not Found', categories, returnUrl: returnUrl });
        }
    } catch (error) {
        console.log('Error in editSubcategory:', error.message);
        res.render('editSubcategory', { message: 'Error loading subcategory', categories: [], returnUrl: req.query.returnUrl || '/view-subcategory' });
    }
}

// Update subcategory
const updateSubcategory = async (req, res) => {
    try {
        let loginData = await Admin.findById({ _id: req.session.user_id });
        if (loginData.is_admin == 1) {
            const id = req.body.id;
            const returnUrl = req.body.returnUrl || req.query.returnUrl || '/view-subcategory';
            const currentSubcategory = await Subcategory.findById(id);
            if (req.file) {
                if (currentSubcategory) {
                    if (fs.existsSync(userimages + currentSubcategory.image)) {
                        fs.unlinkSync(userimages + currentSubcategory.image)
                    }
                }
                await Subcategory.findByIdAndUpdate({ _id: id }, {
                    $set: {
                        name: req.body.name,
                        image: req.file.filename,
                        categoryId: req.body.categoryId
                    }
                });
                res.redirect(returnUrl);
            } else {
                await Subcategory.findByIdAndUpdate({ _id: id }, {
                    $set: {
                        name: req.body.name,
                        categoryId: req.body.categoryId
                    }
                });
                res.redirect(returnUrl);
            }
        } else {
            req.flash('error', 'You have no access to edit subcategory, You are not super admin !! *');
            return res.redirect('back');
        }
    } catch (error) {
        console.log(error.message);
    }
}

// Delete subcategory
const deleteSubcategory = async (req, res) => {
    try {
        const id = req.query.id;
        const returnUrl = req.query.returnUrl || req.get('Referrer') || '/view-subcategory';
        const currentSubcategory = await Subcategory.findById(id);
        if (currentSubcategory) {
            if (fs.existsSync(userimages + currentSubcategory.image)) {
                fs.unlinkSync(userimages + currentSubcategory.image)
            }
        }
        await Subcategory.deleteOne({ _id: id });
        res.redirect(returnUrl);
    } catch (error) {
        console.log(error.message);
    }
}

module.exports = {
    loadCategory,
    addcategory,
    viewCategory,
    editCategory,
    UpdateCategory,
    deleteCategory,
    featureStatus,
    activeStatus,
    featuredCategory,
    loadSubcategory,
    addSubcategory,
    viewSubcategory,
    editSubcategory,
    updateSubcategory,
    deleteSubcategory
}