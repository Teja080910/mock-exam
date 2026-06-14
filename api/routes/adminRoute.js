// Load Environment Variables
require('dotenv').config();

// Express for routing
const express = require("express");
const admin_route = express();

// Body Parser for form data
const bodyParser = require('body-parser');
admin_route.use(bodyParser.json());
admin_route.use(bodyParser.urlencoded({ extended: true }));

// EJS and Static Files
const path = require('path');
admin_route.set('view engine', 'ejs');
admin_route.set('views', [path.join('./', '/views/admin/'), path.join('./', '/views/layout/')]);
admin_route.use(express.static('public'));

// Sanitize filename function
const sanitizeFilename = (filename) => {
  const ext = path.extname(filename);
  const baseName = path.basename(filename, ext);
  const sanitizedBaseName = baseName.replace(/[^a-z0-9-_]/gi, '_').toLowerCase();
  return `${sanitizedBaseName}${ext}`;
};

// Multer for file uploads
const multer = require("multer");
const storage = multer.diskStorage({
    destination: function (req, file, cb) {
      cb(null, path.join(__dirname, '../public/assets/userImages'));
    },
    filename: function (req, file, cb) {
      const originalName = sanitizeFilename(file.originalname);
      const name = Date.now() + '-' + originalName;
      cb(null, name);
    }
  });

const upload = multer({ storage: storage });
const auth = require("../middleware/auth");

// Controllers
const adminController = require("../controllers/adminController");
const BannerController = require("../controllers/bannerController");
const IntroController = require("../controllers/introController");
const CurrencyController = require("../controllers/currencyController");
const CategoryController = require("../controllers/categoryController");
const QuizController = require("../controllers/quizController");
const QuestionsController = require("../controllers/questionsController");
const PlanController = require("../controllers/planController");
const PaymentMethodController = require("../controllers/paymentMethodController");
const AdsController = require("../controllers/adsController");
const SettingController = require("../controllers/settingController");
const notificationController = require("../controllers/notificationController");
const smtpController = require("../controllers/smtpController");
const EbookController = require("../controllers/ebookController");
const CarouselBannerController = require('../controllers/carouselBannerController');
const SubcategoryController = CategoryController;
const categoryGroupController = require('../controllers/categoryGroupController');

// Login
admin_route.get('/', adminController.loginLoad);
admin_route.get('/login', adminController.loginLoad);
admin_route.post('/login', adminController.login);

// Dashboard, Profile 
admin_route.get('/dashboard', adminController.dashboardLoad);
admin_route.get('/edit-profile', adminController.adminProfile);
admin_route.post('/edit-profile', upload.single('image'), adminController.editProfile);
admin_route.get('/change-password', adminController.changePassword);
admin_route.post('/change-password', adminController.resetAdminPassword);
admin_route.get('/currency', CurrencyController.currency);
admin_route.post('/currency', CurrencyController.currencydata);
admin_route.get('/view-users', adminController.viewUsers);
admin_route.post('/view-users/:id/toggle', adminController.userStatus);
admin_route.get('/logout', adminController.adminLogout);

// Intro
admin_route.get('/add-intro', IntroController.loadIntro);
admin_route.post('/add-intro', upload.single('image'), IntroController.addIntro);
admin_route.get('/view-intro', IntroController.viewIntro);
admin_route.post('/intro-is-active/:id/toggle', IntroController.activeStatus);
admin_route.get('/edit-intro', IntroController.editIntro);
admin_route.post('/edit-intro', upload.single('image'), IntroController.UpdateIntro);
admin_route.get('/delete-intro', IntroController.deleteIntro);

// Banner
admin_route.get('/add-banner', CarouselBannerController.loadBanner);
admin_route.post('/add-banner', upload.single('image'), CarouselBannerController.addBanner);
admin_route.get('/view-banner', CarouselBannerController.viewBanner);
admin_route.get('/edit-banner', CarouselBannerController.editBanner);
admin_route.post('/edit-banner', upload.single('image'), CarouselBannerController.updateBanner);
admin_route.get('/delete-banner', CarouselBannerController.deleteBanner);
admin_route.post('/banner-is-active/:id/toggle', CarouselBannerController.activeStatus);

// Category
admin_route.get('/add-category', CategoryController.loadCategory);
admin_route.post('/add-category', upload.single('image'), CategoryController.addcategory);
admin_route.get('/view-category', CategoryController.viewCategory);
admin_route.get('/edit-category', CategoryController.editCategory);
admin_route.post('/edit-category', upload.single('image'), CategoryController.UpdateCategory);
admin_route.post('/update-is-feature/:id/toggle', CategoryController.featureStatus);
admin_route.post('/category-is-active/:id/toggle', CategoryController.activeStatus);
admin_route.get('/delete-category', CategoryController.deleteCategory);

// Feature Category
admin_route.get('/view-featured-category', CategoryController.featuredCategory);

// Subcategory
admin_route.get('/add-subcategory', SubcategoryController.loadSubcategory);
admin_route.post('/add-subcategory', upload.single('image'), SubcategoryController.addSubcategory);
admin_route.get('/view-subcategory', SubcategoryController.viewSubcategory);
admin_route.get('/edit-subcategory', SubcategoryController.editSubcategory);
admin_route.post('/edit-subcategory', upload.single('image'), SubcategoryController.updateSubcategory);
admin_route.get('/delete-subcategory', SubcategoryController.deleteSubcategory);

// Quiz
admin_route.get('/add-quiz', QuizController.loadQuiz);
admin_route.post('/add-quiz', upload.single('image'), QuizController.addQuiz);
admin_route.get('/view-quiz', QuizController.viewQuiz);
admin_route.post('/quiz-is-active/:id/toggle', QuizController.activeStatus);
admin_route.get('/edit-quiz', QuizController.editQuiz);
admin_route.post('/edit-quiz', upload.single('image'), QuizController.UpdateQuiz);
admin_route.get('/delete-quiz', QuizController.deleteQuiz);

// Image and Audio Upload
var cpUpload = upload.fields([
  { name: 'image', maxCount: 1 },
  { name: 'audio', maxCount: 1 },
  { name: 'a_image', maxCount: 1 },
  { name: 'b_image', maxCount: 1 },
  { name: 'c_image', maxCount: 1 },
  { name: 'd_image', maxCount: 1 }
]);

// Questions
admin_route.get('/add-questions', QuestionsController.loadQuestions);
admin_route.post('/add-questions', cpUpload, QuestionsController.addQuestions);
admin_route.post('/import-questions-csv', upload.single('csv'), QuestionsController.importQuestionsCSV);
admin_route.get('/csv-format', QuestionsController.sampleCSVFormat);
admin_route.get('/view-questions', QuestionsController.viewQuestions);
admin_route.post('/questions-is-active/:id/toggle', QuestionsController.activeStatus);
admin_route.get('/edit-questions', QuestionsController.editQuestions);
admin_route.post('/edit-questions', cpUpload, QuestionsController.UpdateQuestions);
admin_route.get('/delete-questions', QuestionsController.deleteQuestions);

// Plan
admin_route.get('/add-plan', PlanController.loadPlan);
admin_route.post('/add-plan', PlanController.addPlan);
admin_route.get('/view-plan', PlanController.viewPlan);
admin_route.get('/edit-plan', PlanController.editPlan);
admin_route.post('/edit-plan', PlanController.updatePlan);
admin_route.get('/delete-plan', PlanController.deletePlan);

// Payment Method
admin_route.get('/add-payment-method', PaymentMethodController.loadPayment);
admin_route.post('/add-payment-method', upload.single('image'), PaymentMethodController.addPaymentMethod);
admin_route.get('/view-payment-method', PaymentMethodController.viewPaymentMethod);
admin_route.get('/edit-payment-method', PaymentMethodController.editPaymentMethod);
admin_route.post('/edit-payment-method', upload.single('image'), PaymentMethodController.updatePaymentMethod);
admin_route.post('/update-is-enable/:id/toggle', PaymentMethodController.is_enableStatus);
admin_route.get('/delete-payment-method', PaymentMethodController.deletePaymentMethod);

// Ads Settings
admin_route.get('/ads-settings', AdsController.loadAds);
admin_route.post('/ads-settings', AdsController.addAdsSetting);

// Settings
admin_route.get('/setting', SettingController.loadSetting);
admin_route.post('/setting', SettingController.addSetting);

// Notifications
admin_route.get('/add-notification', notificationController.loadNotification);
admin_route.post('/add-notification', notificationController.addNotification);

// SMTP Settings
admin_route.get('/smtp-settings', smtpController.smtpLoad);
admin_route.post('/smtp-settings', smtpController.setSMTP);

// Page Route
const PageController = require("../controllers/pageController");
admin_route.get('/pages', PageController.pageLoad);
admin_route.post('/pages', PageController.addPages);

// Media Route
const MediaController = require("../controllers/mediaController");
admin_route.get('/upload-media', MediaController.loadMedia);
admin_route.post('/upload-media', upload.any(), MediaController.addMedia);
admin_route.get('/view-media', MediaController.viewMedia);
admin_route.get('/delete-media', MediaController.deleteMedia);

// Verify Key
admin_route.get('/verification', SettingController.loadVerification);
admin_route.post('/verification', SettingController.keyVerification);
admin_route.post('/revoke', SettingController.revokeKey);

// Ebook Routes
admin_route.get('/add-ebook', EbookController.loadEbook);
admin_route.post('/add-ebook', upload.fields([
    { name: 'image', maxCount: 1 }
]), EbookController.addEbook);
admin_route.get('/view-ebook', EbookController.viewEbook);
admin_route.get('/edit-ebook', EbookController.editEbook);
admin_route.post('/edit-ebook', upload.fields([
    { name: 'image', maxCount: 1 }
]), EbookController.updateEbook);
admin_route.get('/delete-ebook', EbookController.deleteEbook);
admin_route.post('/ebook-is-active/:id/toggle', EbookController.activeStatus);

// Category Group
admin_route.get('/add-category-group', categoryGroupController.loadAddGroup);
admin_route.post('/add-category-group', categoryGroupController.addGroup);
admin_route.get('/edit-category-group', categoryGroupController.loadEditGroup);
admin_route.post('/edit-category-group', categoryGroupController.updateGroup);
admin_route.get('/view-category-groups', categoryGroupController.viewGroups);
admin_route.get('/delete-category-group', categoryGroupController.deleteGroup);

admin_route.get('*', function (req, res) {
  res.redirect('/');
});

module.exports = admin_route;