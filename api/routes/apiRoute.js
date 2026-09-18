const express = require("express");
const api_route = express.Router();
const apiController = require("../controllers/apiController");
const path = require("path");
const passportJwt = require("../config/passport");
const passport = require("passport");
const jwt = require("jsonwebtoken");
const NodeCache = require("node-cache");
const Ebook = require("../models/ebookModel");
const CarouselBanner = require("../models/carouselBannerModel");
const googleAuthController = require("../controllers/googleAuthController");
const Subcategory = require("../models/subcategoryModel");
const News = require("../models/newsModel");
const Note = require("../models/noteModel");
// Multer for file uploads
const multer = require("multer");

const AuthMiddleware = require("../middleware/userMiddleware");

const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, path.join(__dirname, "../public/assets/userImages"));
  },
  filename: function (req, file, cb) {
    const name = Date.now() + "-" + file.originalname;
    cb(null, name);
  },
});

const upload = multer({ storage: storage });

// razorpay buy plan
api_route.post("/buyPlan", AuthMiddleware, apiController.buyPlan);
api_route.post("/verifyPayment", AuthMiddleware, apiController.verifyPayment);
api_route.get("/fetchUserPlan", AuthMiddleware, apiController.fetchUserPlan);
api_route.get("/getReferralInfo", AuthMiddleware, apiController.getReferralInfo);
api_route.post("/saveUpiId", AuthMiddleware, apiController.saveUpiId);
api_route.get("/getReferralCashbacks", AuthMiddleware, apiController.getReferralCashbacks);
api_route.post("/applyReferralCode", AuthMiddleware, apiController.applyReferralCode);

// Signup
api_route.post("/checkregistereduser", apiController.CheckRegisteredUser);
api_route.post("/usersignup", apiController.Signup);
api_route.post("/signupotp", apiController.GetUserOTP);
api_route.post("/userverification", apiController.UserVerification);

// Signin
api_route.post("/usersignin", apiController.SignIn);
api_route.post("/isVerifyAccount", apiController.isVerifyAccount);
api_route.post("/resendOtp", apiController.resendOtp);

// Forgot Password
api_route.post("/userforgotpassword", apiController.ForgotPassword);
api_route.post("/forgotpasswordotp", apiController.GetForgotPasswordOTP);
api_route.post(
  "/userforgotpasswordverification",
  apiController.ForgotPasswordVerification,
);
api_route.post("/userresetpassword", apiController.ChangePassword);

// Edit User Profile
api_route.post("/getuser", apiController.GetUser);
api_route.post(
  "/usereditprofile",
  upload.single("image"),
  apiController.EditUser,
);

// Upload Image
api_route.post(
  "/uploadimage",
  upload.single("image"),
  apiController.UploadImage,
);

// Intro
api_route.post("/getintro", apiController.GetIntro);

// Banner
api_route.post("/getallbanner", apiController.GetBanner);

// Category
api_route.post("/getallcategories", apiController.GetCategories);

// Quizzes
api_route.post("/getallquizzes", apiController.GetQuizzes);

// Quiz By Category
api_route.post("/getquizbycategory", apiController.GetQuizByCategory);

// Questions
api_route.post("/getallquestions", apiController.GetQuestions);
api_route.post("/getquestionsbyquizid", apiController.GetQuestionsByQuizId);
api_route.get("/download-quiz-pdf/:quizId", apiController.DownloadQuizPdf);
api_route.get("/quiz-pdf/:quizId", apiController.DownloadQuizPdf);
api_route.post(
  "/getquestionsbycategoryid",
  apiController.GetQuestionsByCategoryId,
);

// Favourite Quiz
api_route.post("/addfavouritequiz", apiController.AddFavouriteQuiz);
api_route.post("/getfavouritequiz", apiController.GetFavouriteQuiz);
api_route.post("/removefavouritequiz", apiController.RemoveFavouriteQuiz);

//Self Challange Quiz
api_route.post("/selfchallangequiz", apiController.AddSelfChallangeQuiz);

// FeaturedCategory
api_route.post("/getfeaturedcategory", apiController.GetFeaturedCategory);

// Ads Settings
api_route.post("/getadssettings", apiController.GetAdsSettings);

// Points Setting
api_route.post("/getpointssetting", apiController.GetPointsSetting);

// Points Plan
api_route.get("/get_plan", apiController.GetPlans);
// api_route.post('/buy_plan', apiController.BuyPlan);
// api_route.post('/plan_history', apiController.PlanHistory);

// User Quiz
api_route.post("/startquiz", apiController.StartQuiz);
api_route.post("/quizhistory", apiController.QuizHistory);
api_route.post("/addPoints", apiController.AddPoints);
api_route.post("/getPoints", apiController.GetPoints);

//LeaderBoard
api_route.post("/leaderboard", apiController.LeaderBoard);
api_route.post("/getuserrank", apiController.GetUserRank);

// Pages
api_route.post("/pages", apiController.getPages);

// Notification
api_route.post("/notifications", apiController.GetNotifications);

// Get All Ebooks
api_route.post("/getallebooks", async (req, res) => {
  try {
    const ebooks = await Ebook.find({ is_active: 1 }).sort({ updatedAt: -1 });
    const ebooksWithUrls = ebooks.map((ebook) => ({
      ...ebook.toObject(),
      imageUrl: `/assets/userImages/${ebook.image}`,
    }));
    res.json({
      data: {
        success: 1,
        message: "Ebooks retrieved successfully.",
        error: 0,
        ebooks: ebooksWithUrls,
      },
    });
  } catch (error) {
    console.log(error.message);
    res.json({
      data: { success: 0, message: "Error retrieving ebooks.", error: 1 },
    });
  }
});

// Get All Carousel Banners
api_route.post("/getcarouselbanners", async (req, res) => {
  try {
    const banners = await CarouselBanner.find({ is_active: 1 }).sort({
      order: 1,
      updatedAt: -1,
    });
    const bannersWithUrls = banners.map((banner) => ({
      ...banner.toObject(),
      imageUrl: `/assets/userImages/${banner.image}`,
    }));
    res.json({
      data: {
        success: 1,
        message: "Banners retrieved successfully.",
        error: 0,
        banners: bannersWithUrls,
      },
    });
  } catch (error) {
    console.log(error.message);
    res.json({
      data: { success: 0, message: "Error retrieving banners.", error: 1 },
    });
  }
});

// Google Sign-In route
api_route.post("/google-signin", (req, res, next) => {
  googleAuthController.googleSignIn(req, res);
});

// Get Subcategories by Category (public, no auth)
api_route.get("/subcategories", async (req, res) => {
  try {
    const { categoryId } = req.query;
    console.log("Subcategories request received for categoryId:", categoryId);
    if (!categoryId) {
      console.log("No categoryId provided");
      return res.status(400).json([]);
    }
    const subcategories = await require("../models/subcategoryModel").find({
      categoryId,
      is_active: 1,
    });
    console.log("Found subcategories:", subcategories.length);
    console.log("Subcategories:", subcategories);
    res.json(subcategories);
  } catch (err) {
    console.log("Error in subcategories endpoint:", err);
    res.status(500).json([]);
  }
});

// Get Quiz by Subcategory
api_route.post("/getquizbysubcategory", (req, res, next) => {
  apiController.GetQuizBySubcategory(req, res, next);
});

// Get Category Groups
api_route.get("/category-groups", apiController.getCategoryGroups);

// Get All News
api_route.post("/getallnews", async (req, res) => {
  try {
    const news = await News.find({ is_active: 1 }).sort({ createdAt: -1 });
    const newsData = news.map((item) => ({
      _id: item._id,
      title: item.title,
      post_type: item.post_type || 'notification',
      category: item.category || '',
      short_description: item.short_description || item.description || '',
      description: item.description || '',
      image: item.image || '',
      link: item.link || "",
      createdAt: item.createdAt,
    }));
    res.json({
      data: {
        success: 1,
        message: "News retrieved successfully.",
        error: 0,
        news: newsData,
      },
    });
  } catch (error) {
    console.log(error.message);
    res.json({
      data: { success: 0, message: "Error retrieving news.", error: 1 },
    });
  }
});

// Get all note subjects (grouped case-insensitively)
api_route.post("/getnotesubjects", async (req, res) => {
  try {
    const subjects = await Note.aggregate([
      { $match: { is_active: 1 } },
      { 
        $group: { 
          _id: { $toLower: { $trim: { input: "$subject" } } },
          subjectName: { $first: "$subject" },
          topics: { $addToSet: { $toLower: { $trim: { input: "$topic" } } } },
          image: { $first: "$image" }
        } 
      },
      {
        $project: {
          _id: 0,
          subject: "$subjectName",
          topicCount: { $size: "$topics" },
          image: { $ifNull: ["$image", ""] }
        }
      },
      { $sort: { subject: 1 } }
    ]);
    res.json({ data: { success: 1, message: "Subjects retrieved.", error: 0, subjects } });
  } catch (error) {
    console.log(error.message);
    res.json({ data: { success: 0, message: "Error retrieving subjects.", error: 1, subjects: [] } });
  }
});

// Get topics for a subject (case-insensitive match)
api_route.post("/getnotetopics", async (req, res) => {
  try {
    const { subject } = req.body;
    const matchFilter = { is_active: 1 };
    if (subject && subject.trim()) {
      matchFilter.subject = { $regex: new RegExp(`^${subject.trim()}$`, 'i') };
    }
    const topics = await Note.aggregate([
      { $match: matchFilter },
      { 
        $group: { 
          _id: { $toLower: { $trim: { input: "$topic" } } },
          topicName: { $first: "$topic" },
          noteCount: { $sum: 1 }, 
          image: { $first: "$image" } 
        } 
      },
      {
        $project: {
          _id: 0,
          topic: "$topicName",
          noteCount: "$noteCount",
          image: { $ifNull: ["$image", ""] }
        }
      },
      { $sort: { topic: 1 } }
    ]);
    res.json({ data: { success: 1, message: "Topics retrieved.", error: 0, topics } });
  } catch (error) {
    console.log(error.message);
    res.json({ data: { success: 0, message: "Error retrieving topics.", error: 1, topics: [] } });
  }
});

// Get notes for a topic (case-insensitive match)
api_route.post("/getnotes", async (req, res) => {
  try {
    const { subject, topic } = req.body;
    const filter = { is_active: 1 };
    if (subject && subject.trim()) {
      filter.subject = { $regex: new RegExp(`^${subject.trim()}$`, 'i') };
    }
    if (topic && topic.trim()) {
      filter.topic = { $regex: new RegExp(`^${topic.trim()}$`, 'i') };
    }
    const notes = await Note.find(filter).sort({ updatedAt: -1 });
    const notesData = notes.map(n => ({
      _id: n._id,
      title: n.title,
      subject: n.subject,
      topic: n.topic,
      description: n.description || '',
      image: n.image || '',
      file: n.file || '',
      createdAt: n.createdAt
    }));
    res.json({ data: { success: 1, message: "Notes retrieved.", error: 0, notes: notesData } });
  } catch (error) {
    console.log(error.message);
    res.json({ data: { success: 0, message: "Error retrieving notes.", error: 1, notes: [] } });
  }
});

module.exports = api_route;
