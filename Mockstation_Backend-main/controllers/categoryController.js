const fs = require("fs");
const path = require('path')
const userimages = path.join('./public/assets/userImages/');
const { verifyAdminAccess } = require('../config/verification');
const Category = require("../models/categoryModel");
const Quiz = require("../models/quizModel");
const Admin = require("../models/adminModel");
const Subcategory = require("../models/subcategoryModel");

// Load category
const loadCategory = async (req, res) => {
    try {
        res.render('addCategory');
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
                res.render('addCategory', { message: "Category Added SuccessFully..!!" });
            }
            else {
                res.render('addCategory', { message: "Category Not Added..!!*" });
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
            const allCategory = await Category.find({}).sort({ updatedAt: -1 });
            const quiz = await Quiz.find().populate('categoryId');
            if (allCategory) {
                res.render('viewCategory', { category: allCategory, loginData: loginData, quiz: quiz });
            }
            else {
                console.log(error.message);
            }
        });
    } catch (error) {
        console.log(error.message);
    }
}

// Edit category
const editCategory = async (req, res) => {
    try {
        const id = req.query.id;
        const editData = await Category.findById({ _id: id });
        if (editData) {
            res.render('editCategory', { category: editData });
        }
        else {
            res.render('editCategory', { message: 'Category Not Added' });
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
            const currentCategory = await Category.findById(id);
            if (req.file) {
                if (currentCategory) {
                    if (fs.existsSync(userimages + currentCategory.image)) {
                        fs.unlinkSync(userimages + currentCategory.image)
                    }
                }
                const UpdateData = await Category.findByIdAndUpdate({ _id: id },
                    {
                        $set: {
                            name: req.body.name,
                            displayName: req.body.displayName,
                            parentCategory: req.body.parentCategory || null,
                            image: req.file.filename
                        }
                    });
                res.redirect('/view-category');
            }
            else {
                const UpdateData = await Category.findByIdAndUpdate({ _id: id },
                    {
                        $set: {
                            name: req.body.name,
                            displayName: req.body.displayName,
                            parentCategory: req.body.parentCategory || null
                        }
                    });
                res.redirect('/view-category');
            }
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
        const status = await Category.findById(id);
        const is_feature = req.body.is_feature ? req.body.is_feature : "false";
        if (!status) {
            return res.sendStatus(404);
        }
        status.is_feature = !status.is_feature;
        await status.save();
        res.redirect('/view-category');

    } catch (err) {
        console.error(err);
        res.sendStatus(500);

    }
}

// Active status
const activeStatus = async (req, res) => {
    try {
        const { id } = req.params;
        const status = await Category.findById(id);
        const is_active = req.body.is_active ? req.body.is_active : "false";
        console.log(status);
        if (!status) {
            return res.sendStatus(404);
        }
        status.is_active = !status.is_active;
        console.log(status.is_active);
        await status.save();
        res.redirect('/view-category');
    } catch (err) {
        console.error(err);
        res.sendStatus(500);
    }
}

// Delete category
const deleteCategory = async (req, res) => {
    try {
        const id = req.query.id;
        const currentCategory = await Category.findById(id);
        if (currentCategory) {
            if (fs.existsSync(userimages + currentCategory.image)) {
                fs.unlinkSync(userimages + currentCategory.image)
            }
        }
        const delBanner = await Category.deleteOne({ _id: id });
        res.redirect('/view-category');
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
        console.log('=== VIEW SUBCATEGORY CALLED ===');
        let loginData = await Admin.findById({ _id: req.session.user_id });
        console.log('Login data found:', !!loginData);
        
        const allSubcategory = await Subcategory.find({}).populate('categoryId').sort({ updatedAt: -1 });
        console.log('Subcategories found:', allSubcategory.length);
        console.log('Subcategories:', allSubcategory);
        
        if (allSubcategory) {
            res.render('viewSubcategory', { subcategory: allSubcategory, loginData: loginData });
        } else {
            console.log('No subcategories found');
            res.render('viewSubcategory', { subcategory: [], loginData: loginData });
        }
    } catch (error) {
        console.log('Error in viewSubcategory:', error.message);
        res.render('viewSubcategory', { subcategory: [], loginData: null });
    }
}

// Edit subcategory
const editSubcategory = async (req, res) => {
    try {
        console.log('=== EDIT SUBCATEGORY CALLED ===');
        const id = req.query.id;
        console.log('Subcategory ID:', id);
        
        const editData = await Subcategory.findById({ _id: id });
        console.log('Edit data found:', !!editData);
        console.log('Edit data:', editData);
        
        const categories = await Category.find({ is_active: 1 });
        console.log('Categories found:', categories.length);
        
        if (editData) {
            res.render('editSubcategory', { subcategory: editData, categories });
        } else {
            console.log('Subcategory not found');
            res.render('editSubcategory', { message: 'Subcategory Not Found', categories });
        }
    } catch (error) {
        console.log('Error in editSubcategory:', error.message);
        res.render('editSubcategory', { message: 'Error loading subcategory', categories: [] });
    }
}

// Update subcategory
const updateSubcategory = async (req, res) => {
    try {
        let loginData = await Admin.findById({ _id: req.session.user_id });
        if (loginData.is_admin == 1) {
            const id = req.body.id;
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
                res.redirect('/view-subcategory');
            } else {
                await Subcategory.findByIdAndUpdate({ _id: id }, {
                    $set: {
                        name: req.body.name,
                        categoryId: req.body.categoryId
                    }
                });
                res.redirect('/view-subcategory');
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
        const currentSubcategory = await Subcategory.findById(id);
        if (currentSubcategory) {
            if (fs.existsSync(userimages + currentSubcategory.image)) {
                fs.unlinkSync(userimages + currentSubcategory.image)
            }
        }
        await Subcategory.deleteOne({ _id: id });
        res.redirect('/view-subcategory');
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