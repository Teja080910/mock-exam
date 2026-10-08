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
    },
    // Optional URL opened when the user taps this notification in the app.
    link:{
        type:String,
        default:''
    },
    // Optional in-app destination page: plans | current_affairs | news | books | notes
    screen:{
        type:String,
        default:''
    }
},

{ timestamps: true });



module.exports = mongoose.model('commonNotification',allusernotificationSchema);