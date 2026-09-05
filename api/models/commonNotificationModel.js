const mongoose = require("mongoose");
const allusernotificationSchema = new mongoose.Schema ({
    
    title:{
        type:String,
        required:true
    },
    description:{
        type:String,
        required:true
    },
    image:{
        type:String,
        default:''
    }
},

{ timestamps: true });



module.exports = mongoose.model('commonNotification',allusernotificationSchema);