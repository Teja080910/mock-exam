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
        let loginData = await Admin.findById({ _id: req.session.user_id });
        const page = parseInt(req.query.page) || 1;
        const limit = 20;
        const skip = (page - 1) * limit;
        const totalItems = await News.countDocuments();
        const totalPages = Math.ceil(totalItems / limit);
        const newsData = await News.find().sort({ updatedAt: -1 }).skip(skip).limit(limit);
        res.render('viewNews', { news: newsData, loginData: loginData, currentPage: page, totalPages: totalPages, totalItems: totalItems, limit: limit });
    } catch (error) {
        console.log(error.message);
    }
};

// Edit News
const editNews = async (req, res) => {
    try {
        const id = req.query.id;
        const editData = await News.findById({ _id: id });
        if (editData) {
            res.render('editNews', { editnews: editData });
        } else {
            res.render('editNews', { message: 'News Not Found' });
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
            res.redirect('/view-news');
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
        await News.deleteOne({ _id: id });
        res.redirect('/view-news');
    } catch (error) {
        console.log(error.message);
    }
};

// Active status
const activeStatus = async (req, res) => {
    try {
        const { id } = req.params;
        const status = await News.findById({ _id: id });
        if (!status) {
            return res.sendStatus(404);
        }
        status.is_active = !status.is_active;
        await status.save();
        res.redirect('/view-news');
    } catch (err) {
        console.error(err);
        res.sendStatus(500);
    }
};

module.exports = { loadNews, addNews, viewNews, editNews, updateNews, deleteNews, activeStatus };
