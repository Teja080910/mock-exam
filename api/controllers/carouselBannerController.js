const fs = require('fs');
const path = require('path');
const userimages = path.join('./public/assets/userImages/');
const { verifyAdminAccess } = require('../config/verification');
const CarouselBanner = require('../models/carouselBannerModel');
const Admin = require('../models/adminModel');

// Load Add Banner Form
const loadBanner = async (req, res) => {
    try {
        res.render('addBanner');
    } catch (error) {
        console.log(error.message);
    }
};

// Add Banner
const addBanner = async (req, res) => {
    try {
        let loginData = await Admin.findById({ _id: req.session.user_id });
        if (loginData.is_admin == 1) {
            const BannerData = new CarouselBanner({
                title: req.body.title,
                description: req.body.description,
                image: req.file.filename,
                order: req.body.order || 0,
                is_active: req.body.is_active == "on" ? 1 : 0
            });
            const saveBanner = await BannerData.save();
            res.redirect('/view-banner');
        } else {
            req.flash('error', 'You have no access to add Banner, You are not super admin !! *');
            return res.redirect('back');
        }
    } catch (error) {
        console.log(error.message);
    }
};

// View Banners
const viewBanner = async (req, res) => {
    try {
        await verifyAdminAccess(req, res, async () => {
            let loginData = await Admin.findById({ _id: req.session.user_id });
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

            const totalItems = await CarouselBanner.countDocuments(filter);
            const totalPages = Math.max(1, Math.ceil(totalItems / limit));
            const BannerData = await CarouselBanner.find(filter).sort({ order: 1, updatedAt: -1 }).skip(skip).limit(limit);

            const params = [];
            if (req.query.is_active !== undefined && req.query.is_active !== '') params.push(`is_active=${encodeURIComponent(req.query.is_active)}`);
            if (req.query.search) params.push(`search=${encodeURIComponent(req.query.search)}`);
            const extraParams = params.length > 0 ? '&' + params.join('&') : '';

            res.render('viewBanner', {
                banner: BannerData,
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
};

// Edit Banner
const editBanner = async (req, res) => {
    try {
        const id = req.query.id;
        const returnUrl = req.query.returnUrl || req.get('Referrer') || '/view-banner';
        const editData = await CarouselBanner.findById({ _id: id });
        if (editData) {
            res.render('editBanner', { editbanner: editData, returnUrl: returnUrl });
        } else {
            res.render('editBanner', { message: 'Banner Not Found', returnUrl: returnUrl });
        }
    } catch (error) {
        console.log(error.message);
    }
};

// Update Banner
const updateBanner = async (req, res) => {
    try {
        let loginData = await Admin.findById({ _id: req.session.user_id });
        if (loginData.is_admin == 1) {
            const id = req.body.id;
            const returnUrl = req.body.returnUrl || req.query.returnUrl || '/view-banner';
            const currentBanner = await CarouselBanner.findById(id);
            const updateData = {
                title: req.body.title,
                description: req.body.description,
                order: req.body.order || currentBanner.order
            };

            if (req.file) {
                if (currentBanner && fs.existsSync(userimages + currentBanner.image)) {
                    fs.unlinkSync(userimages + currentBanner.image);
                }
                updateData.image = req.file.filename;
            }

            await CarouselBanner.findByIdAndUpdate({ _id: id }, { $set: updateData });
            res.redirect(returnUrl);
        } else {
            req.flash('error', 'You have no access to edit banner, You are not super admin !! *');
            return res.redirect('back');
        }
    } catch (error) {
        console.log(error.message);
    }
};

// Delete Banner
const deleteBanner = async (req, res) => {
    try {
        const id = req.query.id;
        const returnUrl = req.query.returnUrl || req.get('Referrer') || '/view-banner';
        const currentBanner = await CarouselBanner.findById(id);
        if (currentBanner) {
            if (fs.existsSync(userimages + currentBanner.image)) {
                fs.unlinkSync(userimages + currentBanner.image);
            }
        }
        const delBanner = await CarouselBanner.deleteOne({ _id: id });
        res.redirect(returnUrl);
    } catch (error) {
        console.log(error.message);
    }
};

// Toggle Active Status
const activeStatus = async (req, res) => {
    try {
        const { id } = req.params;
        const returnUrl = req.body.returnUrl || req.get('Referrer') || '/view-banner';
        const status = await CarouselBanner.findById({ _id: id });
        if (!status) {
            return res.sendStatus(404);
        }
        status.is_active = !status.is_active;
        await status.save();
        res.redirect(returnUrl);
    } catch (err) {
        console.error(err);
        res.sendStatus(500);
    }
};

module.exports = {
    loadBanner,
    addBanner,
    viewBanner,
    editBanner,
    updateBanner,
    deleteBanner,
    activeStatus
}; 