require("dotenv").config();
const nodemailer = require("nodemailer");
const otpgenerator = require("otp-generator");
const sha256 = require("sha256");
const jwt = require("jsonwebtoken");
//const hbs = require('nodemailer-express-handlebars');
const path = require("path");
const sendinBlue = require("sendinblue-api");
var randomstring = require("randomstring");
const { generateUniqueReferralCode, ensureReferralCode } = require("../utils/referralHelper");
const User = require("../models/userModel");
const UserOTP = require("../models/userOtpModel");
const PasswordOTP = require("../models/passwordOTPModel");
const Setting = require("../models/settingModel");
const Points = require("../models/pointsModel");
const Category = require("../models/categoryModel");
const Quiz = require("../models/quizModel");
const Questions = require("../models/questionsModel");
const Ads = require("../models/adsModel");
const UserQuiz = require("../models/userQuizModel");
const Notification = require("../models/notificationModel");
const CommonNotification = require("../models/commonNotificationModel");
const NodeCache = require("node-cache");
const nodeCache = new NodeCache();
const FavouriteQuiz = require("../models/favouriteQuizModel");
const { create } = require("connect-mongo");
const Banner = require("../models/bannerModel");
const Intro = require("../models/introModel");
const Plan = require("../models/planModel");
const UserPlan = require("../models/userPlanModel");
const Page = require("../models/pagesModel");
const ReferralCashback = require("../models/referralCashbackModel");
const admin = require("../config/firebase");
const SMTP = require("../models/smtpModel");
const CategoryGroup = require("../models/categoryGroupModel");

const normalizeQuizDescription = (desc) => {
  if (!desc) return "";
  const strip = (s) => String(s || "").replace(/<p><br><\/p>/g, "");
  if (typeof desc === "object") {
    return {
      en: strip(desc.en),
      hi: strip(desc.hi),
    };
  }
  return strip(desc);
};

// Firebase Push Notification
function sendPushNotification(registrationToken, title, body) {
  const message = {
    notification: {
      title: title,
      body: body,
    },
    token: registrationToken,
  };

  // Send the message to the device corresponding to the provided registration token
  admin
    .messaging()
    .send(message)
    .then((response) => {
      // Response is a message ID string.
      console.log("Successfully sent message:", response);
    })
    .catch((error) => {
      console.log("Error sending message:", error);
    });
}

// Check if user is already registered
const CheckRegisteredUser = async (req, res) => {
  try {
    const emailExist = await User.findOne({ email: req.body.email });

    if (emailExist) {
      return res.json({
        data: { success: 1, message: "User Already Registered.", error: 0 },
      });
    } else {
      return res.json({
        data: { success: 0, message: "Please Signup..!!", error: 1 },
      });
    }
  } catch (error) {
    console.log(error.message);
  }
};

// Send OTP to user's email
// const SendOTP = async (name, email, OTP) => {
//     try {
//         const transporter = nodemailer.createTransport({
//             host: 'smtp-relay.sendinblue.com',
//             port: 587,
//             secure: false,
//             requireTLS: true,
//             auth: {
//                 user: 'jognmartin84@gmail.com',
//             }
//         });
//         const mailoptions = {
//             from: "jognmartin84@gmail.com",
//             to: email,
//             subject: 'User Registration Verification',
//             html: "Hello <strong>" + name + "</strong> !! Here is your OTP <strong>" + OTP + "</strong>"
//         }
//         transporter.sendMail(mailoptions, function (error, info) {
//             if (error) {
//                 console.warn(error);
//             }
//             else {
//                 console.log("message has been sent", info.response);

//             }
//         })

//     } catch (error) {
//         console.warn(error);
//     }
// }

const SendOTP = async (name, email, OTP) => {
  try {
    // Fetch SMTP configuration
    const smtp = await SMTP.findOne({});
    // Configure the transporter
    const transporter = nodemailer.createTransport({
      host: smtp.host,
      port: smtp.port,
      secure: false,
      requireTLS: true,
      tls: {
        rejectUnauthorized: false, // Disable strict SSL checking
      },
      auth: {
        user: smtp.email,
        pass: smtp.password,
      },
    });

    // handlebars
    const { default: hbs } = await import("nodemailer-express-handlebars");

    const logoUrl = "./public/assets/img/logo/quiz-logo.png";

    // Configure Handlebars options
    const handlebarOptions = {
      viewEngine: {
        partialsDir: path.resolve("./views/mail-templates/user-auth/"),
        defaultLayout: false,
      },
      viewPath: path.resolve("./views/mail-templates/user-auth/"),
    };
    transporter.use("compile", hbs(handlebarOptions));

    // Define email options
    const mailoptions = {
      from: smtp.email,
      to: email,
      template: "signupOTP", // Template file name
      subject: "Verify Your Email for Quiz App Registration",
      context: {
        imgUrl: logoUrl,
        name: name, // User's name
        OTP: OTP, // OTP code/
      },
      attachments: [
        {
          filename: "quiz-logo.png",
          path: "./public/assets/img/logo/quiz-logo.png", // Local path for attachment
          cid: "logo", // Content ID for referencing in the HTML
        },
      ],
    };

    // Send the email
    transporter.sendMail(mailoptions, function (error, info) {
      if (error) {
        console.warn(error);
      } else {
        console.log("message has been sent", info.response);
      }
    });
  } catch (error) {
    console.error("Error in SendOTP:", error);

    // Additional debug information for nodemailer issues
    if (error.response) {
      console.error("SMTP Server Response:", error.response);
    }
    if (error.code) {
      console.error("Error Code:", error.code);
    }
    return { success: false, error: error.message || "Unknown error" };
  }
};

// User Signup
const Signup = async (req, res) => {
  try {
    const pass = sha256.x2(req.body.password);

    let referralCode = await generateUniqueReferralCode();
    let referredBy = null;

    // Handle referral
    if (req.body.referralCode) {
      const referrer = await User.findOne({ referral_code: req.body.referralCode });
      if (referrer) {
        referredBy = referrer._id;
      }
    }

    const userData = new User({
      firstname: req.body.firstname,
      lastname: req.body.lastname,
      username: req.body.username,
      email: req.body.email,
      password: pass,
      referral_code: referralCode,
      referred_by: referredBy,
    });

    const emailExist = await User.findOne({ email: req.body.email });

    if (emailExist) {
      return res.json({
        data: { success: 0, message: "Email Already Exist..", error: 1 },
      });
    } else {
      const saveUser = await userData.save();

      let OTP = otpgenerator.generate(4, {
        lowerCaseAlphabets: false,
        upperCaseAlphabets: false,
        specialChars: false,
      });

      SendOTP(saveUser.firstname, saveUser.email, OTP);

      const delPastRecord = await UserOTP.deleteOne({ email: saveUser.email });

      const otpMail = await UserOTP.create({
        email: saveUser.email,
        OTP: OTP,
      });

      if (saveUser) {
        return res.json({
          data: {
            success: 1,
            message:
              "User Successfully Registered, Please Check Your Email for OTP.",
            error: 0,
          },
        });
      } else {
        return res.json({
          data: { success: 0, message: "User Not Registered..!!*", error: 1 },
        });
      }
    }
  } catch (error) {
    return res.json({ data: { success: 0, message: error, error: 1 } });
  }
};

// Get User OTP
const GetUserOTP = async (req, res) => {
  try {
    const email = req.body.email;
    const findUser = await UserOTP.findOne({ email: email });
    if (findUser) {
      return res.json({
        data: { success: 1, message: "OTP Found", OTP: findUser.OTP, error: 0 },
      });
    } else {
      return res.json({
        data: { success: 0, message: "OTP Not Found", error: 1 },
      });
    }
  } catch (error) {
    return res.json({
      data: { success: 0, message: "An error occurred", error: 1 },
    });
  }
};

// const UserVerification = async (req, res) => {
//     try {
//         const email = req.body.email;

//         const findUser = await UserOTP.findOne({ email: email });

//         if (findUser) {

//             if (findUser.OTP == req.body.otp) {

//                 const quizPoints = await Setting.findOne();

//                 const userEmail = await User.findOneAndUpdate({ email: email }, { $set: { is_verified: 1, points: quizPoints.new_user_reward_points } });

//                 const points = await Points.create({ userId: userEmail._id, points: quizPoints.new_user_reward_points, description: "Welcome Reward Points" });

//                 const DelMatched = await UserOTP.deleteOne({ email: userEmail.email });

//                 const deviceId = req.body.deviceId;

//                 let findUserDevice = await Notification.findOne({
//                     userId: userEmail._id,
//                     deviceId: deviceId
//                 });

//                 if (findUserDevice) {
//                     findUserDevice.registrationToken = req.body.registrationToken;
//                     findUserDevice.is_active = 1;
//                     await findUserDevice.save();
//                     const username = UserData.name;
//                     const registrationToken = req.body.registrationToken;
//                     const title = `Hey, ${username}`;
//                     const body = "You are SignIn Successfully...!!";

//                     sendPushNotification(registrationToken, title, body);

//                 } else {
//                     console.log("device and user not matched or no device found");
//                     const username = userEmail.name;
//                     const registrationToken = req.body.registrationToken;
//                     const title = `Hey, ${username}`;
//                     const body = "You are SignIn Successfully...!!";

//                     sendPushNotification(registrationToken, title, body);

//                     const newDevice = new Notification({
//                         userId: userEmail._id,
//                         registrationToken: registrationToken,
//                         deviceId: req.body.deviceId,
//                         is_active: 1
//                     });

//                     await newDevice.save();
//                 }

//                 const token = jwt.sign({ id: userEmail._id }, process.env.SESSION_SECREAT);

//                 return res.json({
//                     "data": {
//                         "success": 1,
//                         message: "User Successfully Verified..!!",
//                         token: token,
//                         userDetails: {
//                             id: userEmail._id,
//                             firstname: userEmail.firstname,
//                             lastname: userEmail.lastname,
//                             username: userEmail.username,
//                             email: userEmail.email,
//                             phone: userEmail.phone,
//                             active: userEmail.active,
//                             image: userEmail.image ? userEmail.image : "",
//                             points: userEmail.points
//                         },
//                         "error": "0"
//                     }
//                 });
//             }
//             else {
//                 return res.json({ "data": { "success": 0, "message": "OTP Not Matched..!!*", "error": 1 } });
//             }
//         }
//         else {
//             return res.json({ "data": { "success": 0, "message": "Email Not Found", "error": 1 } });
//         }
//     }

//     catch (error) {
//         return res.json({
//             "data": { "success": 0, "message": error, "error": 1 }
//         });
//     }
// }

const UserVerification = async (req, res) => {
  try {
    const email = req.body.email;
    const findUser = await UserOTP.findOne({ email: email });

    if (!findUser) {
      return res.json({
        data: { success: 0, message: "Email Not Found", error: 1 },
      });
    }

    if (findUser.OTP !== req.body.otp) {
      return res.json({
        data: { success: 0, message: "OTP Not Matched..!!*", error: 1 },
      });
    }

    const quizPoints = await Setting.findOne();
    const userEmail = await User.findOneAndUpdate(
      { email: email },
      { $set: { is_verified: 1, points: quizPoints.new_user_reward_points } },
      { new: true }, // Return updated document
    );

    await Points.create({
      userId: userEmail._id,
      points: quizPoints.new_user_reward_points,
      description: "Welcome Reward Points",
    });

    await UserOTP.deleteOne({ email: userEmail.email });

    // Handle device notification
    const deviceId = req.body.deviceId;
    const registrationToken = req.body.registrationToken;
    const username = userEmail.firstname; // Changed from name to firstname
    const title = `Hey, ${username}`;
    const body = "You are SignIn Successfully...!!";

    let findUserDevice = await Notification.findOne({
      user_id: userEmail._id,
      device_id: deviceId,
    });

    if (findUserDevice) {
      findUserDevice.registration_token = registrationToken;
      await findUserDevice.save();
    } else {
      await Notification.create({
        user_id: userEmail._id,
        registration_token: registrationToken,
        device_id: deviceId,
      });
    }

    // Send push notification
    sendPushNotification(registrationToken, title, body);

    const token = jwt.sign({ id: userEmail._id }, process.env.JWT_SECRET, {
      expiresIn: "7d",
    });

    return res.json({
      data: {
        success: 1,
        message: "User Successfully Verified..!!",
        token: token,
        userDetails: {
          id: userEmail._id,
          firstname: userEmail.firstname,
          lastname: userEmail.lastname,
          username: userEmail.username,
          email: userEmail.email,
          phone: userEmail.phone,
          active: userEmail.active,
          image: userEmail.image ? userEmail.image : "",
          points: userEmail.points,
        },
        error: "0",
      },
    });
  } catch (error) {
    console.error("User verification error:", error);
    return res.json({
      data: {
        success: 0,
        message: "An error occurred during verification",
        error: 1,
      },
    });
  }
};

// User SignIn
const SignIn = async (req, res) => {
  try {
    const {
      email,
      password: plainPassword,
      registrationToken,
      deviceId,
    } = req.body;
    const hashedPassword = sha256.x2(plainPassword);

    const user = await User.findOne({ email, active: "true" });

    if (!user) {
      return res.json({
        data: {
          success: 0,
          message: "Your Account is Deactivated By Admin..",
          error: 1,
        },
      });
    }

    if (user.password !== hashedPassword) {
      return res.json({
        data: {
          success: 0,
          message: "Email and Password not correct",
          error: 1,
        },
      });
    }

    let userDevice = await Notification.findOne({ user_id: user._id, device_id: deviceId });

    if (userDevice) {
      userDevice.registration_token = registrationToken;
      await userDevice.save();
    } else {
      console.log("Device and user not matched or no device found");
      await Notification.create({
        user_id: user._id,
        registration_token: registrationToken,
        device_id: deviceId,
      });
    }

    const username = user.firstname || user.username || 'User';
    const title = `Hey, ${username}`;
    const body = "You are SignIn Successfully...!!";
    sendPushNotification(registrationToken, title, body);

    const token = jwt.sign({ id: user._id }, process.env.JWT_SECRET, {
      expiresIn: "7d",
    });
    const referralCode = await ensureReferralCode(user);

    return res.json({
      data: {
        success: 1,
        message: "Successfully Logged User !!",
        token,
        userDetails: {
          id: user._id,
          firstname: user.firstname,
          lastname: user.lastname,
          username: user.username,
          email: user.email,
          countryCode: user.countryCode,
          phone: user.phone,
          active: user.active,
          image: user.image || "",
          points: user.points,
          referral_code: referralCode,
        },
        error: "0",
      },
    });
  } catch (error) {
    console.error(error);
    return res.json({
      data: {
        success: 0,
        message: "Error occurred. Please try again.",
        error: 1,
      },
    });
  }
};

// is verify account
const isVerifyAccount = async (req, res) => {
  try {
    // Extract data from the request body
    const email = req.body.email;

    // Validate email
    if (!email) {
      return res.json({
        data: { success: 0, message: "Email is required", error: 1 },
      });
    }

    // fetch user
    const existingUser = await User.findOne({ email: email });

    if (!existingUser) {
      return res.json({
        data: { success: 0, message: "User not found", error: 1 },
      });
    }

    if (!existingUser.is_verified) {
      return res.json({
        data: {
          success: 0,
          message:
            "Your account is not verified. Please verify your account...",
          error: 1,
        },
      });
    } else {
      return res.json({
        data: {
          success: 1,
          message: "Your account has been successfully verified.",
          error: 0,
        },
      });
    }
  } catch (error) {
    console.log("Error during is verify account", error.message);
    return res.json({
      data: { success: 0, message: "An error occurred", error: 1 },
    });
  }
};

// resend otp
const resendOtp = async (req, res) => {
  try {
    // Extract data from the request body
    const email = req.body.email;

    // Validate email
    if (!email) {
      return res.json({
        data: { success: 0, message: "Email is required", error: 1 },
      });
    }

    // Check if user already exists
    const existingUser = await User.findOne({ email: email });

    if (!existingUser) {
      return res.json({
        data: { success: 0, message: "User not found", error: 1 },
      });
    }

    if (existingUser.is_verified === 1) {
      return res.json({
        data: {
          success: 0,
          message: "Your account is already verified.",
          error: 1,
        },
      });
    }

    let OTP = otpgenerator.generate(4, {
      lowerCaseAlphabets: false,
      upperCaseAlphabets: false,
      specialChars: false,
    });

    // Save OTP
    const otpDoc = await UserOTP.findOneAndUpdate(
      { email: email },
      { $set: { email: email, OTP: OTP } },
      { new: true, upsert: true },
    );

    // Send OTP email
    try {
      await SendOTP(existingUser.firstname, existingUser.email, OTP);
    } catch (emailError) {
      return res.json({
        data: {
          success: 0,
          message: "Something went wrong. Please try again...",
          error: 1,
        },
      });
    }

    return res.json({
      data: {
        success: 1,
        message:
          "We've sent an OTP to your email. Please check your inbox to verify your account.",
        error: 0,
      },
    });
  } catch (error) {
    console.log("Error during resend otp", error.message);
    return res.json({
      data: { success: 0, message: "An error occurred", error: 1 },
    });
  }
};

// Forgot Password OTP
// const oldForgotPasswordOTP = async (name, email, OTP) => {
//     try {
//         const smtp = await SMTP.findOne({});
//         const transporter = nodemailer.createTransport({
//             host: smtp.host,
//             port: smtp.port,
//             secure: false,
//             requireTLS: true,
//             auth: {
//                 user: smtp.email,
//                 pass: smtp.password
//             }
//         });

//         const mailoptions = {
//             from: smtp.email,
//             to: email,
//             subject: 'Forgot Password OTP',
//             html: "Hello <strong>" + name + "</strong> !! Here is your otp <strong>" + OTP2 + "</strong>"
//         }

//         transporter.sendMail(mailoptions, function (error, info) {
//             if (error) {
//                 console.warn(error);
//             }
//             else {
//                 console.log("message has been sent", info.response);
//             }
//         });

//     } catch (error) {
//         console.warn(error);
//     }
// }

const ForgotPasswordOTP = async (name, email, OTP2) => {
  try {
    // Fetch SMTP configuration
    const smtp = await SMTP.findOne({});
    // Configure the transporter
    const transporter = nodemailer.createTransport({
      host: smtp.host,
      port: smtp.port,
      secure: false,
      requireTLS: true,
      tls: {
        rejectUnauthorized: false, // Disable strict SSL checking
      },
      auth: {
        user: smtp.email,
        pass: smtp.password,
      },
    });

    // handlebars
    const { default: hbs } = await import("nodemailer-express-handlebars");

    const logoUrl = "./public/assets/img/logo/quiz-logo.png";

    // Configure Handlebars options
    const handlebarOptions = {
      viewEngine: {
        partialsDir: path.resolve("./views/mail-templates/user-auth/"),
        defaultLayout: false,
      },
      viewPath: path.resolve("./views/mail-templates/user-auth/"),
    };
    transporter.use("compile", hbs(handlebarOptions));

    // Define email options
    const mailoptions = {
      from: smtp.email,
      to: email,
      template: "forgotPasswordOTP", // Template file name
      subject: "Verify Your Forgot Password Email for Quiz App",
      context: {
        imgUrl: logoUrl,
        name: name, // User's name
        OTP: OTP2, // OTP code/
      },
      attachments: [
        {
          filename: "quiz-logo.png",
          path: "./public/assets/img/logo/quiz-logo.png", // Local path for attachment
          cid: "logo", // Content ID for referencing in the HTML
        },
      ],
    };

    // Send the email
    transporter.sendMail(mailoptions, function (error, info) {
      if (error) {
        console.warn(error);
      } else {
        console.log("message has been sent", info.response);
      }
    });
  } catch (error) {
    console.error("Error in SendOTP:", error);

    // Additional debug information for nodemailer issues
    if (error.response) {
      console.error("SMTP Server Response:", error.response);
    }
    if (error.code) {
      console.error("Error Code:", error.code);
    }
    return { success: false, error: error.message || "Unknown error" };
  }
};

// Get Forgot Password OTP
const GetForgotPasswordOTP = async (req, res) => {
  try {
    const email = req.body.email;
    const findUser = await PasswordOTP.findOne({ email: email });
    if (findUser) {
      return res.json({
        data: { success: 1, message: "OTP Found", OTP: findUser.OTP, error: 0 },
      });
    } else {
      return res.json({
        data: { success: 0, message: "OTP Not Found", error: 1 },
      });
    }
  } catch (error) {
    return res.json({
      data: { success: 0, message: "An error occurred", error: 1 },
    });
  }
};

// Forgot Password
const ForgotPassword = async (req, res) => {
  try {
    const email = req.body.email;

    const EmailInfo = await User.findOne({ email: email });

    if (EmailInfo) {
      let OTP2 = otpgenerator.generate(4, {
        lowerCaseAlphabets: false,
        upperCaseAlphabets: false,
        specialChars: false,
      });

      ForgotPasswordOTP(EmailInfo.firstname, EmailInfo.email, OTP2);

      const delPastRecord = await PasswordOTP.deleteOne({
        email: EmailInfo.email,
      });

      const OTPMail = await PasswordOTP.create({
        email: EmailInfo.email,
        OTP: OTP2,
      });

      return res.json({
        data: {
          success: 1,
          message: "Please Check Your Email For OTP",
          error: 0,
        },
      });
    } else {
      return res.json({
        data: { success: 0, message: "Email Not Matched", error: 1 },
      });
    }
  } catch (error) {
    console.log(error.message);
  }
};

// Forgot Password Verification
const ForgotPasswordVerification = async (req, res) => {
  try {
    const email = req.body.email;
    const findUser = await PasswordOTP.findOne({ email: email });
    if (findUser) {
      if (findUser.OTP == req.body.otp) {
        const userEmail = await PasswordOTP.findOneAndUpdate(
          { email: email },
          { $set: { is_verified: 1 } },
        );
        if (userEmail.is_verified == 1) {
          return res.json({
            data: {
              success: 0,
              message: "OTP Not Matched..Try Again",
              error: 1,
            },
          });
        } else {
          return res.json({
            data: {
              success: 1,
              message: "User verified...Set New Password",
              error: 0,
            },
          });
        }
      } else {
        return res.json({
          data: { success: 0, message: "OTP Not Matched", error: 1 },
        });
      }
    } else {
      return res.json({
        data: {
          success: 0,
          message: "OTP expired...Try again for Password Reset",
          error: 1,
        },
      });
    }
  } catch (error) {
    return res.json({ data: { success: 0, message: error, error: 1 } });
  }
};

// Change Password
const ChangePassword = async (req, res) => {
  try {
    const email = req.body.email;
    const newpassword = req.body.newpassword;
    const findEmail = await PasswordOTP.findOne({
      email: email,
      is_verified: 1,
    });

    if (findEmail) {
      const EmailInfo = await User.findOne({ email: email });

      if (EmailInfo) {
        const pass = sha256.x2(newpassword);

        const SavePass = await User.findOneAndUpdate(
          { email: email },
          { $set: { password: pass } },
        );

        if (SavePass) {
          const DelMatched = await PasswordOTP.deleteOne({
            email: SavePass.email,
          });

          return res.json({
            data: {
              success: 1,
              message: "Password Changed Successfully..!!",
              error: 0,
            },
          });
        } else {
          return res.json({
            data: { success: 0, message: "Reset Password Failed", error: 1 },
          });
        }
      } else {
        return res.json({
          data: { success: 0, message: "Email Not found", error: 1 },
        });
      }
    } else {
      return res.json({
        data: {
          success: 0,
          message: "OTP expired...Try again for Password Reset",
          error: 1,
        },
      });
    }
  } catch (error) {
    console.log(error.message);
  }
};

// User Profile
const UploadImage = async (req, res) => {
  try {
    const image = req.file.filename;
    res.json({
      data: {
        success: 1,
        message: "Image Upload Successfully",
        image: image,
        error: 0,
      },
    });
  } catch (error) {
    console.log(error.message);
  }
};

// User Profile
const EditUser = async (req, res) => {
  try {
    const id = req.body.id;
    const email = req.body.email ? req.body.email.trim().toLowerCase() : undefined;
    const updateData = {
      firstname: req.body.firstname,
      lastname: req.body.lastname,
      countryCode: req.body.countryCode,
      phone: req.body.phone,
      image: req.body.image,
    };
    if (email) {
      const existing = await User.findOne({ email, _id: { $ne: id } });
      if (existing) {
        return res.json({
          data: { success: 0, message: "Email already exists", error: 1 },
        });
      }
      updateData.email = email;
    }
    const editUser = await User.findByIdAndUpdate(id, updateData);
    if (editUser) {
      return res.json({
        data: { success: 1, message: "User Updated", error: 0 },
      });
    } else {
      return res.json({
        data: { success: 0, message: "User Not Updated", error: 1 },
      });
    }
  } catch (error) {
    console.log(error.message);
  }
};

// Get user Details
const GetUser = async (req, res) => {
  try {
    const user = await User.findOne({ _id: req.body.userId });

    if (user) {
      const referralCode = await ensureReferralCode(user);
      res.json({
        data: {
          success: 1,
          message: "User Found Successfully...!!",
          user: {
            id: user._id,
            firstname: user.firstname,
            lastname: user.lastname,
            username: user.username,
            email: user.email,
            countryCode: user.countryCode,
            phone: user.phone,
            image: user.image ? user.image : "",
            points: user.points ? user.points : 0,
            total_questions: user.total_questions ? user.total_questions : 0,
            total_correct_answers: user.total_correct_answers
              ? user.total_correct_answers
              : 0,
            total_wrong_answers: user.total_wrong_answers
              ? user.total_wrong_answers
              : 0,
            referral_code: referralCode || "",
          },
          error: 0,
        },
      });
    } else {
      return res
        .status(404)
        .json({ data: { success: 0, message: "User Not Found", error: 1 } });
    }
  } catch (error) {
    console.log(error.message);
  }
};

function newFunction(req) {
  const page = parseInt(req.body.page || req.query.page) || 1;
  const limit = parseInt(req.body.limit || req.query.limit) || 4;
  const skip = (page - 1) * limit;
  return { limit, skip, page };
}

// Get Categories
const GetCategories = async (req, res) => {
  try {
    let categories = await Category.find({ is_active: 1 });
    const quizzes = await Quiz.find().populate("categoryId");

    if (quizzes.length > 0) {
      const categoryCounts = categories.map((category) => {
        const count = quizzes.filter(
          (quiz) =>
            quiz.categoryId &&
            quiz.categoryId._id.toString() === category._id.toString(),
        ).length;
        return {
          categoryId: category._id,
          count: count,
        };
      });

      if (categories.length > 0) {
        const categoryData = categories.map((category) => ({
          _id: category._id,
          name: category.name,
          image: category.image,
          is_feature: category.is_feature,
          quizcount: categoryCounts.find(
            (item) => item.categoryId.toString() === category._id.toString(),
          ).count,
        }));

        res.json({
          data: {
            success: 1,
            message: "category found",
            categoryDetails: categoryData,
            error: 0,
          },
        });
      } else {
        return res.json({
          data: { success: 0, message: "category not found", error: 1 },
        });
      }
    } else {
      // If no quizzes are found, still return categories but with 0 quiz count
      const categoryData = categories.map((category) => ({
        _id: category._id,
        name: category.name,
        image: category.image,
        is_feature: category.is_feature,
        quizcount: 0,
      }));

      res.json({
        data: {
          success: 1,
          message: "categories found but no quizzes available",
          categoryDetails: categoryData,
          error: 0,
        },
      });
    }
  } catch (error) {
    console.log(error);
    res.status(500).json({
      data: { success: 0, message: "Internal server error", error: 1 },
    });
  }
};

// Get Banner
const GetBanner = async (req, res) => {
  try {
    let banner = await Banner.find({ is_active: 1 }).populate(
      "quizId",
      "quizId name categoryId image timer_status minutes_per_quiz description pdf pdf_en pdf_hi",
    );
    if (banner.length > 0) {
      const bannerData = await Promise.all(
        banner.map(async (banners) => {
          // Get total questions count for this quiz
          const totalQuestions = await Questions.countDocuments({
            quizId: banners.quizId._id,
            is_active: 1,
          });
          return {
            _id: banners._id,
            image: banners.image,
            quizId: {
              ...banners.quizId._doc,
              description: normalizeQuizDescription(banners.quizId?.description),
              totalQuestions: totalQuestions,
            },
          };
        }),
      );
      res.json({
        data: {
          success: 1,
          message: "banner found",
          bannerDetails: bannerData,
          error: 0,
        },
      });
    } else {
      return res.json({
        data: { success: 0, message: "banner not found", error: 1 },
      });
    }
  } catch (error) {
    console.log(error);
    res.status(500).json({
      data: { success: 0, message: "Internal server error", error: 1 },
    });
  }
};

// Get Intro
const GetIntro = async (req, res) => {
  try {
    let intro = await Intro.find({ is_active: 1 }).sort({ createdAt: 1 });

    if (intro.length > 0) {
      const introData = intro.map((intros) => ({
        _id: intros._id,
        title: intros.title,
        image: intros.image,
        description: intros.description,
      }));
      res.json({
        data: {
          success: 1,
          message: "Intro found Successfully..",
          introDetails: introData,
          error: 0,
        },
      });
    } else {
      return res.json({
        data: { success: 0, message: "Intro not found", error: 1 },
      });
    }
  } catch (error) {
    console.log(error);
    res.status(500).json({
      data: { success: 0, message: "Internal server error", error: 1 },
    });
  }
};

// Get Quizzes
const GetQuizzes = async (req, res) => {
  try {
    let quizzes = await Quiz.find({ is_active: 1 })
      .populate("categoryId")
      .sort({ createdAt: -1 });

    // i want to extract bearer token from the header
    const token = req.headers.authorization
      ? req.headers.authorization.split(" ")[1]
      : null;

    let userId = null;
    // extract userId from token if token exists
    if (token) {
      const decoded = jwt.verify(token, process.env.SESSION_SECREAT);
      userId = decoded.id;
    }

    if (quizzes.length > 0) {
      const quizzesData = await Promise.all(
        quizzes.map(async (quiz) => {
          // Check if user has played the game
          const hasPlayed = userId
            ? await UserQuiz.exists({ userId, quizId: quiz._id })
            : false;

          // Count total questions for the current quiz
          const totalQuestions = await Questions.countDocuments({
            quizId: quiz._id,
          });

          return {
            _id: quiz._id,
            is_played: hasPlayed ? 1 : 0,
            name: quiz.name,
            categoryId: quiz.categoryId.id || quiz.categoryId._id,
            image: quiz.image,
            points_require_to_play: quiz.points_require_to_play,
            timer_status: quiz.timer_status,
            minutes_per_quiz: quiz.minutes_per_quiz,
            description: normalizeQuizDescription(quiz.description),
            pdf: quiz.pdf || { en: quiz.pdf_en || '', hi: quiz.pdf_hi || '' },
            pdf_en: quiz.pdf_en || (quiz.pdf ? quiz.pdf.en : ''),
            pdf_hi: quiz.pdf_hi || (quiz.pdf ? quiz.pdf.hi : ''),
            total_questions: totalQuestions,
            correct_ans_reward_per_question:
              quiz.correct_ans_reward_per_question,
            penalty_per_question: quiz.penalty_per_question,
          };
        }),
      );

      res.json({
        data: {
          success: 1,
          message: "quiz found",
          quizDetails: quizzesData,
          error: 0,
        },
      });
    } else {
      return res.json({
        data: { success: 0, message: "quiz not found", error: 1 },
      });
    }
  } catch (error) {
    console.log(error);
  }
};

// Get Quiz By Category
const GetQuizByCategory = async (req, res) => {
  try {
    const catId = req.body.categoryId;
    if (!catId) {
      return res.json({
        data: { success: 0, message: "categoryId is required", error: 1 },
      });
    }
    // i want to extract bearer token from the header
    const token = req.headers.authorization
      ? req.headers.authorization.split(" ")[1]
      : null;

    let userId = null;
    // extract userId from token if token exists
    if (token) {
      try {
        const decoded = jwt.verify(token, process.env.SESSION_SECREAT);
        userId = decoded.id;
      } catch (error) {
        console.log("Token verification failed:", error);
      }
    }

    const quizzes = await Quiz.find({
      categoryId: req.body.categoryId,
      is_active: 1,
    })
      .populate("categoryId")
      .sort({ createdAt: -1 }); // latest first;
    console.log("Fetched quizzes from MongoDB:", quizzes);

    if (quizzes.length > 0) {
      const quizzesData = await Promise.all(
        quizzes.map(async (quiz) => {
          // Check if user has played the game
          const hasPlayed = userId
            ? await UserQuiz.exists({ userId, quizId: quiz._id })
            : false;

          // Count total questions for the current quiz
          const totalQuestions = await Questions.countDocuments({
            quizId: quiz._id,
          });

          return {
            _id: quiz._id,
            is_played: hasPlayed ? 1 : 0,
            name: quiz.name,
            categoryId: quiz.categoryId._id,
            image: quiz.image,
            points_require_to_play: quiz.points_require_to_play,
            timer_status: quiz.timer_status,
            minutes_per_quiz: quiz.minutes_per_quiz,
            description: normalizeQuizDescription(quiz.description),
            pdf: quiz.pdf || { en: quiz.pdf_en || '', hi: quiz.pdf_hi || '' },
            pdf_en: quiz.pdf_en || (quiz.pdf ? quiz.pdf.en : ''),
            pdf_hi: quiz.pdf_hi || (quiz.pdf ? quiz.pdf.hi : ''),
            total_questions: totalQuestions,
            correct_ans_reward_per_question:
              quiz.correct_ans_reward_per_question,
            penalty_per_question: quiz.penalty_per_question,
          };
        }),
      );

      console.log("Final quizDetails response:", quizzesData);
      return res.json({
        data: {
          success: 1,
          message: "quiz found",
          quizDetails: quizzesData,
          error: 0,
        },
      });
    } else {
      return res.json({
        data: {
          success: 0,
          message: "No quizzes found in this category",
          error: 1,
        },
      });
    }
  } catch (error) {
    console.log("Error in GetQuizByCategory:", error);
    return res.json({
      data: {
        success: 0,
        message: "An error occurred while fetching quizzes",
        error: 1,
      },
    });
  }
};

// Remove HTML Attributes
const removeAttributes = (html) => {
  return html.replace(/<(\w+)(\s[^>]*)?>/g, "<$1>");
};

// Remove Non-Breaking Spaces
const removeNonBreakingSpaces = (html) => {
  return html.replace(/&nbsp;/g, ""); // Remove &nbsp;
};

// Bilingual helpers — storage is nested {en, hi}; legacy flat strings are
// normalized too so old documents keep working before/after migration.
const bi = (v) => {
  if (typeof v === "string") return { en: v, hi: "" };
  return { en: v?.en || "", hi: v?.hi || "" };
};
const optionTextEn = (o) =>
  typeof o === "string" ? o : typeof o?.text === "string" ? o.text : o?.text?.en || "";
const optionTextHi = (o) =>
  typeof o === "string" ? "" : typeof o?.text === "string" ? "" : o?.text?.hi || "";
const optionImage = (o) => (typeof o === "object" && o ? o.image || "" : "");

// Nested bilingual question shape for the mobile app:
//   question_title / answer / description: { en, hi }
//   option: { a: { text: { en, hi }, image }, ... }
const toAppQuestion = (question) => {
  const title = bi(question.question_title);
  const descRaw = bi(question.description);
  const stripBr = (s) => String(s || "").replace(/<p><br><\/p>/g, "");
  const answer = bi(question.answer);
  const opt = (key) => {
    const o = question.option?.[key];
    if (typeof o === "string") {
      return { text: { en: o, hi: "" }, image: "" };
    }
    const t =
      typeof o?.text === "string"
        ? { en: o.text, hi: "" }
        : bi(o?.text);
    return { text: { en: t.en, hi: t.hi }, image: optionImage(o) };
  };
  return {
    question_title: { en: title.en, hi: title.hi },
    subject: question.subject || '',
    chapter: question.chapter || '',
    question_mode: question.question_mode || 'mix',
    option: { a: opt("a"), b: opt("b"), c: opt("c"), d: opt("d") },
    answer: { en: answer.en, hi: answer.hi },
    description: { en: stripBr(descRaw.en), hi: stripBr(descRaw.hi) },
  };
};

// Get Questions
const GetQuestions = async (req, res) => {
  try {
    let questions = await Questions.find({ is_active: 1 })
      .populate(["categoryId", "quizId"])
      .lean();

    if (questions.length > 0) {
      const questionsData = questions.map((question) => ({
        _id: question._id,
        categoryId: question.categoryId?._id || null,
        quizId: question.quizId?._id || null,
        question_type: question.question_type,
        image: question.image,
        audio: question.audio,
        ...toAppQuestion(question),
      }));

      res.json({
        data: {
          success: 1,
          message: "questions found",
          questionsDetails: questionsData,
          error: 0,
        },
      });
    } else {
      return res.json({
        data: { success: 0, message: "questions not found", error: 1 },
      });
    }
  } catch (error) {
    console.log(error);
  }
};

// Get Questions By QuizId
const GetQuestionsByQuizId = async (req, res) => {
  try {
    console.log("API CALL: GetQuestionsByQuizId");
    console.log("Received quizId:", req.body.quizId);
    let questions = await Questions.find({
      quizId: req.body.quizId,
      is_active: 1,
    }).populate(["categoryId", "subcategoryId", "quizId"]).lean();
    console.log("Questions found:", questions.length);
    if (questions.length > 0) {
      const questionsData = questions.map((question) => ({
        _id: question._id,
        categoryId: question.categoryId?._id || null,
        subcategoryName: question.subcategoryId?.name || '',
        subject: question.subject || '',
        question_mode: question.question_mode || 'mix',
        quizId: {
          _id: question.quizId?._id || null,
          timer_status: question.quizId?.timer_status,
          minutes_per_quiz: question.quizId?.minutes_per_quiz,
          correct_ans_reward_per_question:
            question.quizId?.correct_ans_reward_per_question,
          penalty_per_question: question.quizId?.penalty_per_question,
          name: question.quizId?.name,
          image: question.quizId?.image,
          description: normalizeQuizDescription(question.quizId?.description),
          pdf: question.quizId?.pdf || { en: question.quizId?.pdf_en || '', hi: question.quizId?.pdf_hi || '' },
          pdf_en: question.quizId?.pdf_en || (question.quizId?.pdf ? question.quizId.pdf.en : ''),
          pdf_hi: question.quizId?.pdf_hi || (question.quizId?.pdf ? question.quizId.pdf.hi : ''),
        },
        question_type: question.question_type,
        image: question.image,
        audio: question.audio,
        ...toAppQuestion(question),
      }));

      const responseObj = {
        data: {
          success: 1,
          message: "questions found",
          questionsDetails: questionsData,
          correctAnsReward: questions[0].quizId?.correct_ans_reward_per_question,
          penaltyPerQuestion: questions[0].quizId?.penalty_per_question,
          error: 0,
        },
      };
      console.log("API RESPONSE:", JSON.stringify(responseObj, null, 2));
      return res.json(responseObj);
    } else {
      console.log("No questions found for quizId:", req.body.quizId);
      return res.json({
        data: { success: 0, message: "questions not found", error: 1 },
      });
    }
  } catch (error) {
    console.log("ERROR in GetQuestionsByQuizId:", error);
  }
};

// Download or View Quiz Question Paper (Printable HTML / PDF)
const DownloadQuizPdf = async (req, res) => {
  try {
    const quizId = req.params.quizId || req.query.quizId || req.body?.quizId;
    if (!quizId) {
      return res.status(400).send(`
        <!DOCTYPE html>
        <html><head><title>Error</title></head>
        <body style="font-family:sans-serif;padding:40px;text-align:center;">
          <h2>Invalid Request</h2>
          <p>Quiz ID is required.</p>
        </body></html>
      `);
    }

    const quiz = await Quiz.findById(quizId).populate(["categoryId", "subcategoryId"]).lean();
    if (!quiz) {
      return res.status(404).send(`
        <!DOCTYPE html>
        <html><head><title>Quiz Not Found</title></head>
        <body style="font-family:sans-serif;padding:40px;text-align:center;">
          <h2>Quiz Not Found</h2>
          <p>The requested mock test could not be found.</p>
        </body></html>
      `);
    }

    // If quiz has static pdf uploaded
    const staticPdf = quiz.pdf || quiz.pdf_url || quiz.file || quiz.link;
    if (staticPdf && typeof staticPdf === "string" && staticPdf.trim() && !req.query.force_render) {
      const clean = staticPdf.trim();
      const target = clean.startsWith("http") ? clean : `/assets/userImages/${clean}`;
      return res.redirect(target);
    }

    const questions = await Questions.find({ quizId: quiz._id, is_active: 1 }).sort({ _id: 1 }).lean();
    if (!questions || questions.length === 0) {
      return res.status(200).send(`
        <!DOCTYPE html>
        <html><head><title>${quiz.name || "Mock Test"}</title></head>
        <body style="font-family:sans-serif;padding:40px;text-align:center;">
          <h2>${quiz.name || "Mock Test"}</h2>
          <p>Questions for this mock test are currently being prepared.</p>
        </body></html>
      `);
    }

    const quizTitle = quiz.name || "Mock Test Paper";
    const categoryName = quiz.categoryId?.name || "";
    const subcategoryName = quiz.subcategoryId?.name || "";
    const totalQuestions = questions.length;
    const timeMinutes = quiz.minutes_per_quiz || (totalQuestions > 0 ? totalQuestions : 60);
    const rewardPerQ = quiz.correct_ans_reward_per_question !== undefined && quiz.correct_ans_reward_per_question !== null ? quiz.correct_ans_reward_per_question : 1;
    const penaltyPerQ = quiz.penalty_per_question !== undefined && quiz.penalty_per_question !== null ? quiz.penalty_per_question : 0;
    const totalMarks = totalQuestions * rewardPerQ;

    const biText = (val) => {
      if (!val) return { en: "", hi: "" };
      if (typeof val === "string") return { en: val, hi: "" };
      return {
        en: (val.en || "").toString().trim(),
        hi: (val.hi || "").toString().trim(),
      };
    };

    const cleanHtml = (html) => {
      if (!html) return "";
      let s = String(html).trim();
      s = s.replace(/<p><br\s*\/?><\/p>/gi, "");
      s = s.replace(/&nbsp;/g, " ");
      return s;
    };

    const resolveOption = (opt) => {
      if (!opt) return { en: "", hi: "", image: "" };
      if (typeof opt === "string") return { en: opt, hi: "", image: "" };
      const textBi = biText(opt.text);
      const img = opt.image ? opt.image.toString().trim() : "";
      return { en: textBi.en, hi: textBi.hi, image: img };
    };

    const formatImgUrl = (img) => {
      if (!img || typeof img !== "string") return "";
      const clean = img.trim();
      if (!clean) return "";
      if (clean.startsWith("http://") || clean.startsWith("https://") || clean.startsWith("data:")) return clean;
      if (clean.startsWith("/")) return clean;
      return "/assets/userImages/" + clean;
    };

    const stripTags = (s) => (s || "").replace(/<[^>]*>/g, "").trim().toLowerCase();

    const getAnswerKey = (q, optA, optB, optC, optD) => {
      const ansBi = biText(q.answer);
      const ansEn = ansBi.en.trim().toLowerCase();
      const ansHi = ansBi.hi.trim().toLowerCase();

      if (ansEn === "a" || ansHi === "a" || ansEn === "1" || ansHi === "1") return "A";
      if (ansEn === "b" || ansHi === "b" || ansEn === "2" || ansHi === "2") return "B";
      if (ansEn === "c" || ansHi === "c" || ansEn === "3" || ansHi === "3") return "C";
      if (ansEn === "d" || ansHi === "d" || ansEn === "4" || ansHi === "4") return "D";

      const ansRawEn = stripTags(ansBi.en);
      const ansRawHi = stripTags(ansBi.hi);

      const checkMatch = (opt) => {
        const oEn = stripTags(opt.en);
        const oHi = stripTags(opt.hi);
        if (ansRawEn && oEn && ansRawEn === oEn) return true;
        if (ansRawHi && oHi && ansRawHi === oHi) return true;
        if (ansRawHi && oEn && ansRawHi === oEn) return true;
        if (ansRawEn && oHi && ansRawEn === oHi) return true;
        return false;
      };

      if (checkMatch(optA)) return "A";
      if (checkMatch(optB)) return "B";
      if (checkMatch(optC)) return "C";
      if (checkMatch(optD)) return "D";

      return ansBi.en || ansBi.hi || "-";
    };

    const formattedQuestions = questions.map((q, idx) => {
      const qNum = idx + 1;
      const qTitleBi = biText(q.question_title);
      const optA = resolveOption(q.option?.a);
      const optB = resolveOption(q.option?.b);
      const optC = resolveOption(q.option?.c);
      const optD = resolveOption(q.option?.d);
      const correctOption = getAnswerKey(q, optA, optB, optC, optD);
      const descBi = biText(q.description);

      return {
        number: qNum,
        subject: q.subject || "",
        chapter: q.chapter || "",
        title: { en: cleanHtml(qTitleBi.en), hi: cleanHtml(qTitleBi.hi) },
        image: q.image ? q.image.trim() : "",
        options: { a: optA, b: optB, c: optC, d: optD },
        correctOption,
        explanation: { en: cleanHtml(descBi.en), hi: cleanHtml(descBi.hi) },
      };
    });

    // Build answer key grid (chunks of 10)
    let answerKeyHtml = '<div class="ans-grid-wrap"><table class="ans-table"><thead><tr>';
    for (let c = 1; c <= 10; c++) {
      answerKeyHtml += `<th>Q</th><th>Ans</th>`;
    }
    answerKeyHtml += "</tr></thead><tbody>";

    const chunkSize = 10;
    for (let i = 0; i < formattedQuestions.length; i += chunkSize) {
      answerKeyHtml += "<tr>";
      const chunk = formattedQuestions.slice(i, i + chunkSize);
      for (let c = 0; c < 10; c++) {
        if (c < chunk.length) {
          const item = chunk[c];
          answerKeyHtml += `<td class="q-cell">${item.number}</td><td class="ans-cell"><strong>${item.correctOption}</strong></td>`;
        } else {
          answerKeyHtml += `<td class="q-cell">-</td><td class="ans-cell">-</td>`;
        }
      }
      answerKeyHtml += "</tr>";
    }
    answerKeyHtml += "</tbody></table></div>";

    // Render questions HTML
    let questionsHtml = formattedQuestions.map((q) => {
      const renderOpt = (letter, opt) => {
        const hasTextEn = !!opt.en;
        const hasTextHi = !!opt.hi;
        const hasImg = !!opt.image;
        if (!hasTextEn && !hasTextHi && !hasImg) return "";

        return `
          <div class="opt-box">
            <span class="opt-label">${letter}</span>
            <div class="opt-content">
              ${hasTextHi ? `<div class="lang-hi text-hindi opt-text">${opt.hi}</div>` : ""}
              ${hasTextEn ? `<div class="lang-en text-english opt-text">${opt.en}</div>` : ""}
              ${hasImg ? `<img src="${formatImgUrl(opt.image)}" class="opt-img" alt="Option ${letter}" />` : ""}
            </div>
          </div>
        `;
      };

      const hasTitleHi = !!q.title.hi;
      const hasTitleEn = !!q.title.en;
      const hasQImg = !!q.image;

      return `
        <div class="question-card" id="q-${q.number}">
          <div class="q-meta-header">
            <div class="q-number">Question ${q.number}</div>
            <div class="q-tags">
              ${q.subject ? `<span class="q-subject-badge">${q.subject}</span>` : ""}
              <span class="q-marks-badge">+${rewardPerQ} / -${penaltyPerQ}</span>
            </div>
          </div>
          <div class="q-body">
            ${hasTitleHi ? `<div class="lang-hi text-hindi q-text">${q.title.hi}</div>` : ""}
            ${hasTitleEn ? `<div class="lang-en text-english q-text">${q.title.en}</div>` : ""}
            ${hasQImg ? `<div class="q-img-wrap"><img src="${formatImgUrl(q.image)}" class="q-img" alt="Question ${q.number}" /></div>` : ""}
          </div>
          <div class="options-grid">
            ${renderOpt("A", q.options.a)}
            ${renderOpt("B", q.options.b)}
            ${renderOpt("C", q.options.c)}
            ${renderOpt("D", q.options.d)}
          </div>
        </div>
      `;
    }).join("");

    // Render solutions HTML
    let solutionsHtml = formattedQuestions.map((q) => {
      const hasHi = !!q.explanation.hi;
      const hasEn = !!q.explanation.en;
      return `
        <div class="solution-card" id="sol-${q.number}">
          <div class="sol-header">
            <span class="sol-qnum">Q. ${q.number}</span>
            <span class="sol-correct-badge">Correct Answer: <strong>Option (${q.correctOption})</strong></span>
          </div>
          <div class="sol-body">
            ${hasHi ? `<div class="lang-hi text-hindi sol-text">${q.explanation.hi}</div>` : ""}
            ${hasEn ? `<div class="lang-en text-english sol-text">${q.explanation.en}</div>` : ""}
            ${!hasHi && !hasEn ? `<div class="sol-text text-muted">Option (${q.correctOption}) is the correct answer.</div>` : ""}
          </div>
        </div>
      `;
    }).join("");

    const fullHtml = `<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>${quizTitle} - Mock Station Test Paper</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&family=Noto+Sans+Devanagari:wght@400;500;600;700&display=swap" rel="stylesheet">
  <style>
    :root {
      --primary: #1D6FFF;
      --primary-dark: #1450BE;
      --primary-light: #EEF4FF;
      --bg: #F8FAFC;
      --card-bg: #FFFFFF;
      --text: #1E293B;
      --text-muted: #64748B;
      --border: #E2E8F0;
      --correct: #16A34A;
      --correct-bg: #DCFCE7;
    }

    * {
      box-sizing: border-box;
      margin: 0;
      padding: 0;
    }

    body {
      font-family: 'Inter', 'Noto Sans Devanagari', -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
      background-color: var(--bg);
      color: var(--text);
      line-height: 1.6;
      -webkit-font-smoothing: antialiased;
    }

    /* Fixed Action Toolbar */
    .action-bar {
      position: sticky;
      top: 0;
      z-index: 100;
      background: #FFFFFF;
      border-bottom: 1px solid var(--border);
      box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05);
      padding: 10px 16px;
      display: flex;
      flex-wrap: wrap;
      align-items: center;
      justify-content: space-between;
      gap: 12px;
    }

    .bar-brand {
      display: flex;
      align-items: center;
      gap: 8px;
    }

    .brand-logo-text {
      font-size: 18px;
      font-weight: 800;
      color: var(--primary);
      letter-spacing: -0.5px;
    }

    .brand-badge {
      font-size: 11px;
      background: var(--primary-light);
      color: var(--primary);
      font-weight: 700;
      padding: 2px 8px;
      border-radius: 6px;
      text-transform: uppercase;
    }

    .bar-controls {
      display: flex;
      align-items: center;
      gap: 8px;
      flex-wrap: wrap;
    }

    .btn-group {
      display: inline-flex;
      background: #F1F5F9;
      border-radius: 8px;
      padding: 3px;
      border: 1px solid var(--border);
    }

    .btn-group button {
      border: none;
      background: transparent;
      padding: 6px 12px;
      font-size: 13px;
      font-weight: 600;
      color: var(--text-muted);
      border-radius: 6px;
      cursor: pointer;
      transition: all 0.2s;
    }

    .btn-group button.active {
      background: #FFFFFF;
      color: var(--primary);
      box-shadow: 0 2px 4px rgba(0,0,0,0.06);
    }

    .btn-action {
      display: inline-flex;
      align-items: center;
      gap: 6px;
      background: var(--primary);
      color: #FFFFFF;
      border: none;
      padding: 8px 16px;
      font-size: 14px;
      font-weight: 600;
      border-radius: 8px;
      cursor: pointer;
      box-shadow: 0 2px 6px rgba(29, 111, 255, 0.3);
      transition: all 0.2s;
      text-decoration: none;
    }

    .btn-action:hover {
      background: var(--primary-dark);
    }

    .btn-outline {
      display: inline-flex;
      align-items: center;
      gap: 6px;
      background: #FFFFFF;
      color: var(--text);
      border: 1px solid var(--border);
      padding: 7px 12px;
      font-size: 13px;
      font-weight: 600;
      border-radius: 8px;
      cursor: pointer;
      text-decoration: none;
    }

    .btn-outline:hover {
      background: #F8FAFC;
    }

    /* Container */
    .container {
      max-width: 900px;
      margin: 24px auto;
      padding: 0 16px 40px;
    }

    /* Exam Paper Header */
    .paper-header {
      background: #FFFFFF;
      border: 1px solid var(--border);
      border-radius: 12px;
      padding: 24px;
      margin-bottom: 20px;
      box-shadow: 0 2px 8px rgba(0,0,0,0.02);
      text-align: center;
    }

    .paper-title {
      font-size: 22px;
      font-weight: 800;
      color: #0F172A;
      margin-bottom: 6px;
    }

    .paper-sub {
      font-size: 14px;
      color: var(--text-muted);
      font-weight: 500;
      margin-bottom: 16px;
    }

    .meta-grid {
      display: grid;
      grid-template-columns: repeat(4, 1fr);
      gap: 10px;
      margin-top: 16px;
    }

    .meta-box {
      background: #F8FAFC;
      border: 1px solid var(--border);
      border-radius: 8px;
      padding: 10px 8px;
      text-align: center;
    }

    .meta-label {
      font-size: 11px;
      text-transform: uppercase;
      font-weight: 700;
      color: var(--text-muted);
      margin-bottom: 4px;
    }

    .meta-value {
      font-size: 15px;
      font-weight: 700;
      color: #0F172A;
    }

    /* Instructions */
    .instructions-card {
      background: #FEF9C3;
      border: 1px solid #FDE047;
      border-radius: 10px;
      padding: 16px 20px;
      margin-bottom: 24px;
      font-size: 13px;
      color: #713F12;
    }

    .instructions-card h4 {
      font-size: 14px;
      font-weight: 700;
      margin-bottom: 8px;
    }

    .instructions-card ol {
      padding-left: 20px;
    }

    .instructions-card li {
      margin-bottom: 4px;
    }

    /* Section Header */
    .section-title-bar {
      display: flex;
      align-items: center;
      justify-content: space-between;
      margin: 32px 0 16px;
      padding-bottom: 8px;
      border-bottom: 2px solid var(--primary);
    }

    .section-title-bar h2 {
      font-size: 18px;
      font-weight: 800;
      color: #0F172A;
    }

    /* Question Cards */
    .question-card {
      background: #FFFFFF;
      border: 1px solid var(--border);
      border-radius: 10px;
      padding: 16px 20px;
      margin-bottom: 16px;
      box-shadow: 0 1px 4px rgba(0,0,0,0.02);
      break-inside: avoid;
      page-break-inside: avoid;
    }

    .q-meta-header {
      display: flex;
      align-items: center;
      justify-content: space-between;
      margin-bottom: 12px;
    }

    .q-number {
      font-size: 14px;
      font-weight: 800;
      color: var(--primary);
    }

    .q-tags {
      display: flex;
      align-items: center;
      gap: 6px;
    }

    .q-subject-badge {
      font-size: 11px;
      font-weight: 600;
      background: #F1F5F9;
      color: #475569;
      padding: 2px 8px;
      border-radius: 4px;
      border: 1px solid #CBD5E1;
    }

    .q-marks-badge {
      font-size: 11px;
      font-weight: 700;
      background: #F8FAFC;
      color: #0F172A;
      padding: 2px 8px;
      border-radius: 4px;
      border: 1px solid var(--border);
    }

    .q-body {
      font-size: 15px;
      font-weight: 500;
      margin-bottom: 14px;
      line-height: 1.6;
    }

    .q-body p {
      margin-bottom: 6px;
    }

    .q-body ol, .q-body ul {
      margin: 8px 0;
      padding-left: 24px;
    }

    .q-text {
      margin-bottom: 8px;
    }

    .text-hindi {
      font-family: 'Noto Sans Devanagari', sans-serif;
    }

    .text-english {
      font-family: 'Inter', sans-serif;
    }

    .q-img-wrap {
      margin: 10px 0;
      text-align: center;
    }

    .q-img {
      max-width: 100%;
      max-height: 320px;
      border-radius: 6px;
      border: 1px solid var(--border);
    }

    /* Options Grid */
    .options-grid {
      display: grid;
      grid-template-columns: 1fr 1fr;
      gap: 10px;
    }

    .opt-box {
      display: flex;
      align-items: flex-start;
      gap: 10px;
      background: #F8FAFC;
      border: 1px solid var(--border);
      border-radius: 8px;
      padding: 10px 12px;
      font-size: 14px;
    }

    .opt-label {
      display: inline-flex;
      align-items: center;
      justify-content: center;
      width: 24px;
      height: 24px;
      border-radius: 50%;
      background: #FFFFFF;
      border: 1.5px solid #CBD5E1;
      font-size: 12px;
      font-weight: 800;
      color: #334155;
      flex-shrink: 0;
    }

    .opt-content {
      flex: 1;
      font-weight: 500;
    }

    .opt-img {
      max-width: 100%;
      max-height: 160px;
      margin-top: 6px;
      border-radius: 4px;
    }

    /* Answer Key Table */
    .ans-grid-wrap {
      overflow-x: auto;
      background: #FFFFFF;
      border: 1px solid var(--border);
      border-radius: 10px;
      padding: 12px;
      margin-bottom: 24px;
    }

    .ans-table {
      width: 100%;
      border-collapse: collapse;
      font-size: 12px;
      text-align: center;
    }

    .ans-table th {
      background: #F1F5F9;
      padding: 8px 4px;
      border: 1px solid var(--border);
      font-weight: 700;
      color: #334155;
    }

    .ans-table td {
      padding: 6px 4px;
      border: 1px solid var(--border);
    }

    .ans-table .q-cell {
      background: #F8FAFC;
      font-weight: 600;
      color: #64748B;
    }

    .ans-table .ans-cell {
      color: var(--primary);
      font-weight: 800;
      background: #FFFFFF;
    }

    /* Solution Cards */
    .solution-card {
      background: #FFFFFF;
      border: 1px solid var(--border);
      border-radius: 10px;
      padding: 16px 20px;
      margin-bottom: 14px;
      break-inside: avoid;
      page-break-inside: avoid;
    }

    .sol-header {
      display: flex;
      align-items: center;
      justify-content: space-between;
      margin-bottom: 10px;
      padding-bottom: 8px;
      border-bottom: 1px dashed var(--border);
    }

    .sol-qnum {
      font-size: 14px;
      font-weight: 800;
      color: #0F172A;
    }

    .sol-correct-badge {
      font-size: 12px;
      background: var(--correct-bg);
      color: var(--correct);
      padding: 4px 10px;
      border-radius: 6px;
      font-weight: 600;
    }

    .sol-body {
      font-size: 14px;
      line-height: 1.6;
      color: #334155;
    }

    .sol-text {
      margin-bottom: 6px;
    }

    /* Language Visibility Filtering */
    .hide-en .lang-en {
      display: none !important;
    }

    .hide-hi .lang-hi {
      display: none !important;
    }

    /* Footer */
    .paper-footer {
      text-align: center;
      padding: 24px 0 10px;
      font-size: 12px;
      color: var(--text-muted);
      border-top: 1px solid var(--border);
      margin-top: 30px;
    }

    /* Print Stylesheet */
    @media print {
      body {
        background: #FFFFFF;
        color: #000000;
        font-size: 11pt;
      }

      .no-print, .action-bar {
        display: none !important;
      }

      .container {
        max-width: 100%;
        margin: 0;
        padding: 0;
      }

      .paper-header {
        border: 1px solid #000000;
        box-shadow: none;
        padding: 12px;
        margin-bottom: 12px;
      }

      .meta-grid {
        gap: 6px;
      }

      .meta-box {
        border: 1px solid #999999;
        background: #FAFAFA;
        padding: 6px;
      }

      .instructions-card {
        border: 1px solid #000000;
        background: #FFFFFF;
        color: #000000;
        padding: 10px;
      }

      .question-card, .solution-card {
        border: 1px solid #D1D5DB;
        box-shadow: none;
        padding: 10px 14px;
        margin-bottom: 10px;
        break-inside: avoid;
        page-break-inside: avoid;
      }

      .page-break {
        break-before: page;
        page-break-before: always;
      }

      .opt-box {
        background: #FFFFFF;
        border: 1px solid #E5E7EB;
        padding: 6px 10px;
      }

      .ans-table th {
        background: #EEEEEE;
        border: 1px solid #333333;
        color: #000000;
      }

      .ans-table td {
        border: 1px solid #333333;
      }
    }

    @media (max-width: 640px) {
      .meta-grid {
        grid-template-columns: repeat(2, 1fr);
      }
      .options-grid {
        grid-template-columns: 1fr;
      }
    }
  </style>
</head>
<body>

  <!-- Top Action Toolbar -->
  <div class="action-bar no-print">
    <div class="bar-brand">
      <span class="brand-logo-text">MOCK STATION</span>
      <span class="brand-badge">Official Paper</span>
    </div>
    <div class="bar-controls">
      <div class="btn-group">
        <button id="btn-both" class="active" onclick="setLanguage('both')">Both / दोनों</button>
        <button id="btn-en" onclick="setLanguage('en')">English</button>
        <button id="btn-hi" onclick="setLanguage('hi')">हिन्दी</button>
      </div>
      <a href="#section-anskey" class="btn-outline">Answer Key</a>
      <a href="#section-solutions" class="btn-outline">Solutions</a>
      <button class="btn-action" onclick="window.print()">
        <svg width="16" height="16" fill="currentColor" viewBox="0 0 24 24"><path d="M19 8H5c-1.66 0-3 1.34-3 3v6h4v4h12v-4h4v-6c0-1.66-1.34-3-3-3zm-3 11H8v-5h8v5zm3-7c-.55 0-1-.45-1-1s.45-1 1-1 1 .45 1 1-.45 1-1 1zm-1-9H6v4h12V3z"/></svg>
        Download / Print PDF
      </button>
    </div>
  </div>

  <div class="container" id="paper-container">

    <!-- Exam Paper Header -->
    <div class="paper-header">
      <div class="paper-sub">${categoryName ? categoryName + " &bull; " : ""}${subcategoryName}</div>
      <h1 class="paper-title">${quizTitle}</h1>
      <div class="meta-grid">
        <div class="meta-box">
          <div class="meta-label">Total Questions</div>
          <div class="meta-value">${totalQuestions}</div>
        </div>
        <div class="meta-box">
          <div class="meta-label">Time Allowed</div>
          <div class="meta-value">${timeMinutes} Mins</div>
        </div>
        <div class="meta-box">
          <div class="meta-label">Maximum Marks</div>
          <div class="meta-value">${totalMarks}</div>
        </div>
        <div class="meta-box">
          <div class="meta-label">Marking Scheme</div>
          <div class="meta-value">+${rewardPerQ} / -${penaltyPerQ}</div>
        </div>
      </div>
    </div>

    <!-- Instructions -->
    <div class="instructions-card">
      <h4>📌 Instructions for Candidates (अभ्यर्थियों के लिए निर्देश):</h4>
      <ol>
        <li>This question paper contains <strong>${totalQuestions} questions</strong>. All questions are compulsory.</li>
        <li>Each question carries <strong>${rewardPerQ} mark(s)</strong>. A negative marking of <strong>${penaltyPerQ} marks</strong> is applicable for each wrong answer.</li>
        <li>Each question has 4 options (A, B, C, D) with only one correct choice.</li>
        <li>Detailed Answer Key and Explanations are provided at the end of this paper.</li>
      </ol>
    </div>

    <!-- Questions Section -->
    <div class="section-title-bar">
      <h2>QUESTIONS (प्रश्न पत्र)</h2>
      <span class="brand-badge">${totalQuestions} Questions</span>
    </div>

    <div class="questions-list">
      ${questionsHtml}
    </div>

    <!-- Answer Key Section -->
    <div class="page-break" id="section-anskey"></div>
    <div class="section-title-bar" style="margin-top: 40px;">
      <h2>ANSWER KEY (उत्तर कुंजी)</h2>
      <span class="brand-badge">Quick Reference</span>
    </div>
    ${answerKeyHtml}

    <!-- Solutions Section -->
    <div class="page-break" id="section-solutions"></div>
    <div class="section-title-bar" style="margin-top: 40px;">
      <h2>DETAILED SOLUTIONS & EXPLANATIONS (विस्तृत हल)</h2>
      <span class="brand-badge">Solutions</span>
    </div>
    <div class="solutions-list">
      ${solutionsHtml}
    </div>

    <!-- Footer -->
    <div class="paper-footer">
      <p>&copy; ${new Date().getFullYear()} Mock Station App. All Rights Reserved.</p>
      <p style="margin-top: 4px; font-size: 11px;">Practice online tests on Mock Station App: https://play.google.com/store/apps/details?id=com.mock.exam.app</p>
    </div>

  </div>

  <script>
    function setLanguage(lang) {
      const container = document.getElementById('paper-container');
      const btnBoth = document.getElementById('btn-both');
      const btnEn = document.getElementById('btn-en');
      const btnHi = document.getElementById('btn-hi');

      btnBoth.classList.remove('active');
      btnEn.classList.remove('active');
      btnHi.classList.remove('active');

      container.classList.remove('hide-en', 'hide-hi');

      if (lang === 'en') {
        container.classList.add('hide-hi');
        btnEn.classList.add('active');
      } else if (lang === 'hi') {
        container.classList.add('hide-en');
        btnHi.classList.add('active');
      } else {
        btnBoth.classList.add('active');
      }
    }

    const urlParams = new URLSearchParams(window.location.search);
    if (urlParams.get('lang') === 'en') {
      setLanguage('en');
    } else if (urlParams.get('lang') === 'hi') {
      setLanguage('hi');
    }

    if (urlParams.get('print') === '1' || urlParams.get('download') === '1') {
      window.onload = function() {
        setTimeout(function() {
          window.print();
        }, 500);
      };
    }
  </script>
</body>
</html>`;

    return res.status(200).send(fullHtml);
  } catch (error) {
    console.error("ERROR in DownloadQuizPdf:", error);
    return res.status(500).send(`
      <!DOCTYPE html>
      <html><head><title>Server Error</title></head>
      <body style="font-family:sans-serif;padding:40px;text-align:center;">
        <h2>Error Generating Test Paper</h2>
        <p>An error occurred while generating the test paper. Please try again later.</p>
      </body></html>
    `);
  }
};

// Get Questions By CategoryId
const GetQuestionsByCategoryId = async (req, res) => {
  try {
    let questions = await Questions.find({
      categoryId: req.body.categoryId,
      is_active: 1,
    }).populate(["categoryId", "quizId"]).lean();

    if (questions.length > 0) {
      const questionsData = questions.map((question) => ({
        _id: question._id,
        categoryId: question.categoryId?._id || null,
        quizId: question.quizId?._id || null,
        question_type: question.question_type,
        image: question.image,
        audio: question.audio,
        ...toAppQuestion(question),
      }));

      res.json({
        data: {
          success: 1,
          message: "questions found",
          questionsDetails: questionsData,
          error: 0,
        },
      });
    } else {
      return res.json({
        data: { success: 0, message: "questions not found", error: 1 },
      });
    }
  } catch (error) {
    console.log(error);
  }
};

// Get Featured CategoryId
// const GetFeaturedCategory = async (req, res) => {
//     try {
//         const categories = await Category.find({ is_feature: 1 });

//         if (categories.length > 0) {

//             const categoryData = categories.map(category => ({
//                 "_id": category._id,
//                 "name": category.name,
//                 "is_feature": category.is_feature
//             }));

//             res.json({ "data": { "success": 1, "message": "featured category found", categoryDetails: categoryData, "error": 0 } });
//         } else {
//             return res.json({ "data": { "success": 0, "message": "featured category not found", "error": 1 } });
//         }

//     } catch (error) {
//         console.log(error);
//     }
// }

const GetFeaturedCategory = async (req, res) => {
  try {
    const categories = await Category.find({ is_feature: 1, is_active: 1 });

    // i want to extract bearer token from the header
    const token = req.headers.authorization
      ? req.headers.authorization.split(" ")[1]
      : null;

    let userId = null;
    // extract userId from token if token exists
    if (token) {
      const decoded = jwt.verify(token, process.env.SESSION_SECREAT);
      userId = decoded.id;
    }

    if (categories.length > 0) {
      const categoryData = await Promise.all(
        categories.map(async (category) => {
          // Retrieve quizzes for the current category
          const quizzes = await Quiz.find({ categoryId: category._id })
            .sort({ createdAt: -1 })
            .limit(2);

          // Optionally, you can format quizzes if needed
          const quizzesData = await Promise.all(
            quizzes.map(async (quiz) => {
              // Check if user has played the game
              const hasPlayed = userId
                ? await UserQuiz.exists({ userId, quizId: quiz._id })
                : false;

              // You might want to include additional information like total questions or if played
              const totalQuestions = await Questions.countDocuments({
                quizId: quiz._id,
              });
              return {
                _id: quiz._id,
                is_played: hasPlayed ? 1 : 0,
                name: quiz.name,
                image: quiz.image,
                categoryId: quiz.categoryId,
                points_require_to_play: quiz.points_require_to_play,
                timer_status: quiz.timer_status,
                minutes_per_quiz: quiz.minutes_per_quiz,
                description: normalizeQuizDescription(quiz.description),
                pdf: quiz.pdf || { en: quiz.pdf_en || '', hi: quiz.pdf_hi || '' },
                pdf_en: quiz.pdf_en || (quiz.pdf ? quiz.pdf.en : ''),
                pdf_hi: quiz.pdf_hi || (quiz.pdf ? quiz.pdf.hi : ''),
                total_questions: totalQuestions,
                correct_ans_reward_per_question:
                  quiz.correct_ans_reward_per_question,
                penalty_per_question: quiz.penalty_per_question,
              };
            }),
          );

          return {
            _id: category._id,
            name: category.name,
            is_feature: category.is_feature,
            image: category.image,
            quizzes: quizzesData, // Include quizzes related to the category
          };
        }),
      );

      res.json({
        data: {
          success: 1,
          message: "featured category found",
          categoryDetails: categoryData,
          error: 0,
        },
      });
    } else {
      return res.json({
        data: { success: 0, message: "featured category not found", error: 1 },
      });
    }
  } catch (error) {
    console.log(error);
    res.json({ data: { success: 0, message: "An error occurred", error: 1 } });
  }
};

// Get Ads Settings
const GetAdsSettings = async (req, res) => {
  try {
    const ads = await Ads.find();

    if (ads.length >= 0) {
      const adsData = ads.map((ad) => ({
        banner_ad: ad.banner_ad,
        interstitial_ad: ad.interstitial_ad,
        rewarded_video_ad: ad.rewarded_video_ad,
        rewarded_points_for_each_video_ads:
          ad.rewarded_points_for_each_video_ads,
      }));
      res.json({
        data: {
          success: 1,
          message: "ads setting found",
          adsDetails: adsData,
          error: 0,
        },
      });
    } else {
      return res.json({
        data: { success: 0, message: "ads setting not found", error: 1 },
      });
    }
  } catch (error) {
    console.log(error);
  }
};

// Get Points Setting
const GetPointsSetting = async (req, res) => {
  try {
    const setting = await Setting.find();

    if (setting.length >= 0) {
      const settingData = setting.map((setting) => ({
        new_user_reward_points: setting.new_user_reward_points,
        correct_ans_reward_per_question:
          setting.correct_ans_reward_per_question,
        penalty_per_question: setting.penalty_per_question,
        self_challenge_mode: setting.self_challenge_mode,
        self_challenge_correct_ans_reward_per_question:
          setting.self_challenge_correct_ans_reward_per_question,
        self_challenge_penalty_per_question:
          setting.self_challenge_penalty_per_question,
      }));
      res.json({
        data: {
          success: 1,
          message: "point settings found",
          settingDetails: settingData,
          error: 0,
        },
      });
    } else {
      return res.json({
        data: { success: 0, message: "point settings not found", error: 1 },
      });
    }
  } catch (error) {
    console.log(error);
  }
};

// Get Plan
const GetPlans = async (req, res) => {
  try {
    const plans = await Plan.find().populate({
      path: "categoryGroup",
      select: "displayName", // 👈 sirf ye field aayegi
    });

    const planData = plans.map((plan) => ({
      _id: plan._id,
      planName: plan.planName,
      planValidity: plan.planValidity,
      planId: plan.planId,
      planType: plan.planType || '',
      features: plan.features || [],
      price: plan.price,
      categoryGroup: plan.categoryGroup,
    }));

    res.json({
      data: {
        success: 1,
        message: "Plans found successfully.",
        planDetails: planData,
        error: 0,
      },
    });
  } catch (error) {
    console.log(error);
    res.status(500).json({
      data: { success: 0, message: "Internal Server Error", error: 1 },
    });
  }
};

// Buy Plan
// const BuyPlan = async (req, res) => {
//     try {
//         const { userId, points, price, planId } = req.body;
//         const addPlan = new UserPlan({
//             userId: userId,
//             planId: planId,
//             points: points,
//             price: price
//         });
//         const savePlan = await addPlan.save();
//         if (savePlan) {
//             res.json({ "data": { "success": 1, "message": "Plan Buy Successfully..", "error": 0 } });
//         } else {
//                 return res.json({ "data": { "success": 0, "message": "Plan not buy", "error": 1 } });
//             }
//     } catch (error) {
//         console.log(error);
//         return res.status(500).json({ "data": { "success": 0, "message": "Internal Server Error", "error": 1 } });
//     }
// }

// Plan History
// const PlanHistory = async (req, res) => {
//   try {
//     const plan = await UserPlan.find({ userId: req.body.userId }).populate(
//       "userId",
//       "username phone image",
//     );
//     if (plan.length >= 0) {
//       const planData = plan.map((plans) => ({
//         _id: plans._id,
//         userDetails: plans.userId,
//         planId: plans.planId,
//         points: plans.points,
//         price: plans.price,
//       }));
//       res.json({
//         data: {
//           success: 1,
//           message: "Plan History found Successfully..",
//           planDetails: planData,
//           error: 0,
//         },
//       });
//     } else {
//       return res.json({
//         data: { success: 0, message: "Plan History not found", error: 1 },
//       });
//     }
//   } catch (error) {
//     console.log(error);
//     return res
//       .status(500)
//       .json({
//         data: { success: 0, message: "Internal Server Error", error: 1 },
//       });
//   }
// };

// [Points check and deduction removed: users can play quizzes without points]

// Start Quiz
const StartQuiz = async (req, res) => {
  try {
    // Extract questions from the request body
    const questions = req.body.questions;

    // Create an array to store question objects
    const questionDetails = [];

    const copyHistoryValue = (value) => {
      if (value && typeof value === "object" && !Array.isArray(value)) {
        return { ...value };
      }
      return value ?? "";
    };
    const cleanHistoryDescription = (value) => {
      const stripBr = (text) => String(text || "").replace(/<p><br><\/p>/g, "");
      if (value && typeof value === "object" && !Array.isArray(value)) {
        return {
          ...value,
          en: stripBr(value.en),
          hi: stripBr(value.hi),
        };
      }
      return stripBr(value);
    };

    // Iterate over each question and construct the question object
    for (const question of questions) {
      const option = question.option !== null ? question.option : {};
      const questionObject = {
        question_title: copyHistoryValue(question.question_title),
        image: question.image,
        audio: question.audio,
        question_type: question.question_type,
        subject: question.subject || "",
        chapter: question.chapter || "",
        option: option,
        answer: copyHistoryValue(question.answer),
        user_answer: question.user_answer,
        description: cleanHistoryDescription(question.description),
      };
      questionDetails.push(questionObject);
    }

    // Create the UserQuiz object with questionDetails array
    const userQuiz = new UserQuiz({
      userId: req.body.userId,
      quizId: req.body.quizId,
      questionDetails: questionDetails,
      total_questions: req.body.total_questions,
      correct_answers: req.body.correct_answers,
      wrong_answers: req.body.wrong_answers,
      score: req.body.score,
    });

    // Update the user's total questions, correct answers, and wrong answers
    await User.findByIdAndUpdate(req.body.userId, {
      $inc: {
        total_questions: req.body.total_questions,
        total_correct_answers: req.body.correct_answers,
        total_wrong_answers: req.body.wrong_answers,
      },
    });

    // Save the userQuiz object
    const saveQuiz = await userQuiz.save();

    if (saveQuiz) {
      // Populate the quiz details
      const populatedQuiz = await UserQuiz.findById(saveQuiz._id)
        .populate("quizId")
        .exec();

      if (populatedQuiz) {
        // Extract the necessary quiz details
        const quizDetails = {
          _id: populatedQuiz.quizId._id,
          categoryId: populatedQuiz.quizId.categoryId,
          name: populatedQuiz.quizId.name,
          image: populatedQuiz.quizId.image,
          timer_status: populatedQuiz.quizId.timer_status,
          minutes_per_quiz: populatedQuiz.quizId.minutes_per_quiz,
          description: normalizeQuizDescription(populatedQuiz.quizId?.description),
        };

        // Construct the response object
        const responseObject = {
          _id: saveQuiz._id,
          userId: saveQuiz.userId,
          quizDetails: quizDetails,
          questionDetails: saveQuiz.questionDetails,
          total_questions: saveQuiz.total_questions,
          correct_answers: saveQuiz.correct_answers,
          wrong_answers: saveQuiz.wrong_answers,
          score: saveQuiz.score,
        };

        return res.json({
          data: {
            success: 1,
            message: "Quiz added Successfully.",
            quizDetails: responseObject,
            error: 0,
          },
        });
      } else {
        return res.json({
          data: {
            success: 0,
            message: "Quiz details not found after saving",
            error: 1,
          },
        });
      }
    } else {
      return res.json({
        data: {
          success: 0,
          message: "Quiz not added",
          error: 1,
        },
      });
    }
  } catch (error) {
    console.error("Error during quiz start process:", error);
    return res.status(500).json({
      data: {
        success: 0,
        message: "Internal Server Error: " + error.message,
        error: 1,
      },
    });
  }
};

// Get Quiz History
const QuizHistory = async (req, res) => {
  try {
    const userRecord = await UserQuiz.find({
      userId: req.body.userId,
    }).populate(
      "quizId",
      "name categoryId image timer_status minutes_per_quiz description",
    );

    if (userRecord.length > 0) {
      const records = userRecord.map((record) => ({
        userId: record.userId,
        quizDetails: {
          ...record.quizId._doc,
          description: normalizeQuizDescription(record.quizId?.description),
        },
        questionDetails: record.questionDetails,
        total_questions: record.total_questions,
        correct_answers: record.correct_answers,
        wrong_answers: record.wrong_answers,
        score: record.score,
      }));

      return res.json({
        data: {
          success: 1,
          message: "quiz history found",
          historydetails: records,
          error: 0,
        },
      });
    } else {
      return res.json({
        data: { success: 0, message: "quiz history not found", error: 1 },
      });
    }
  } catch (error) {
    console.log(error);
  }
};

// Add Points
const AddPoints = async (req, res) => {
  try {
    pointValue = req.body.points;
    const addpoints = new Points({
      userId: req.body.userId,
      points: pointValue,
      description: req.body.description,
    });

    const savePoints = await addpoints.save();

    if (addpoints.points < 0) {
      const addNewPoint = await User.updateOne(
        { _id: addpoints.userId },
        { $inc: { points: pointValue } },
      );

      res.json({ data: { success: 1, message: "points removed", error: 0 } });
    } else if (addpoints.points > 0) {
      const updateUser = await User.updateOne(
        { _id: addpoints.userId }, // Use the user's _id here
        { $inc: { points: pointValue } },
      );

      res.json({ data: { success: 1, message: "points added", error: 0 } });
    } else {
      return res.json({
        data: { success: 0, message: "points not added", error: 1 },
      });
    }
  } catch (error) {
    console.log(error);
  }
};

// Get Points
const GetPoints = async (req, res) => {
  try {
    const pointsHistory = await Points.find({ userId: req.body.userId }).sort({
      createdAt: -1,
    });
    if (pointsHistory.length > 0) {
      const pointsData = pointsHistory.map((points) => ({
        userId: points.userId,
        points: points.points,
        description: points.description,
      }));
      return res.json({
        data: {
          success: 1,
          message: "points found",
          pointsDetails: pointsData,
          error: 0,
        },
      });
    } else {
      return res.json({
        data: { success: 0, message: "points not found", error: 1 },
      });
    }
  } catch (error) {
    console.log(error);
  }
};

// Get User Points
const LeaderBoard = async (req, res) => {
  try {
    const { quizId } = req.body;
    if (!quizId) {
      return res.status(400).json({
        data: { success: 0, message: "quizId is required", error: 1 },
      });
    }
    // Aggregate query to find users with the highest best score for the quiz
    const leaderboard = await UserQuiz.aggregate([
      {
        $match: { quizId: new (require("mongoose").Types.ObjectId)(quizId) },
      },
      {
        // Keep all displayed values from the same best attempt. Grouping each
        // field with $max can combine the score from one attempt with the
        // correct-answer count from another attempt.
        $sort: { userId: 1, correct_answers: -1, score: -1, createdAt: -1 },
      },
      {
        $group: {
          _id: "$userId",
          bestAttempt: { $first: "$$ROOT" },
        },
      },
      {
        $sort: { "bestAttempt.correct_answers": -1, "bestAttempt.score": -1 },
      },
      {
        $limit: 5,
      },
      {
        $lookup: {
          from: "users",
          localField: "_id",
          foreignField: "_id",
          as: "user",
        },
      },
      {
        $unwind: "$user",
      },
      {
        $project: {
          _id: "$user._id",
          firstname: "$user.firstname",
          lastname: "$user.lastname",
          image: { $ifNull: ["$user.image", ""] },
          points: "$bestAttempt.score",
          correct_answers: "$bestAttempt.correct_answers",
          total_questions: "$bestAttempt.total_questions",
          rank: 1,
        },
      },
    ]);

    if (leaderboard.length > 0) {
      // Set the rank for each user in the array
      leaderboard.forEach((user, index) => {
        user.rank = index + 1; // Rank starts from 1
      });
      // If users with best scores are found, return the details
      res.json({
        data: {
          success: 1,
          message: "Leaderboard found",
          user: leaderboard,
          error: 0,
        },
      });
    } else {
      // If no attempts found for the quiz, return appropriate message
      res.status(404).json({
        data: {
          success: 0,
          message: "No attempts found for this quiz",
          error: 1,
        },
      });
    }
  } catch (error) {
    console.log(error.message);
    res.status(500).json({
      data: {
        success: 0,
        message: "Internal Server Error",
        error: 1,
      },
    });
  }
};

// Get User Rank
const GetUserRank = async (req, res) => {
  try {
    console.log("GetUserRank called with body:", req.body);
    if (!req.body.userId) {
      console.log("userId missing in request body");
      return res.status(400).json({
        data: { success: 0, message: "userId is required", error: 1 },
      });
    }
    if (!require("mongoose").Types.ObjectId.isValid(req.body.userId)) {
      console.log("Invalid userId:", req.body.userId);
      return res
        .status(400)
        .json({ data: { success: 0, message: "Invalid userId", error: 1 } });
    }
    const { quizId } = req.body;
    const user = await User.findOne({ _id: req.body.userId });
    console.log("User found:", user);
    if (!user) {
      console.log("User not found for userId:", req.body.userId);
      return res
        .status(404)
        .json({ data: { success: 0, message: "User Not Found", error: 1 } });
    }
    if (!quizId) {
      const userPoints = user.points;
      const userRank =
        (await User.countDocuments({ points: { $gt: userPoints } })) + 1;
      console.log("User points:", userPoints, "User rank:", userRank);
      return res.json({
        data: {
          success: 1,
          message: "User found",
          user: {
            id: user._id,
            firstname: user.firstname,
            lastname: user.lastname,
            image: user.image ? user.image : "",
            points: userPoints,
            rank: userRank,
          },
          error: 0,
        },
      });
    }
    const quizObjectId = new (require("mongoose").Types.ObjectId)(quizId);
    const bestScores = await UserQuiz.aggregate([
      {
        $match: {
          userId: new (require("mongoose").Types.ObjectId)(req.body.userId),
          quizId: quizObjectId,
        },
      },
      {
        $sort: { correct_answers: -1, score: -1 },
      },
      {
        $group: { _id: null, bestCorrect: { $first: "$correct_answers" }, bestScore: { $first: "$score" } },
      },
    ]);
    if (bestScores.length === 0) {
      return res.status(404).json({
        data: { success: 0, message: "No attempt found for this quiz", error: 1 },
      });
    }
    const userBestCorrect = bestScores.length > 0 ? bestScores[0].bestCorrect : 0;
    const userBestScore = bestScores.length > 0 ? bestScores[0].bestScore : 0;
    const participantScores = await UserQuiz.aggregate([
      { $match: { quizId: quizObjectId } },
      { $sort: { correct_answers: -1, score: -1 } },
      { $group: { _id: "$userId", bestCorrect: { $first: "$correct_answers" }, bestScore: { $first: "$score" } } },
    ]);
    const totalParticipants = participantScores.length;
    const betterParticipants = participantScores.filter(
      (p) => Number(p.bestCorrect || 0) > Number(userBestCorrect || 0) ||
             (Number(p.bestCorrect || 0) === Number(userBestCorrect || 0) && Number(p.bestScore || 0) > Number(userBestScore || 0)),
    ).length;
    const lowerScoringParticipants = participantScores.filter(
      (p) => Number(p.bestCorrect || 0) < Number(userBestCorrect || 0) ||
             (Number(p.bestCorrect || 0) === Number(userBestCorrect || 0) && Number(p.bestScore || 0) < Number(userBestScore || 0)),
    ).length;
    const userRank = betterParticipants + 1;
    // A percentile is not meaningful with only one participant. Return null
    // until another user's result exists for this quiz.
    const percentile = totalParticipants <= 1
      ? null
      : (lowerScoringParticipants / totalParticipants) * 100;
    console.log(
      "User best score:",
      userBestScore,
      "User rank:",
      userRank,
    );
    return res.json({
      data: {
        success: 1,
        message: "User found",
        user: {
          id: user._id,
          firstname: user.firstname,
          lastname: user.lastname,
          image: user.image ? user.image : "",
          points: userBestScore,
          rank: userRank,
          percentile: percentile === null ? null : Number(percentile.toFixed(1)),
          totalParticipants,
        },
        error: 0,
      },
    });
  } catch (error) {
    console.error("GetUserRank error:", error);
    return res.status(500).json({
      data: { success: 0, message: "Internal Server Error", error: 1 },
    });
  }
};

// Add Favourite Quiz
const AddFavouriteQuiz = async (req, res) => {
  try {
    const addFavourite = new FavouriteQuiz({
      userId: req.body.userId,
      quizId: req.body.quizId,
    });
    const saveFavourite = await addFavourite.save();
    if (saveFavourite) {
      return res.json({
        data: {
          success: 1,
          message: "Favourite Quiz Added Successfully",
          error: 0,
        },
      });
    } else {
      return res.json({
        data: { success: 0, message: "Favourite Quiz Not Added", error: 1 },
      });
    }
  } catch (error) {
    return res.status(500).json({
      data: { success: 0, message: "Internal Server Error", error: 1 },
    });
  }
};

// Get Favourite Quiz
const GetFavouriteQuiz = async (req, res) => {
  try {
    const favouriteQuiz = await FavouriteQuiz.find({
      userId: req.body.userId,
    }).populate(
      "quizId",
      "quizId name categoryId image timer_status minutes_per_quiz description",
    );
    if (favouriteQuiz.length > 0) {
      const favouriteQuizData = favouriteQuiz.map((favourite) => ({
        userId: favourite.userId,
        quizId: {
          ...favourite.quizId._doc,
          description: normalizeQuizDescription(favourite.quizId?.description),
        },
      }));
      return res.json({
        data: {
          success: 1,
          message: "Favourite Quiz Found",
          favouriteQuiz: favouriteQuizData,
          error: 0,
        },
      });
    } else {
      return res.json({
        data: { success: 0, message: "Favourite Quiz Not Found", error: 1 },
      });
    }
  } catch (error) {
    return res.status(500).json({
      data: { success: 0, message: "Internal Server Error", error: 1 },
    });
  }
};

// Remove Favourite Quiz
const RemoveFavouriteQuiz = async (req, res) => {
  try {
    const removeFavourite = await FavouriteQuiz.deleteOne({
      userId: req.body.userId,
      quizId: req.body.quizId,
    });
    if (removeFavourite) {
      return res.json({
        data: {
          success: 1,
          message: "Favourite Quiz Removed Successfully",
          error: 0,
        },
      });
    } else {
      return res.json({
        data: { success: 0, message: "Favourite Quiz Not Removed", error: 1 },
      });
    }
  } catch (error) {
    return res.status(500).json({
      data: { success: 0, message: "Internal Server Error", error: 1 },
    });
  }
};

// Add Self Challange Quiz
const AddSelfChallangeQuiz = async (req, res) => {
  try {
    const quizId = req.body.quizId;
    const total_questions = req.body.total_questions;
    const timer = req.body.timer;

    const allQuestions = await Questions.find({ quizId: quizId });

    if (allQuestions.length > 0) {
      const randomQuestions = [];
      while (
        randomQuestions.length < total_questions &&
        allQuestions.length > 0
      ) {
        const randomIndex = Math.floor(Math.random() * allQuestions.length);
        randomQuestions.push(allQuestions.splice(randomIndex, 1)[0]);
      }
      return res.json({
        data: {
          success: 1,
          message: "Quiz successfully found",
          quizdetails: randomQuestions,
          error: 0,
        },
      });
    } else {
      return res.json({
        data: { success: 0, message: "Quiz not found", error: 1 },
      });
    }
  } catch (error) {
    // Internal Server Error
    return res.status(500).json({
      data: { success: 0, message: "Internal Server Error", error: 1 },
    });
  }
};

// Get Pages
const getPages = async (req, res) => {
  try {
    // Fetch all pages
    let pages = await Page.find();

    // Check if pages are found
    if (pages.length > 0) {
      // Process each page to return only required data
      const pagesData = pages.map((page) => ({
        _id: page._id,
        terms_and_conditions: page.terms_and_conditions,
        privacy_policy: page.privacy_policy,
        about_us: page.about_us,
      }));

      res.json({
        data: {
          success: 1,
          message: "Pages found successfully...!!",
          pagesDetails: pagesData,
          error: 0,
        },
      });
    } else {
      return res.json({
        data: { success: 0, message: "Pages not found...!!*", error: 1 },
      });
    }
  } catch (error) {
    console.log(error);
  }
};

// Get Notifications
const GetNotifications = async (req, res) => {
  try {
    const userdata = await User.findOne({ _id: req.body.userId });
    // compare the user created date with the current date
    const currentDate = new Date();
    const userCreatedDate = userdata.createdAt;

    // Compare the user created date with Notification Created Date
    const notifications = await CommonNotification.find({
      createdAt: { $gte: userCreatedDate },
    });
    if (notifications.length > 0) {
      const notificationData = notifications.map((notification) => ({
        _id: notification._id,
        title: notification.title,
        description: notification.description,
        image: notification.image || '',
        createdAt: notification.createdAt,
      }));
      res.json({
        data: {
          success: 1,
          message: "Notification found",
          notificationDetails: notificationData,
          error: 0,
        },
      });
    } else {
      return res.json({
        data: { success: 0, message: "Notification not found", error: 1 },
      });
    }
  } catch (error) {
    console.log(error);
  }
};

// Get quizzes by subcategory
const GetQuizBySubcategory = async (req, res) => {
  try {
    const { subcategoryId } = req.body;
    if (!subcategoryId) return res.status(400).json({ quizzes: [] });
    // Try subcategoryId first, then fall back to parent categoryId
    const quizzes = await Quiz.find({ subcategoryId, is_active: 1 }).sort({
      createdAt: -1,
    });
    const normalizedQuizzes = quizzes.map((q) => {
      const obj = q.toObject ? q.toObject() : { ...q };
      obj.description = normalizeQuizDescription(obj.description);
      return obj;
    });
    res.json({ quizzes: normalizedQuizzes });
  } catch (err) {
    res.status(500).json({ quizzes: [] });
  }
};

const getCategoryGroups = async (req, res) => {
  try {
    const groups = await CategoryGroup.find({}).populate("categories");
    res.json({ success: true, data: groups });
  } catch (err) {
    res.status(500).json({ success: false, error: err.message });
  }
};

// Set all users as verified on server start
(async () => {
  try {
    await User.updateMany({}, { $set: { is_verified: 1 } });
    console.log("All users set to is_verified: 1");
  } catch (err) {
    console.error("Failed to set all users as verified:", err);
  }
})();

const Razorpay = require("razorpay");
const crypto = require("crypto");

const razorpay = new Razorpay({
  key_id: process.env.RAZORPAY_KEY_ID,
  key_secret: process.env.RAZORPAY_KEY_SECRET,
});

// Referral settings with schema defaults (used when no Setting doc exists)
async function getReferralSettings() {
  const setting = await Setting.findOne();
  return {
    rewardPoints: setting ? setting.referral_reward_points || 0 : 0,
    discountPercent: setting ? setting.referral_discount_percent || 0 : 12,
    cashbackPercent: setting ? setting.referral_cashback_percent || 0 : 20,
  };
}

const buyPlan = async (req, res) => {
  try {
    const { planId } = req.body;
    const { id: userId } = req.user;

    if (!planId) {
      return res.status(400).json({
        success: false,
        message: "planId is required",
      });
    }

    const plan = await Plan.findById(planId);
    if (!plan) {
      return res.status(404).json({
        success: false,
        message: "Plan not found",
      });
    }

    const existingPlan = await UserPlan.findOne({
      userId,
      planStatus: "active",
    });

    // Check if user already has this specific content or all access
    if (existingPlan) {
      if (existingPlan.isSelectedAll) {
        return res.status(400).json({
          success: false,
          message: "You already have all-access plan",
        });
      }

      if (
        plan.categoryGroup &&
        existingPlan.categoryGroupIds.includes(plan.categoryGroup.toString())
      ) {
        return res.status(400).json({
          success: false,
          message: "You already have access to this test group",
        });
      }
    }

    const amount = plan.price;

    // ============================
    // 🎁 REFERRAL DISCOUNT
    // ============================
    let finalAmount = amount;
    const user = await User.findById(userId);
    if (user && user.referred_by) {
      const settings = await getReferralSettings();
      if (settings.discountPercent > 0) {
        finalAmount = Math.round((amount * (100 - settings.discountPercent)) / 100);
      }
    }

    // ============================
    // 🔐 RAZORPAY ORDER
    // ============================

    const amountInPaise = finalAmount * 100;

    const order = await razorpay.orders.create({
      amount: amountInPaise,
      currency: "INR",
      receipt: `receipt_${Date.now()}`,
      notes: {
        userId,
        planId: plan._id.toString(),
      },
    });

    res.json({
      success: true,
      orderId: order.id,
      amountInPaise,
      planId: plan._id,
    });
  } catch (err) {
    console.error("Buy Plan Error:", err);
    res.status(500).json({
      success: false,
      message: "Something went wrong",
    });
  }
};

const verifyPayment = async (req, res) => {
  try {
    const { razorpay_payment_id, razorpay_order_id, razorpay_signature } =
      req.body;

    const { id: userId } = req.user;

    // 🔐 Signature verify
    const body = razorpay_order_id + "|" + razorpay_payment_id;

    const expectedSignature = crypto
      .createHmac("sha256", process.env.RAZORPAY_KEY_SECRET)
      .update(body)
      .digest("hex");

    if (expectedSignature !== razorpay_signature) {
      return res.status(400).json({
        success: false,
        message: "Payment verification failed",
      });
    }

    // 📦 Fetch order to get notes
    const order = await razorpay.orders.fetch(razorpay_order_id);
    const planId = order.notes.planId;

    if (!planId) {
      return res.status(400).json({
        success: false,
        message: "Plan ID not found in order notes",
      });
    }

    const plan = await Plan.findById(planId);
    if (!plan) {
      return res.status(404).json({
        success: false,
        message: "Associated plan details not found",
      });
    }

    let userPlan = await UserPlan.findOne({ userId });

    if (!userPlan) {
      userPlan = new UserPlan({
        userId,
        categoryGroupIds: [],
      });
    }

    // ===============================
    // 🧠 ACTIVATE PLAN DATA
    // ===============================
    userPlan.planId = plan._id;
    userPlan.price = plan.price;

    if (!plan.categoryGroup) {
      // If plan has no specific categoryGroup, it's an "All Access" plan
      userPlan.isSelectedAll = true;
      // Optionally populate all category groups here or handle it in Auth logic
      const allGroups = await CategoryGroup.find({}, "_id");
      userPlan.categoryGroupIds = allGroups.map((g) => g._id);
    } else {
      // Direct access to specific category group
      const merged = new Set([
        ...(userPlan.categoryGroupIds || []).map((id) => id.toString()),
        plan.categoryGroup.toString(),
      ]);
      userPlan.categoryGroupIds = Array.from(merged);
    }

    userPlan.planStatus = "active";

    // ⏰ Expiry = 1 year (Lifetime plans never expire)
    if (plan.planValidity && plan.planValidity.toLowerCase().includes('lifetime')) {
      userPlan.expiresAt = null;
    } else {
      const expiryDate = new Date();
      expiryDate.setFullYear(expiryDate.getFullYear() + 1);
      userPlan.expiresAt = expiryDate;
    }

    await userPlan.save();

    // ===============================
    // 🎁 REFERRAL REWARD
    // ===============================
    const user = await User.findById(userId);
    if (user && user.referred_by && !user.referred_reward_credited) {
      const settings = await getReferralSettings();
      const referrer = await User.findById(user.referred_by);

      if (referrer) {
        const rewardPoints = settings.rewardPoints;

        if (rewardPoints > 0) {
          referrer.points = (referrer.points || 0) + rewardPoints;
          await referrer.save();

          await Points.create({
            userId: referrer._id,
            points: rewardPoints,
            description: "Referral Reward",
          });
        }

        // Mark referred reward as credited (one-time)
        user.referred_reward_credited = true;
        await user.save();
      }
    }

    // ===============================
    // 💸 REFERRAL CASHBACK (UPI)
    // ===============================
    if (user && user.referred_by && user.upi_id) {
      const settings = await getReferralSettings();
      const cashbackPercent = settings.cashbackPercent;

      if (cashbackPercent > 0) {
        const paidAmount = (order.amount || 0) / 100; // paise -> rupees
        const cashbackAmount = Math.round(paidAmount * cashbackPercent) / 100;
        const discountAmount = plan.price - paidAmount;

        // 🔁 Guard: only credit one cashback flow per referred purchase
        const existingCashback = await ReferralCashback.findOne({
          referrerId: user.referred_by,
          referredUserId: user._id,
          status: { $in: ['pending', 'paid'] },
        });

        if (!existingCashback) {
          await ReferralCashback.create({
            referrerId: user.referred_by,
            referredUserId: user._id,
            planId: plan._id,
            planName: plan.planName || 'Plan',
            planAmount: plan.price,
            discountAmount: Math.max(discountAmount, 0),
            paidAmount: paidAmount,
            cashbackPercent: cashbackPercent,
            cashbackAmount: cashbackAmount,
            status: 'pending',
          });

          console.log(
            `Referral cashback credited: referrer=${user.referred_by}, amount=₹${cashbackAmount}`
          );
        }
      }
    }

    res.status(200).json({
      success: true,
      message: "Payment verified & plan activated",
      expiresAt: expiryDate,
    });
  } catch (error) {
    console.error("Verify Payment Error:", error);
    res.status(500).json({
      success: false,
      message: "Payment verification failed",
    });
  }
};

const fetchUserPlan = async (req, res) => {
  try {
    const { id: userId } = req.user;

    const plan = await UserPlan.findOne({ userId })
      .populate("categoryGroupIds", "displayName")
      .populate("planId");

    if (!plan) {
      return res.json({
        success: true,
        isSelectedAll: false,
        categoryGroupIds: [],
        planStatus: "none",
      });
    }

    res.json({
      success: true,
      isSelectedAll: plan.isSelectedAll,
      categoryGroupIds: plan.categoryGroupIds,
      planId: plan.planId,
      planStatus: plan.planStatus,
      price: plan.price,
      expiresAt: plan.expiresAt,
    });
  } catch (error) {
    console.error("Fetch User Plan Error:", error);
    res.status(500).json({
      success: false,
      message: "Unable to fetch user plan",
    });
  }
};

const applyReferralCode = async (req, res) => {
  try {
    const { id: userId } = req.user;
    const { referralCode } = req.body;

    if (!referralCode || !referralCode.trim()) {
      return res.status(400).json({
        success: false,
        message: "Referral code is required",
      });
    }

    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({
        success: false,
        message: "User not found",
      });
    }

    if (user.referred_by) {
      return res.json({
        success: 0,
        message: "Referral code already applied",
      });
    }

    const code = referralCode.trim().toUpperCase();
    if (user.referral_code && user.referral_code.toUpperCase() === code) {
      return res.json({
        success: 0,
        message: "You cannot use your own referral code",
      });
    }

    const referrer = await User.findOne({ referral_code: code });
    if (!referrer) {
      return res.json({
        success: 0,
        message: "Invalid referral code",
      });
    }

    user.referred_by = referrer._id;
    await user.save();

    res.json({
      success: true,
      message: "Referral code applied successfully",
    });
  } catch (error) {
    console.error("Apply Referral Code Error:", error);
    res.status(500).json({
      success: false,
      message: "Unable to apply referral code",
    });
  }
};

const getReferralInfo = async (req, res) => {
  try {
    const { id: userId } = req.user;
    const user = await User.findById(userId);
    const settings = await getReferralSettings();

    if (!user) {
      return res.status(404).json({
        success: false,
        message: "User not found",
      });
    }

    const referralCode = await ensureReferralCode(user);

    res.json({
      success: true,
      referralCode: referralCode || "",
      rewardPoints: settings.rewardPoints,
      discountPercent: settings.discountPercent,
      cashbackPercent: settings.cashbackPercent,
      upiId: user.upi_id || "",
      hasReferrer: Boolean(user.referred_by),
    });
  } catch (error) {
    console.error("Get Referral Info Error:", error);
    res.status(500).json({
      success: false,
      message: "Unable to fetch referral info",
    });
  }
};

const saveUpiId = async (req, res) => {
  try {
    const { id: userId } = req.user;
    const { upiId } = req.body;

    if (!upiId || !upiId.trim()) {
      return res.status(400).json({
        success: false,
        message: "UPI ID is required",
      });
    }

    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({
        success: false,
        message: "User not found",
      });
    }

    user.upi_id = upiId.trim();
    await user.save();

    res.json({
      success: true,
      message: "UPI ID saved successfully",
      upiId: user.upi_id,
    });
  } catch (error) {
    console.error("Save UPI ID Error:", error);
    res.status(500).json({
      success: false,
      message: "Unable to save UPI ID",
    });
  }
};

const getReferralCashbacks = async (req, res) => {
  try {
    const { id: userId } = req.user;

    const cashbacks = await ReferralCashback.find({ referrerId: userId })
      .sort({ createdAt: -1 })
      .limit(50);

    const totalEarned = cashbacks
      .filter((c) => c.status === 'paid')
      .reduce((sum, c) => sum + (c.cashbackAmount || 0), 0);
    const totalPending = cashbacks
      .filter((c) => c.status === 'pending')
      .reduce((sum, c) => sum + (c.cashbackAmount || 0), 0);

    res.json({
      success: true,
      totalEarned: Math.round(totalEarned * 100) / 100,
      totalPending: Math.round(totalPending * 100) / 100,
      cashbacks: cashbacks.map((c) => ({
        _id: c._id,
        referredUserId: c.referredUserId,
        planName: c.planName,
        planAmount: c.planAmount,
        discountAmount: c.discountAmount,
        paidAmount: c.paidAmount,
        cashbackPercent: c.cashbackPercent,
        cashbackAmount: c.cashbackAmount,
        status: c.status,
        createdAt: c.createdAt,
      })),
    });
  } catch (error) {
    console.error("Get Referral Cashbacks Error:", error);
    res.status(500).json({
      success: false,
      message: "Unable to fetch referral cashbacks",
    });
  }
};

module.exports = {
  CheckRegisteredUser,
  SendOTP,
  Signup,
  GetUserOTP,
  UserVerification,
  SignIn,
  isVerifyAccount,
  resendOtp,
  ForgotPassword,
  GetForgotPasswordOTP,
  ForgotPasswordVerification,
  ChangePassword,
  EditUser,
  UploadImage,
  GetUser,
  GetCategories,
  GetIntro,
  GetBanner,
  GetQuizzes,
  GetQuizByCategory,
  GetQuestions,
  GetQuestionsByQuizId,
  DownloadQuizPdf,
  GetQuestionsByCategoryId,
  GetFeaturedCategory,
  GetAdsSettings,
  GetPointsSetting,
  GetPlans,
  // BuyPlan,
  //   PlanHistory,
  StartQuiz,
  QuizHistory,
  AddPoints,
  GetPoints,
  LeaderBoard,
  GetUserRank,
  AddFavouriteQuiz,
  GetFavouriteQuiz,
  RemoveFavouriteQuiz,
  AddSelfChallangeQuiz,
  getPages,
  GetNotifications,
  GetQuizBySubcategory,
  getCategoryGroups,
  buyPlan,
  verifyPayment,
  fetchUserPlan,
  getReferralInfo,
  saveUpiId,
  getReferralCashbacks,
  applyReferralCode,
};
