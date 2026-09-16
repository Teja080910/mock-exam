const fs = require("fs");
const path = require('path')
const userimages = path.join('./public/assets/userImages/');
const { verifyAdminAccess } = require('../config/verification');
const Intro = require("../models/introModel");
const Admin = require("../models/adminModel");

// Load Intro
const loadIntro = async (req, res) => {
    try {
        const intro = await Intro.find({});
        res.render('addIntro', { intro: intro });
    } catch (error) {
        console.log(error.message);
    }
}

// Add Intro
const addIntro = async (req, res) => {
    try {
        let loginData = await Admin.findById({_id:req.session.user_id});
        if (loginData.is_admin == 1) {
            const introData = new Intro({
                title: req.body.title,
                image: req.file.filename,
                description: req.body.description,
                is_active: req.body.is_active = "on" ? 1 : 0
            });
            const saveIntro = await introData.save();
            const intro = await Intro.find({});
            if (saveIntro) {
                res.render('addIntro', { message: "Intro Added Succesfully..!!", intro: intro });
            }
            else {
                res.render('addIntro', { message: "Intro Not Added..!!*" });
            }
        } else {
            req.flash('error', 'You have no access to add Intro , You are not super admin !! *');
            return res.redirect('back');
        }
    } catch (error) {
        console.log(error.message);
    }
}

// View Intro
const viewIntro = async (req, res) => {
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
            if (req.query.search && String(req.query.search).trim() !== '') {
                const term = String(req.query.search).trim().replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
                filter.$or = [
                    { title: { $regex: term, $options: 'i' } },
                    { description: { $regex: term, $options: 'i' } }
                ];
            }

            const totalItems = await Intro.countDocuments(filter);
            const totalPages = Math.max(1, Math.ceil(totalItems / limit));
            const allIntro = await Intro.find(filter).sort({ createdAt: 1 }).skip(skip).limit(limit);

            const params = [];
            if (req.query.is_active !== undefined && req.query.is_active !== '') params.push(`is_active=${encodeURIComponent(req.query.is_active)}`);
            if (req.query.search) params.push(`search=${encodeURIComponent(req.query.search)}`);
            const extraParams = params.length > 0 ? '&' + params.join('&') : '';

            res.render('viewIntro', {
                intro: allIntro,
                loginData: loginData,
                currentPage: page,
                totalPages: totalPages,
                totalItems: totalItems,
                limit: limit,
                extraParams: extraParams,
                filters: {
                    is_active: req.query.is_active !== undefined ? req.query.is_active : '',
                    search: req.query.search || ''
                }
            });
        });
    } catch (error) {
        console.log(error.message);
    }
}

// Edit Intro
const editIntro = async (req, res) => {
    try {
        const id = req.query.id;
        const returnUrl = req.query.returnUrl || req.get('Referrer') || '/view-intro';
        const editData = await Intro.findById({ _id: id });
        if (editData) {
            res.render('editIntro', { intro: editData, returnUrl: returnUrl });
        }
        else {
            res.render('editIntro', { message: 'Intro Not Added', returnUrl: returnUrl });
        }
    } catch (error) {
        console.log(error.message);
    }
}

// Update Intro
const UpdateIntro = async (req, res) => {
    try {
        let loginData = await Admin.findById({_id:req.session.user_id});
        if (loginData.is_admin == 1) {
            const id = req.body.id;
            const returnUrl = req.body.returnUrl || req.query.returnUrl || '/view-intro';
            const currentIntro = await Intro.findById(id);
            if (req.file) {
                if (currentIntro) {
                    if (fs.existsSync(userimages + currentIntro.image)) {
                        fs.unlinkSync(userimages + currentIntro.image)
                    }
                }
                const UpdateData = await Intro.findByIdAndUpdate({ _id: id },
                    {
                        $set: {
                            title: req.body.title,
                            image: req.file.filename,
                            description: req.body.description
                        }
                    });
                res.redirect(returnUrl);
            }
            else {
                const UpdateData = await Intro.findByIdAndUpdate({ _id: id },
                    {
                        $set: {
                            title: req.body.title,
                            description: req.body.description
                        }
                    });
                res.redirect(returnUrl);
            }
        }
        else {
            req.flash('error', 'You have no access to edit Intro , You are not super admin !! *');
            return res.redirect('back');
        }

    } catch (error) {
        console.log(error.message);
    }
}

// Delete Intro
const deleteIntro = async (req, res) => {
    try {
        const id = req.query.id;
        const returnUrl = req.query.returnUrl || req.get('Referrer') || '/view-intro';
        const currentIntro = await Intro.findById(id);
        if (currentIntro) {
            if (fs.existsSync(userimages + currentIntro.image)) {
                fs.unlinkSync(userimages + currentIntro.image)
            }
        }
        const delIntro = await Intro.deleteOne({ _id: id });
        res.redirect(returnUrl);
    } catch (error) {
        console.log(error.message);
    }
}

// Active status
const activeStatus = async(req,res) => {
    try {
        let loginData = await Admin.findById({_id:req.session.user_id});
        if (loginData.is_admin == 1) {
            const returnUrl = req.body.returnUrl || req.get('Referrer') || '/view-intro';
            const intros = await Intro.findById({_id: req.params.id});
            intros.is_active = intros.is_active == 1 ? 0 : 1;
            await intros.save();
            res.redirect(returnUrl);
            return;
        } else {
            req.flash('error', 'You have no access to change status of Intro, You are not super admin !! *');
            return res.redirect('back');
        }
    } catch (error) {
        console.error(error);
    }
}

module.exports = {
    loadIntro,
    addIntro,
    viewIntro,
    editIntro,
    UpdateIntro,
    deleteIntro,
    activeStatus
}