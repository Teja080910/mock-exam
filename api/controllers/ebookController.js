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
                link: (req.body.link || '').trim(),
                image: req.files.image[0].filename,
                file: req.files && req.files.file ? req.files.file[0].filename : '',
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
            const page = Math.max(1, parseInt(req.query.page, 10) || 1);
            const limit = 20;
            const skip = (page - 1) * limit;

            const filter = {};
            if (req.query.is_active !== undefined && req.query.is_active !== '') {
                filter.is_active = parseInt(req.query.is_active, 10);
            }
            if (req.query.language && req.query.language.trim() !== '') {
                filter.language = req.query.language.trim();
            }
            if (req.query.search && String(req.query.search).trim() !== '') {
                const term = String(req.query.search).trim().replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
                filter.name = { $regex: term, $options: 'i' };
            }

            const languages = await Ebook.distinct('language');
            const totalItems = await Ebook.countDocuments(filter);
            const totalPages = Math.max(1, Math.ceil(totalItems / limit));
            const EbookData = await Ebook.find(filter).sort({ updatedAt: -1 }).skip(skip).limit(limit);

            const params = [];
            if (req.query.is_active !== undefined && req.query.is_active !== '') params.push(`is_active=${encodeURIComponent(req.query.is_active)}`);
            if (req.query.language) params.push(`language=${encodeURIComponent(req.query.language)}`);
            if (req.query.search) params.push(`search=${encodeURIComponent(req.query.search)}`);
            const extraParams = params.length > 0 ? '&' + params.join('&') : '';

            res.render('viewEbook', {
                ebook: EbookData,
                languages: languages.filter(Boolean),
                loginData: loginData,
                currentPage: page,
                totalPages: totalPages,
                totalItems: totalItems,
                limit: limit,
                extraParams: extraParams,
                filters: {
                    is_active: req.query.is_active !== undefined ? req.query.is_active : '',
                    language: req.query.language || '',
                    search: req.query.search || ''
                }
            });
        });
    } catch (error) {
        console.log(error.message);
    }
};

// Edit Ebook
const editEbook = async (req, res) => {
    try {
        const id = req.query.id;
        const returnUrl = req.query.returnUrl || req.get('Referrer') || '/view-ebook';
        const editData = await Ebook.findById({ _id: id });
        if (editData) {
            res.render('editEbook', { editebook: editData, returnUrl: returnUrl });
        } else {
            res.render('editEbook', { message: 'Ebook Not Found', returnUrl: returnUrl });
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
            const returnUrl = req.body.returnUrl || req.query.returnUrl || '/view-ebook';
            const currentEbook = await Ebook.findById(id);
            const updateData = { 
                name: req.body.name,
                language: req.body.language,
                link: (req.body.link || '').trim()
            };

            // Handle image update
            if (req.files && req.files.image) {
                if (currentEbook && fs.existsSync(userimages + currentEbook.image)) {
                    fs.unlinkSync(userimages + currentEbook.image);
                }
                updateData.image = req.files.image[0].filename;
            }

            // Handle pdf file update
            if (req.files && req.files.file) {
                if (currentEbook && currentEbook.file && fs.existsSync(userimages + currentEbook.file)) {
                    fs.unlinkSync(userimages + currentEbook.file);
                }
                updateData.file = req.files.file[0].filename;
            }

            await Ebook.findByIdAndUpdate({ _id: id }, { $set: updateData });
            res.redirect(returnUrl);
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
        const returnUrl = req.query.returnUrl || req.get('Referrer') || '/view-ebook';
        const currentEbook = await Ebook.findById(id);
        if (currentEbook) {
            if (fs.existsSync(userimages + currentEbook.image)) {
                fs.unlinkSync(userimages + currentEbook.image);
            }
            if (currentEbook.file && fs.existsSync(userimages + currentEbook.file)) {
                fs.unlinkSync(userimages + currentEbook.file);
            }
        }
        const delEbook = await Ebook.deleteOne({ _id: id });
        res.redirect(returnUrl);
    } catch (error) {
        console.log(error.message);
    }
};

// Active status
const activeStatus = async (req, res) => {
    try {
        const { id } = req.params;
        const returnUrl = req.body.returnUrl || req.get('Referrer') || '/view-ebook';
        const status = await Ebook.findById({ _id: id });
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

module.exports = { loadEbook, addEbook, viewEbook, editEbook, updateEbook, deleteEbook, activeStatus }; 