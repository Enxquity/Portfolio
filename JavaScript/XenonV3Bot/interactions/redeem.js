const Discord = require("discord.js")
const Mongo = require("mongoose")

const HWID = require("../schemes/hwid_schema.js")

module.exports = {
    name: "redeem",
    description: "Redeems a key",
    options: [
        {
            name: "key",
            description: "Paste the key you were given after purchase",
            type: 3,
            required: true
        }
    ],

    async run  (client, interaction, args) {

        //setTimeout(() => message.delete(), 500);

        let [KeySent]  = args
        //if (!KeySent) return message.channel.send("Please provide a key!").then(r => setTimeout(() => r.delete(), 2000))

        let HasKey = false

        HWID.findOne({UserId: interaction.user.id}, async (err, data) => {
            if (data) {
                HasKey = true
            }
        })

        HWID.findOne({Key: KeySent}, async (err, data) =>{
            if (!data) return interaction.reply("Invalid key.").then(r => setTimeout(() => interaction.deleteReply(), 2000)) // if theres no data then that means this aint no key
            if (data.UserId != 0) return interaction.reply("This key has already been used.").then(r => setTimeout(() => interaction.deleteReply(), 2000)) // lets check if its been used or not by determining the id.
            if (HasKey) return interaction.reply("You already have an existing key.").then(r => setTimeout(() => interaction.deleteReply(), 2000))

            var myquery = { Key: KeySent };
            var newvalues = { UserId: interaction.user.id };

            HWID.updateOne(myquery, newvalues, function(err, res) {
                if (err) return message.channel.send("XenonBot Error: " + err);
                interaction.reply("Redeemed!").then(r => setTimeout(() => interaction.deleteReply(), 2000))

                let whitelisted = interaction.guild.roles.cache.find(role => role.name === "Whitelisted");
                interaction.member.roles.add(whitelisted.id);

                client.channels.cache.get(`1068894416414183554`).send("```" + interaction.user.username + " (" + interaction.user.id + ") has redeemed the key " + KeySent + ".```");
            })
        })

    }  
   
}   