const Discord = require("discord.js")
const Mongo = require("mongoose")

const HWID = require("../schemes/hwid_schema.js")

module.exports = {
    name: "blacklist",
    description: "Blacklists a user",
    options: [
        {
            name: "user",
            description: "User to blacklist",
            type: 6,
            required: true
        }
    ],

    async run  (client, interaction, args) {
        if(!interaction.member.permissions.has("ADMINISTRATOR")) return interaction.reply("You lack administrative permissions.");

        let [reset_member] = args
        reset_member = interaction.guild.members.cache.get(reset_member)

        if (reset_member.permissions.has("ADMINISTRATOR")) return interaction.reply("You cannot blacklist administrators.");

        var HasKey = false

        await HWID.findOne({UserId: interaction.user.id}, async (err, data) => {
            if (data) {
                HasKey = true
            }
        })
        if (HasKey == false) return interaction.reply("This user does not have a key");

        var myquery = { UserId: reset_member.id };
        var newvalues = { HWID: `blacklisted_${reset_member.id}`, UserId: (00000000000000000 + Math.random() * 1000000000)};

        HWID.updateOne(myquery, newvalues, function(err, res) {
            if (err) return interaction.reply("XenonBot Error: " + err);
            let whitelisted = interaction.guild.roles.cache.find(role => role.name === "Whitelisted");
            reset_member.roles.remove(whitelisted.id);
            interaction.reply("Blacklisted user (<@"+reset_member.id+">).")
        })
    }  
}   