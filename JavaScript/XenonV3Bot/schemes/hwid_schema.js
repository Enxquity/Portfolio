const Mongo = require("mongoose");

const HWIDSchema = Mongo.Schema({
    _id: Mongo.Schema.Types.ObjectId,
    Key: String,
    HWID: String,
    UserId: Number,
    IP: String
})

module.exports = Mongo.model("HWID", HWIDSchema);