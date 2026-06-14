require('dotenv').config();
const mongoose = require('mongoose');
const sha256 = require('sha256');
const Admin = require('../models/adminModel');

// Connect to MongoDB
mongoose.connect(process.env.DB_CONNECTION)
.then(() => console.log('Connected to MongoDB'))
.catch(err => console.error('Could not connect to MongoDB:', err));

// Admin user data
const adminData = {
    username: 'admin',
    email: 'admin@example.com',
    password: sha256.x2('admin123'), // This will create password: admin123
    phone: '1234567890',
    image: 'default.png',
    is_admin: 1
};

// Create admin user
async function createAdmin() {
    try {
        // Check if admin already exists
        const existingAdmin = await Admin.findOne({ email: adminData.email });
        if (existingAdmin) {
            console.log('Admin user already exists!');
            process.exit(0);
        }

        // Create new admin
        const admin = new Admin(adminData);
        await admin.save();
        console.log('Admin user created successfully!');
        console.log('Email:', adminData.email);
        console.log('Password: admin123');
    } catch (error) {
        console.error('Error creating admin:', error);
    } finally {
        mongoose.connection.close();
    }
}

createAdmin(); 