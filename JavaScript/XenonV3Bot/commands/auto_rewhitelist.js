const Discord = require("discord.js")
const Mongo = require("mongoose")

const HWID = require("../schemes/hwid_schema.js")

const BotStart = Date.now();
function xenon_log(message) {
    console.log("(" + (Date.now()-BotStart) + "ms since bot start) XenonBot: " + message)
}

module.exports = {
    name: "auto_rewhitelist",
    description: "Checks for user in database and rewhitelists them if found.",

    async run  (client, re_m) {
        if (re_m.roles.cache.some(role => role.name === 'Whitelisted')) {
        } else {
            HWID.findOne({UserId: re_m.id}, async (err, data) => {
                if (data) {
                    let whitelisted = re_m.guild.roles.cache.find(role => role.name === "Whitelisted");
                    re_m.roles.add(whitelisted.id);

                    re_m.send("You have been re-whitelisted due to being a previous buyer by: Xenon. Your key was: " + data.Key)
                    re_m.send("This key is automatically redeemed to your account and is proof of purchase in case of database failure.")
                    
                    xenon_log("User: " + re_m.user.username + " has joined and automatically been rewhitelisted with the key: " + data.Key + ".")
                } else {
                    xenon_log("User: " + re_m.user.username + " has joined and is not a buyer.");
                }
            })
        }
    }  
   
}   