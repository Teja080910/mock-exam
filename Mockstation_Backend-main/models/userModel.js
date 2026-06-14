const mongoose = require("mongoose");
const userSchema = new mongoose.Schema ({
    firstname:{
        type:String,
        required:false
    },
    lastname:{
        type:String,
        required:false
    },
    username:{
        type:String,
        required:false
    },
    countryCode:{
        type:String
    },
    phone:{
        type:String
    },
    email:{
        type:String,
        required:true
    },
    password:{
        type:String,
        required:false
    },
    image:{
        type:String
    },
    points:{
        type:Number
    },
    total_questions:{
        type:Number
    },
    total_correct_answers:{
        type:Number
    },
    total_wrong_answers:{
        type:Number
    },
    is_verified:{
        type:Number,
        default:0
    },
    is_google_user: {
        type: Boolean,
        default: false
    },
    active:{
        type:Boolean,
        default:true
    }
},
{ timestamps: true });

module.exports = mongoose.model('User',userSchema);
