const Discord = require("discord.js")
const Mongo = require("mongoose")

const HWID = require("../schemes/hwid_schema.js")

const log_client = new Discord.WebhookClient({
    id: "873309707643785258", 
    token: "UyzzdXmjUQsMkZaJLKQaKitJZKc1TsM1kpaFhZf_WLJqTDeM63KvyKfp5MGVyTJ9SJoy"
});

function randomString(length, chars) {
    var result = '';
    for (var i = length; i > 0; --i) result += chars[Math.floor(Math.random() * chars.length)];
    return result;
}

module.exports = {
    name: "trial",
    description: "Creates a new key",

    async run  (client, message, args) {

        setTimeout(() => message.delete(), 500);
        
        //return message.reply("The trial is not currently on.")
        
        let randomKey = "trial-" + randomString(8, '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ');
        let HasKey = false

        HWID.findOne({UserId: message.member.id}, async (err, data) => {
            if (data) {
                HasKey = true
            }
        })
        
        HWID.findOne({Key: randomKey}, async (err, data) => {
            if (HasKey) return message.channel.send("You already have an existing key.").then(r => setTimeout(() => r.delete(), 3500))
            if (!data) {
                const NewData = new HWID({
                    _id: Mongo.Types.ObjectId(),
                    Key: randomKey,
                    HWID: "",
                    UserId: message.member.id
                })
                NewData.save()
                let trial = message.guild.roles.cache.find(role => role.name === "Trial Whitelist");
                message.member.roles.add(trial.id);
                message.author.send("You are now on trial period, your trial key will be valid until 06/06/2022")
            } else {
                message.channel.send("Failed to create key '" + randomKey + "' due to it already being a key.").then(r => setTimeout(() => r.delete(), 10000))
            }
        });
    }
}