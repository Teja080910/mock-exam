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
            const BannerData = await CarouselBanner.find().sort({ order: 1, updatedAt: -1 });
            res.render('viewBanner', { banner: BannerData, loginData: loginData });
        });
    } catch (error) {
        console.log(error.message);
    }
};

// Edit Banner
const editBanner = async (req, res) => {
    try {
        const id = req.query.id;
        const editData = await CarouselBanner.findById({ _id: id });
        if (editData) {
            res.render('editBanner', { editbanner: editData });
        } else {
            res.render('editBanner', { message: 'Banner Not Found' });
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
            res.redirect('/view-banner');
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
        const currentBanner = await CarouselBanner.findById(id);
        if (currentBanner) {
            if (fs.existsSync(userimages + currentBanner.image)) {
                fs.unlinkSync(userimages + currentBanner.image);
            }
        }
        const delBanner = await CarouselBanner.deleteOne({ _id: id });
        res.redirect('/view-banner');
    } catch (error) {
        console.log(error.message);
    }
};

// Toggle Active Status
const activeStatus = async (req, res) => {
    try {
        const { id } = req.params;
        const status = await CarouselBanner.findById({ _id: id });
        if (!status) {
            return res.sendStatus(404);
        }
        status.is_active = !status.is_active;
        await status.save();
        res.redirect('/view-banner');
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