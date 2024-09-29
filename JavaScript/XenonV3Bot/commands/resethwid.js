const Discord = require("discord.js")
const Mongo = require("mongoose")
const db = require("quick.db")

const HWID = require("../schemes/hwid_schema.js")

module.exports = {
    name: "resethwid",
    description: "Resets a hwid",

    async run  (client, message, args) {

        if(!message.member.permissions.has("MANAGE_MESSAGES")) return message.reply("You lack administrative permissions.");
        
        let reset_member = message.mentions.members.first();
        if (!reset_member) return message.channel.send("No user mentioned.")

        HWID.findOne({UserId: reset_member.id}, async (err, data) => {
            if (!data) return message.channel.send("This user (<@"+message.member.id+">) is not a buyer.")
            db.set(`shwid_${reset_member.id}`, (Date.now()-(43200000/2)));
            if (data.HWID == "") return message.reply("User (<@"+message.member.id+">) had no HWID set, but i have reset their HWID timer.");

            var myquery = { UserId: reset_member.id };
            var newvalues = { HWID: "" };

            HWID.updateOne(myquery, newvalues, function(err, res) {
                if (err) return message.channel.send("XenonBot Error: " + err);
                message.channel.send("Removed user (<@"+message.member.id+">) HWID from database.")
            })
        })

    }
}