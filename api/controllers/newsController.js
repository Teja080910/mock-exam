const { verifyAdminAccess } = require('../config/verification');
const News = require('../models/newsModel');
const Admin = require('../models/adminModel');

// Load Add News Form
const loadNews = async (req, res) => {
    try {
        res.render('addNews');
    } catch (error) {
        console.log(error.message);
    }
};

// Add News
const addNews = async (req, res) => {
    try {
        let loginData = await Admin.findById({ _id: req.session.user_id });
        if (loginData.is_admin == 1) {
            const newsData = new News({
                title: req.body.title,
                post_type: req.body.post_type,
                category: req.body.category || 'General',
                short_description: req.body.short_description,
                description: req.body.short_description,
                image: req.file ? req.file.filename : '',
                link: req.body.link,
                is_active: req.body.is_active == "on" ? 1 : 0
            });
            const saveNews = await newsData.save();
            res.redirect('/view-news');
        } else {
            req.flash('error', 'You have no access to add News, You are not super admin !! *');
            return res.redirect('back');
        }
    } catch (error) {
        console.log(error.message);
    }
};

// View News
const viewNews = async (req, res) => {
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
            if (req.query.post_type && req.query.post_type.trim() !== '') {
                filter.post_type = req.query.post_type.trim();
            }
            if (req.query.search && String(req.query.search).trim() !== '') {
                const term = String(req.query.search).trim().replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
                filter.$or = [
                    { title: { $regex: term, $options: 'i' } },
                    { short_description: { $regex: term, $options: 'i' } },
                    { description: { $regex: term, $options: 'i' } }
                ];
            }

            const totalItems = await News.countDocuments(filter);
            const totalPages = Math.max(1, Math.ceil(totalItems / limit));
            const newsData = await News.find(filter).sort({ updatedAt: -1 }).skip(skip).limit(limit);

            const params = [];
            if (req.query.is_active !== undefined && req.query.is_active !== '') params.push(`is_active=${encodeURIComponent(req.query.is_active)}`);
            if (req.query.post_type) params.push(`post_type=${encodeURIComponent(req.query.post_type)}`);
            if (req.query.search) params.push(`search=${encodeURIComponent(req.query.search)}`);
            const extraParams = params.length > 0 ? '&' + params.join('&') : '';

            res.render('viewNews', {
                news: newsData,
                loginData: loginData,
                currentPage: page,
                totalPages: totalPages,
                totalItems: totalItems,
                limit: limit,
                extraParams: extraParams,
                filters: {
                    is_active: req.query.is_active !== undefined ? req.query.is_active : '',
                    post_type: req.query.post_type || '',
                    search: req.query.search || ''
                }
            });
        });
    } catch (error) {
        console.log(error.message);
    }
};

// Edit News
const editNews = async (req, res) => {
    try {
        const id = req.query.id;
        const returnUrl = req.query.returnUrl || req.get('Referrer') || '/view-news';
        const editData = await News.findById({ _id: id });
        if (editData) {
            res.render('editNews', { editnews: editData, returnUrl: returnUrl });
        } else {
            res.render('editNews', { message: 'News Not Found', returnUrl: returnUrl });
        }
    } catch (error) {
        console.log(error.message);
    }
};

// Update News
const updateNews = async (req, res) => {
    try {
        let loginData = await Admin.findById({ _id: req.session.user_id });
        if (loginData.is_admin == 1) {
            const id = req.body.id;
            const returnUrl = req.body.returnUrl || req.query.returnUrl || '/view-news';
            const updateData = {
                title: req.body.title,
                post_type: req.body.post_type,
                category: req.body.category || 'General',
                short_description: req.body.short_description,
                description: req.body.short_description,
                link: req.body.link,
                is_active: req.body.is_active == "on" ? 1 : 0
            };
            if (req.file) {
                updateData.image = req.file.filename;
            }
            await News.findByIdAndUpdate({ _id: id }, { $set: updateData });
            res.redirect(returnUrl);
        } else {
            req.flash('error', 'You have no access to edit news, You are not super admin !! *');
            return res.redirect('back');
        }
    } catch (error) {
        console.log(error.message);
    }
};

// Delete News
const deleteNews = async (req, res) => {
    try {
        const id = req.query.id;
        const returnUrl = req.query.returnUrl || req.get('Referrer') || '/view-news';
        await News.deleteOne({ _id: id });
        res.redirect(returnUrl);
    } catch (error) {
        console.log(error.message);
    }
};

// Active status
const activeStatus = async (req, res) => {
    try {
        const { id } = req.params;
        const returnUrl = req.body.returnUrl || req.get('Referrer') || '/view-news';
        const status = await News.findById({ _id: id });
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

module.exports = { loadNews, addNews, viewNews, editNews, updateNews, deleteNews, activeStatus };
