const User = require("../models/userModel");
const jwt = require("jsonwebtoken");

const AuthMiddleware = async (req, res, next) => {
  let token;

  if (req.headers?.authorization?.startsWith("Bearer")) {
    token = req.headers.authorization.split(" ")[1];

    try {
      if (!token) {
        return res
          .status(401)
          .json({ message: "Token missing, please login again" });
      }

      const decoded = jwt.verify(token, process.env.JWT_SECRET);

      const user = await User.findById(decoded.id);

      if (!user) {
        return res
          .status(401)
          .json({ message: "User not found, invalid token" });
      }

      req.user = user;
      next();
    } catch (error) {
      return res.status(401).json({
        message: "Not Authorized token, Please Login again",
      });
    }
  } else {
    return res.status(401).json({
      message: "Authorization header missing, Please Login",
    });
  }
};

module.exports = AuthMiddleware;
