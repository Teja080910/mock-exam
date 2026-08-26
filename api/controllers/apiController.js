require("dotenv").config();
const nodemailer = require("nodemailer");
const otpgenerator = require("otp-generator");
const sha256 = require("sha256");
const jwt = require("jsonwebtoken");
//const hbs = require('nodemailer-express-handlebars');
const path = require("path");
const sendinBlue = require("sendinblue-api");
var randomstring = require("randomstring");
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
const admin = require("../config/firebase");
const SMTP = require("../models/smtpModel");
const CategoryGroup = require("../models/categoryGroupModel");

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

    const userData = new User({
      firstname: req.body.firstname,
      lastname: req.body.lastname,
      username: req.body.username,
      email: req.body.email,
      password: pass,
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
      userId: userEmail._id,
      deviceId: deviceId,
    });

    if (findUserDevice) {
      findUserDevice.registration_token = registrationToken;
      findUserDevice.is_active = 1;
      await findUserDevice.save();
    } else {
      await Notification.create({
        userId: userEmail._id,
        registrationToken: registrationToken,
        deviceId: deviceId,
        is_active: 1,
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

    let userDevice = await Notification.findOne({ userId: user._id, deviceId });

    if (userDevice) {
      userDevice.registration_token = registrationToken;
      userDevice.is_active = 1;
      await userDevice.save();
    } else {
      console.log("Device and user not matched or no device found");
      userDevice = new Notification({
        userId: user._id,
        registrationToken,
        deviceId,
        is_active: 1,
      });
      await userDevice.save();
    }

    const username = user.name;
    const title = `Hey, ${username}`;
    const body = "You are SignIn Successfully...!!";
    sendPushNotification(registrationToken, title, body);

    const token = jwt.sign({ id: user._id }, process.env.JWT_SECRET, {
      expiresIn: "7d",
    });
    console.log("token", token);
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
    const editUser = await User.findByIdAndUpdate(id, {
      firstname: req.body.firstname,
      lastname: req.body.lastname,
      countryCode: req.body.countryCode,
      phone: req.body.phone,
      image: req.body.image,
    });
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
      "quizId name categoryId image timer_status minutes_per_quiz description",
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
              description: banners.quizId.description
                ? banners.quizId.description.replace(/<p><br><\/p>/g, "")
                : "",
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
            description: quiz.description
              ? quiz.description.replace(/<p><br><\/p>/g, "")
              : "",
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
            description: quiz.description
              ? quiz.description.replace(/<p><br><\/p>/g, "")
              : "",
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
        quizId: {
          _id: question.quizId?._id || null,
          timer_status: question.quizId?.timer_status,
          minutes_per_quiz: question.quizId?.minutes_per_quiz,
          correct_ans_reward_per_question:
            question.quizId?.correct_ans_reward_per_question,
          penalty_per_question: question.quizId?.penalty_per_question,
          name: question.quizId?.name,
          image: question.quizId?.image,
          description: question.quizId?.description
            ? String(question.quizId.description).replace(/<p><br><\/p>/g, "")
            : "",
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
                description: quiz.description
                  ? quiz.description.replace(/<p><br><\/p>/g, "")
                  : "",
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

    // Iterate over each question and construct the question object
    for (const question of questions) {
      const option = question.option !== null ? question.option : {};
      const questionObject = {
        question_title: question.question_title,
        image: question.image,
        audio: question.audio,
        question_type: question.question_type,
        option: option,
        answer: question.answer,
        user_answer: question.user_answer,
        description: question.description
          ? question.description.replace(/<p><br><\/p>/g, "")
          : "",
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
          description: populatedQuiz.quizId.description
            ? populatedQuiz.quizId.description.replace(/<p><br><\/p>/g, "")
            : "",
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
          description: record.quizId.description
            ? record.quizId.description.replace(/<p><br><\/p>/g, "")
            : "",
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
        $group: { _id: "$userId", bestScore: { $max: "$score" } },
      },
      {
        $sort: { bestScore: -1 },
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
          points: "$bestScore",
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
    const bestScore = await UserQuiz.aggregate([
      {
        $match: {
          userId: new (require("mongoose").Types.ObjectId)(req.body.userId),
          quizId: new (require("mongoose").Types.ObjectId)(quizId),
        },
      },
      {
        $group: { _id: null, bestScore: { $max: "$score" } },
      },
    ]);
    const userBestScore = bestScore.length > 0 ? bestScore[0].bestScore : 0;
    const userRank =
      (await UserQuiz.aggregate([
        {
          $match: { quizId: new (require("mongoose").Types.ObjectId)(quizId) },
        },
        {
          $group: { _id: "$userId", bestScore: { $max: "$score" } },
        },
        {
          $match: { bestScore: { $gt: userBestScore } },
        },
        {
          $count: "count",
        },
      ]))[0]?.count + 1 || 1;
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
          description: favourite.quizId.description
            ? favourite.quizId.description.replace(/<p><br><\/p>/g, "")
            : "",
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
    res.json({ quizzes });
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
    // 🔐 RAZORPAY ORDER
    // ============================

    const amountInPaise = amount * 100;

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

    // ⏰ Expiry = 1 year
    const expiryDate = new Date();
    expiryDate.setFullYear(expiryDate.getFullYear() + 1);
    userPlan.expiresAt = expiryDate;

    await userPlan.save();

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
};
