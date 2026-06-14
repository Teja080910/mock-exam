/*************************************************************************
 * app.js
 * This is the main file of the project
 * This file is responsible for starting the server
 * and connecting to the database
 * It also contains the routes for the project
 * It also contains the session and passport configuration
 * It also contains the flash middleware
 * It also contains the static files configuration
 *************************************************************************/

// Load the environment variables
require('dotenv').config();

// Load the mongoose module
var mongoose = require('mongoose');
const db = require('./config/mongoose');
const MongoStore = require("connect-mongo");

require("./Cron/planCron")
// Load the passport module
const passport = require('passport');
const flash = require("connect-flash");
const flashmiddleware = require('./config/flash');

// Load the express module
const express = require("express");
const cors = require("cors");
const bodyParser = require("body-parser");
const app = express();
const http = require('http').Server(app);

// Parse JSON and urlencoded bodies (must be before routes)
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Load the express-session module
const session = require('express-session');
app.use(session({secret:process.env.SESSION_SECREAT,resave: false,saveUninitialized: true,rolling: true, cookie: {maxAge: 24 * 60 * 60 * 1000},
    store: MongoStore.create({
        mongoUrl: process.env.DB_CONNECTION, 
        ttl: 3600,
    }),}));

// Setting the session and passport configuration
app.use(passport.initialize());
app.use(passport.session());

app.use(flash())
app.use(flashmiddleware.setflash);

// Load The Public Directory
const path = require("path");
app.use(express.static(path.join(__dirname, 'public')));

// Enable CORS for all routes
app.use(cors({
  origin: '*', // Update this to your client's origin
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'Accept'],
  maxAge: 86400 // 24 hours
}));

// Setting the API routes
const apiRoute = require("./routes/apiRoute");
app.use('/api', apiRoute);

// Setting the Admin routes
const adminRoute = require('./routes/adminRoute');
app.use('/',adminRoute);


// Increase payload size limit
app.use(bodyParser.json({ limit: '10mb' }));
app.use(bodyParser.urlencoded({ extended: true, limit: '10mb' }));

// Error handling middleware
app.use((err, req, res, next) => {
  console.error('Error:', err);
  console.error('Request body:', req.body);
  console.error('Request headers:', req.headers);
  res.status(500).json({
    success: 0,
    message: 'Something went wrong!',
    error: 1,
    details: err.message
  });
});

// Setting the server port
const PORT = process.env.PORT || 6900;
app.listen(PORT, '0.0.0.0', () => {
  console.log(`Server is running on port ${PORT}`);
  console.log(`Server is accessible at http://localhost:${PORT} and http://192.168.1.41:${PORT}`);
});