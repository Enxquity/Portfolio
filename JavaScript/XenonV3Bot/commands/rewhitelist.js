const Discord = require("discord.js")
const Mongo = require("mongoose")

const HWID = require("../schemes/hwid_schema.js")

module.exports = {
    name: "rewhitelist",
    description: "Checks for user in database and rewhitelists them if found.",

    async run  (client, message, args) {

        setTimeout(() => message.delete(), 500);

        let re_m = message.mentions.members.first();
        if (!re_m) return message.channel.send("No user mentioned.").then(r => setTimeout(() => r.delete(), 5000))

        if (re_m.roles.cache.some(role => role.name === 'Whitelisted')) {
            message.channel.send("User is already whitelisted.")
        } else {
            HWID.findOne({UserId: re_m.id}, async (err, data) => {
                if (data) {
                    message.channel.send(re_m.user.username + " is a buyer.")
                    let whitelisted = re_m.guild.roles.cache.find(role => role.name === "Whitelisted");
                    re_m.roles.add(whitelisted.id);

                    re_m.send("You have been re-whitelisted due to being a previous buyer by: " + message.member.user.username + ". Your key was: " + data.Key)
                } else {
                    message.channel.send(re_m.user.username + " is not a buyer.")
                }
            })
        }
    }  
   
}   