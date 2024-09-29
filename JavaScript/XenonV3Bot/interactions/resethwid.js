const Discord = require("discord.js")
const Mongo = require("mongoose")
const db = require("quick.db")

const HWID = require("../schemes/hwid_schema.js")

module.exports = {
    name: "resethwid",
    description: "Resets a hwid",
    options: [
        {
            name: "user",
            description: "Clears the HWID the user has set.",
            type: 6,
            required: true
        }
    ],

    async run  (client, interaction, args) {

        if(!interaction.member.permissions.has("MANAGE_MESSAGES")) return interaction.reply("You lack administrative permissions.");
        
        let [reset_member] = args
        reset_member = interaction.guild.members.cache.get(reset_member)

        HWID.findOne({UserId: reset_member.id}, async (err, data) => {
            if (!data) return interaction.reply("This user (<@"+reset_member.id+">) is not a buyer.")
            db.set(`shwid_${reset_member.id}`, (Date.now()-(43200000/2)));
            if (data.HWID == "") return interaction.reply("User (<@"+reset_member.id+">) had no HWID set, but i have reset their HWID timer.");

            var myquery = { UserId: reset_member.id };
            var newvalues = { HWID: "", IP: "" };

            HWID.updateOne(myquery, newvalues, function(err, res) {
                if (err) return interaction.reply("XenonBot Error: " + err);
                interaction.reply("Removed user (<@"+reset_member.id+">) HWID from database.")
            })
        })

    }
}