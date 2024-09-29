const Discord = require("discord.js")
const Mongo = require("mongoose")

const HWID = require("../schemes/hwid_schema.js")

module.exports = {
    name: "rewhitelist",
    description: "Checks for user in database and rewhitelists them if found.",
    options: [
        {
            name: "user",
            description: "User to rewhitelist",
            type: 6,
            required: true
        }
    ],

    async run  (client, interaction, args) {

        //setTimeout(() => message.delete(), 500);

        let [re_m] = args;
        re_m = interaction.guild.members.cache.get(re_m)
        if (!re_m) return interaction.reply("No user mentioned.").then(r => setTimeout(() => interaction.deleteReply(), 5000))

        if (re_m.roles.cache.some(role => role.name === 'Whitelisted')) {
            interaction.reply("User is already whitelisted.")
        } else {
            HWID.findOne({UserId: re_m.id}, async (err, data) => {
                if (data) {
                    interaction.reply(re_m.user.username + " is a buyer.")
                    let whitelisted = interaction.guild.roles.cache.find(role => role.name === "Whitelisted");
                    re_m.roles.add(whitelisted.id);

                    re_m.send("You have been re-whitelisted due to being a previous buyer by: " + interaction.user.username + ". Your key was: " + data.Key)
                } else {
                    interaction.reply(re_m.user.username + " is not a buyer.")
                }
            })
        }
    }  
   
}   