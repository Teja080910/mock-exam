const fs = require('fs');
const path = require('path');
const userimages = path.join('./public/assets/userImages/');
const { verifyAdminAccess } = require('../config/verification');
const Ebook = require('../models/ebookModel');
const Admin = require('../models/adminModel');

// Load Add Ebook Form
const loadEbook = async (req, res) => {
    try {
        res.render('addEbook');
    } catch (error) {
        console.log(error.message);
    }
};

// Add Ebook
const addEbook = async (req, res) => {
    try {
        let loginData = await Admin.findById({ _id: req.session.user_id });
        if (loginData.is_admin == 1) {
            const EbookData = new Ebook({
                name: req.body.name,
                language: req.body.language,
                link: req.body.link,
                image: req.files.image[0].filename,
                is_active: req.body.is_active == "on" ? 1 : 0
            });
            const saveEbook = await EbookData.save();
            res.redirect('/view-ebook');
        } else {
            req.flash('error', 'You have no access to add Ebook, You are not super admin !! *');
            return res.redirect('back');
        }
    } catch (error) {
        console.log(error.message);
    }
};

// View Ebooks
const viewEbook = async (req, res) => {
    try {
        await verifyAdminAccess(req, res, async () => {
            let loginData = await Admin.findById({ _id: req.session.user_id });
            const EbookData = await Ebook.find().sort({ updatedAt: -1 });
            res.render('viewEbook', { ebook: EbookData, loginData: loginData });
        });
    } catch (error) {
        console.log(error.message);
    }
};

// Edit Ebook
const editEbook = async (req, res) => {
    try {
        const id = req.query.id;
        const editData = await Ebook.findById({ _id: id });
        if (editData) {
            res.render('editEbook', { editebook: editData });
        } else {
            res.render('editEbook', { message: 'Ebook Not Found' });
        }
    } catch (error) {
        console.log(error.message);
    }
};

// Update Ebook
const updateEbook = async (req, res) => {
    try {
        let loginData = await Admin.findById({ _id: req.session.user_id });
        if (loginData.is_admin == 1) {
            const id = req.body.id;
            const currentEbook = await Ebook.findById(id);
            const updateData = { 
                name: req.body.name,
                language: req.body.language,
                link: req.body.link
            };

            // Handle image update
            if (req.files && req.files.image) {
                if (currentEbook && fs.existsSync(userimages + currentEbook.image)) {
                    fs.unlinkSync(userimages + currentEbook.image);
                }
                updateData.image = req.files.image[0].filename;
            }

            await Ebook.findByIdAndUpdate({ _id: id }, { $set: updateData });
            res.redirect('/view-ebook');
        } else {
            req.flash('error', 'You have no access to edit ebook, You are not super admin !! *');
            return res.redirect('back');
        }
    } catch (error) {
        console.log(error.message);
    }
};

// Delete Ebook
const deleteEbook = async (req, res) => {
    try {
        const id = req.query.id;
        const currentEbook = await Ebook.findById(id);
        if (currentEbook) {
            if (fs.existsSync(userimages + currentEbook.image)) {
                fs.unlinkSync(userimages + currentEbook.image);
            }
        }
        const delEbook = await Ebook.deleteOne({ _id: id });
        res.redirect('/view-ebook');
    } catch (error) {
        console.log(error.message);
    }
};

// Active status
const activeStatus = async (req, res) => {
    try {
        const { id } = req.params;
        const status = await Ebook.findById({ _id: id });
        if (!status) {
            return res.sendStatus(404);
        }
        status.is_active = !status.is_active;
        await status.save();
        res.redirect('/view-ebook');
    } catch (err) {
        console.error(err);
        res.sendStatus(500);
    }
};

module.exports = { loadEbook, addEbook, viewEbook, editEbook, updateEbook, deleteEbook, activeStatus }; 