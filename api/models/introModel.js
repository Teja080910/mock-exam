const mongoose = require("mongoose");
const introSchema = new mongoose.Schema ({

    title:{
        type:String,
        required:true
    },
    image:{
        type:String,
        required:true
    },
    description:{
        type:String,
        required:true
    },
    is_active:{
        type:Number,
        default:0
    },
    // Sale discounts shown on the app subscription page while this offer is
    // the newest active one. Empty = no plan discounts.
    discounts:[
        {
            _id:false,
            planId:{
                type:mongoose.Schema.Types.ObjectId,
                ref:'Plan'
            },
            discountPercent:{
                type:Number,
                default:0
            }
        }
    ]
},

{ timestamps: true });

module.exports = mongoose.model('Intro',introSchema);
