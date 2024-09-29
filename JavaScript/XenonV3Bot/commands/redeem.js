const Discord = require("discord.js")
const Mongo = require("mongoose")

const HWID = require("../schemes/hwid_schema.js")

module.exports = {
    name: "redeem",
    description: "Redeems a key",

    async run  (client, message, args) {

        setTimeout(() => message.delete(), 500);

        let Args =  message.content.split(" ").slice(1)
        let KeySent  = Args[0]  
        if (!KeySent) return message.channel.send("Please provide a key!").then(r => setTimeout(() => r.delete(), 2000))

        let HasKey = false

        HWID.findOne({UserId: message.member.id}, async (err, data) => {
            if (data) {
                HasKey = true
            }
        })

        HWID.findOne({Key: KeySent}, async (err, data) =>{
            if (!data) return message.channel.send("Invalid key.").then(r => setTimeout(() => r.delete(), 2000)) // if theres no data then that means this aint no key
            if (data.UserId != 0) return message.channel.send("This key has already been used.").then(r => setTimeout(() => r.delete(), 2000)) // lets check if its been used or not by determining the id.
            if (HasKey) return message.channel.send("You already have an existing key.").then(r => r.delete( { timeout: 2000 } ))

            var myquery = { Key: KeySent };
            var newvalues = { UserId: message.member.id };

            HWID.updateOne(myquery, newvalues, function(err, res) {
                if (err) return message.channel.send("XenonBot Error: " + err);
                message.channel.send("Redeemed!").then(r => setTimeout(() => r.delete(), 2000))

                let whitelisted = message.guild.roles.cache.find(role => role.name === "Whitelisted");
                message.member.roles.add(whitelisted.id);

                client.channels.cache.get(`1068894416414183554`).send("```" + message.member.user.username + " (" + message.member.id + ") has redeemed the key " + KeySent + ".```");
            })
        })

    }  
   
}   