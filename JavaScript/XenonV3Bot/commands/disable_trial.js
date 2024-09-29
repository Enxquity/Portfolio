const Discord = require("discord.js")
const Mongo = require("mongoose")

const HWID = require("../schemes/hwid_schema.js")

module.exports = {
    name: "disable_trial",
    description: "Disables trial and deletes all trial keys.",

    async run  (client, message, args) {

        setTimeout(() => message.delete(), 500);
        
        let is_good_user = (message.member.id == 925172777135255663 || message.member.id == 270183168609353728 || message.member.id == 932714600691015711)
        
        if (is_good_user == false) {	
            message.reply("You cannot use this command.").then(r => setTimeout(() => r.delete(), 5000))
            return;
        }

        let R = 0;
        for (let i=0; i < 200; i++) {
            HWID.findOneAndRemove({Key: {$regex: "trial-"}}, async (err, data) => {
                if (data) {
                    R++
                    return R; 
                }
            });
        }
        setTimeout(function() {
            message.channel.send("Done! - Removed: " + R);
        }, 2000) 
        
        const Role = message.guild.roles.cache.find(role => role.name === "Trial Whitelist");
        Role.members.forEach((member, i) => {
            setTimeout(() => {
                member.roles.remove(Role);
            }, i * 1000);
        });
    }  
   
}   