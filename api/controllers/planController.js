const Plan = require('../models/planModel');
const Admin = require("../models/adminModel");
const { verifyAdminAccess } = require('../config/verification');
const CategoryGroup = require('../models/categoryGroupModel');

// Load Plan
const loadPlan = async (req, res) => {
    try {
        const categoryGroups = await CategoryGroup.find({});
        const plan = await Plan.find({});
        res.render('addPlan', { plan: plan, categoryGroups: categoryGroups });
    } catch (error) {
        console.log(error.message);
    }
}

// Add Plan
const addPlan = async (req, res) => {
    try {
        let loginData = await Admin.findById({ _id: req.session.user_id });
        if (loginData.is_admin == 1) {
            const categoryGroups = await CategoryGroup.find({});
            const categoryGroupVal = req.body.categoryGroup === 'all' ? null : req.body.categoryGroup;

            const existingPlan = await Plan.findOne({ categoryGroup: categoryGroupVal });
            if (existingPlan) {
                return res.render('addPlan', { message: "Plan for this Category Group already exists!", categoryGroups: categoryGroups });
            }

            // Generate random Plan ID (Format: PLAN-XXXXXX)
            const characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
            let randomStr = '';
            for (let i = 0; i < 6; i++) {
                randomStr += characters.charAt(Math.floor(Math.random() * characters.length));
            }
            const randomPlanId = `PLAN-${randomStr}`;

            const planData = new Plan({
                planName: req.body.planName,
                planValidity: req.body.planValidity,
                price: req.body.price,
                planId: randomPlanId,
                categoryGroup: categoryGroupVal
            });
            const savePlan = await planData.save();
            const plan = await Plan.find({});
            if (savePlan) {
                res.render('addPlan', { message: "Plan Added Succesfully..!!", plan: plan, categoryGroups: categoryGroups });
            }
            else {
                res.render('addPlan', { message: "Plan Not Added..!!*", categoryGroups: categoryGroups });
            }
        }
        else {
            req.flash('error', 'You have no access to add Plan , You are not super admin !! *');
            return res.redirect('back');
        }
    } catch (error) {
        console.log(error.message);
    }
}

// View Plan
const viewPlan = async (req, res) => {
    try {
        await verifyAdminAccess(req, res, async () => {
            let loginData = await Admin.findById({ _id: req.session.user_id });
            const allPlan = await Plan.find({}).populate('categoryGroup').sort({ updatedAt: -1 });
            if (allPlan) {
                res.render('viewPlan', { plan: allPlan, loginData: loginData });
            }
            else {
                console.log(error.message);
            }
        });
    } catch (error) {
        console.log(error.message);
    }
}

// Edit Plan
const editPlan = async (req, res) => {
    try {
        const id = req.query.id;
        const editData = await Plan.findById({ _id: id });
        const categoryGroups = await CategoryGroup.find({});
        if (editData) {
            res.render('editPlan', { plan: editData, categoryGroups: categoryGroups });
        }
        else {
            res.render('editPlan', { message: 'Plan Not Found', categoryGroups: categoryGroups });
        }
    } catch (error) {
        console.log(error.message);
    }
}

// Update Plan
const updatePlan = async (req, res) => {
    try {
        let loginData = await Admin.findById({ _id: req.session.user_id });
        if (loginData.is_admin == 1) {
            const id = req.body.id;
            const categoryGroupVal = req.body.categoryGroup === 'all' ? null : req.body.categoryGroup;

            const existingPlan = await Plan.findOne({ categoryGroup: categoryGroupVal, _id: { $ne: id } });
            if (existingPlan) {
                req.flash('error', 'A plan for this Category Group already exists!');
                return res.redirect('back');
            }
            await Plan.findByIdAndUpdate({ _id: id },
                {
                    $set: {
                        planName: req.body.planName,
                        planValidity: req.body.planValidity,
                        price: req.body.price,
                        categoryGroup: categoryGroupVal
                    }
                });
            res.redirect('/view-plan');
        }
        else {
            req.flash('error', 'You have no access to edit plan , You are not super admin !! *');
            return res.redirect('back');
        }
    } catch (error) {
        console.log(error.message);
    }
}

// Delete Plan
const deletePlan = async (req, res) => {
    try {
        const id = req.query.id;
        const delPlan = await Plan.deleteOne({ _id: id });
        res.redirect('/view-plan');
    } catch (error) {
        console.log(error.message);
    }
}


module.exports = {
    loadPlan,
    addPlan,
    viewPlan,
    editPlan,
    updatePlan,
    deletePlan
}