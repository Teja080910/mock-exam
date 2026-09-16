const fs = require('fs');
const path = require('path');
const Note = require('../models/noteModel');

const userimages = path.join('./public/assets/userImages/');

async function getNormalizedSubject(subjectInput) {
    const trimmed = (subjectInput || '').trim();
    if (!trimmed) return '';
    const existing = await Note.findOne({
        subject: { $regex: new RegExp(`^${trimmed.replace(/[-\/\\^$*+?.()|[\]{}]/g, '\\$&')}$`, 'i') }
    });
    if (existing) {
        return existing.subject;
    }
    return trimmed.replace(/\b\w/g, c => c.toUpperCase());
}

async function getNormalizedTopic(subject, topicInput) {
    const trimmed = (topicInput || '').trim();
    if (!trimmed) return '';
    const existing = await Note.findOne({
        subject: { $regex: new RegExp(`^${(subject || '').trim().replace(/[-\/\\^$*+?.()|[\]{}]/g, '\\$&')}$`, 'i') },
        topic: { $regex: new RegExp(`^${trimmed.replace(/[-\/\\^$*+?.()|[\]{}]/g, '\\$&')}$`, 'i') }
    });
    if (existing) {
        return existing.topic;
    }
    return trimmed.replace(/\b\w/g, c => c.toUpperCase());
}

// Render add note form
exports.loadNote = async (req, res) => {
    const subjects = await Note.distinct('subject');
    const topics = await Note.distinct('topic');
    res.render('addNote', { subjects, topics });
};

// Add note
exports.addNote = async (req, res) => {
    try {
        const { title, subject, topic, description } = req.body;
        const normalizedSubject = await getNormalizedSubject(subject);
        const normalizedTopic = await getNormalizedTopic(normalizedSubject, topic);
        const image = req.files && req.files.image ? req.files.image[0].filename : '';
        const file = req.files && req.files.file ? req.files.file[0].filename : '';
        const note = new Note({
            title: title.trim(),
            subject: normalizedSubject,
            topic: normalizedTopic,
            description: description || '',
            image,
            file,
            is_active: 1
        });
        await note.save();
        res.redirect('/view-notes');
    } catch (error) {
        console.log(error.message);
        const subjects = await Note.distinct('subject');
        const topics = await Note.distinct('topic');
        res.render('addNote', { subjects, topics, message: 'Error adding note.' });
    }
};

// List notes
exports.viewNotes = async (req, res) => {
    const page = Math.max(1, parseInt(req.query.page, 10) || 1);
    const limit = 20;
    const filter = {};

    if (req.query.subject) {
        filter.subject = { $regex: new RegExp(`^${req.query.subject.trim()}$`, 'i') };
    }
    if (req.query.topic) {
        filter.topic = { $regex: req.query.topic, $options: 'i' };
    }
    if (req.query.is_active !== undefined && req.query.is_active !== '') {
        filter.is_active = parseInt(req.query.is_active, 10);
    }
    if (req.query.search) {
        const term = req.query.search;
        filter.$or = [
            { title: { $regex: term, $options: 'i' } },
            { subject: { $regex: term, $options: 'i' } },
            { topic: { $regex: term, $options: 'i' } }
        ];
    }

    const totalItems = await Note.countDocuments(filter);
    const totalPages = Math.max(1, Math.ceil(totalItems / limit));

    const notes = await Note.find(filter)
        .sort({ updatedAt: -1 })
        .skip((page - 1) * limit)
        .limit(limit);

    const subjects = await Note.distinct('subject');

    const params = [];
    if (req.query.subject) params.push(`subject=${encodeURIComponent(req.query.subject)}`);
    if (req.query.topic) params.push(`topic=${encodeURIComponent(req.query.topic)}`);
    if (req.query.is_active !== undefined && req.query.is_active !== '') params.push(`is_active=${encodeURIComponent(req.query.is_active)}`);
    if (req.query.search) params.push(`search=${encodeURIComponent(req.query.search)}`);
    const extraParams = params.length > 0 ? '&' + params.join('&') : '';

    res.render('viewNotes', {
        notes,
        subjects,
        currentPage: page,
        totalPages,
        totalItems,
        limit,
        extraParams,
        filters: {
            subject: req.query.subject || '',
            topic: req.query.topic || '',
            is_active: req.query.is_active !== undefined ? req.query.is_active : '',
            search: req.query.search || ''
        }
    });
};

// Render edit note form
exports.editNote = async (req, res) => {
    const returnUrl = req.query.returnUrl || req.get('Referrer') || '/view-notes';
    const note = await Note.findById(req.query.id);
    const subjects = await Note.distinct('subject');
    const topics = await Note.distinct('topic');
    res.render('editNote', { note, subjects, topics, returnUrl: returnUrl });
};

// Update note
exports.updateNote = async (req, res) => {
    const returnUrl = req.body.returnUrl || req.query.returnUrl || '/view-notes';
    try {
        const { id, title, subject, topic, description } = req.body;
        const normalizedSubject = await getNormalizedSubject(subject);
        const normalizedTopic = await getNormalizedTopic(normalizedSubject, topic);
        const updateData = {
            title: title.trim(),
            subject: normalizedSubject,
            topic: normalizedTopic,
            description: description || ''
        };
        const existing = await Note.findById(id);
        if (req.files && req.files.image) {
            if (existing && existing.image) {
                const oldPath = path.join(userimages, existing.image);
                if (fs.existsSync(oldPath)) fs.unlinkSync(oldPath);
            }
            updateData.image = req.files.image[0].filename;
        }
        if (req.files && req.files.file) {
            if (existing && existing.file) {
                const oldPath = path.join(userimages, existing.file);
                if (fs.existsSync(oldPath)) fs.unlinkSync(oldPath);
            }
            updateData.file = req.files.file[0].filename;
        }
        await Note.findByIdAndUpdate(id, updateData);
        res.redirect(returnUrl);
    } catch (error) {
        console.log(error.message);
        const note = await Note.findById(req.body.id);
        const subjects = await Note.distinct('subject');
        const topics = await Note.distinct('topic');
        res.render('editNote', { note, subjects, topics, returnUrl: returnUrl, message: 'Error updating note.' });
    }
};

// Delete note
exports.deleteNote = async (req, res) => {
    try {
        const returnUrl = req.query.returnUrl || req.get('Referrer') || '/view-notes';
        const note = await Note.findById(req.query.id);
        if (note) {
            if (note.image) {
                const imgPath = path.join(userimages, note.image);
                if (fs.existsSync(imgPath)) fs.unlinkSync(imgPath);
            }
            if (note.file) {
                const filePath = path.join(userimages, note.file);
                if (fs.existsSync(filePath)) fs.unlinkSync(filePath);
            }
        }
        await Note.findByIdAndDelete(req.query.id);
        res.redirect(returnUrl);
    } catch (error) {
        console.log(error.message);
        res.redirect('/view-notes');
    }
};

// Toggle active status
exports.activeStatus = async (req, res) => {
    try {
        const note = await Note.findById(req.params.id);
        if (!note) return res.status(404).json({ success: 0, message: 'Note not found' });
        note.is_active = note.is_active === 1 ? 0 : 1;
        await note.save();
        res.json({ success: 1, message: 'Status updated', is_active: note.is_active });
    } catch (error) {
        res.status(500).json({ success: 0, message: 'Server error' });
    }
};
