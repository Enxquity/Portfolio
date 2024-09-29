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
    name: "new",
    description: "Creates a new key",

    async run  (client, message, args) {

        setTimeout(() => message.delete(), 500);

        let is_good_user = (message.member.id == 1058570661611720825 || message.member.id == 932714600691015711)
        
        if (is_good_user == false) {	
            message.reply("You cannot create keys.").then(r => setTimeout(() => r.delete(), 5000))
            return;
        }

        let Args =  message.content.split(" ").slice(1)
        let Key  = Args[0]

        if (!Key) {
            const filter = (m) => m.author.id === message.author.id;

            message.channel.send("No key was provided, please provide a number of keys to generate or type 'cancel' to cancel this command. (this will expire in 10 seconds)").then(r => setTimeout(() => r.delete(), 10000))
            
            message.channel.awaitMessages({filter: filter, time: 10000, max: 1}).then(collected =>{

                if (collected.first().content === "cancel") {
                    message.channel.send("Canceled.").then(r => setTimeout(() => r.delete(), 2000))
                    return;
                }

                let amount = collected.first().content
                var keys = "";
                var i = 0;

                if (!isNaN(amount)) {

                    amount = Number(amount)

                    for (i = 0; i < amount; i++) {
                        let randomKey = randomString(16, '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ');

                        keys = (keys + randomKey + "\n")

                        HWID.findOne({Key: randomKey}, async (err, data) => {
                            if (!data) {
                                const NewData = new HWID({
                                    _id: Mongo.Types.ObjectId(),
                                    Key: randomKey,
                                    HWID: "",
                                    UserId: 0
                                })

                                NewData.save()

                            } else {
                                message.channel.send("Failed to create key '" + randomKey + "' due to it already being a key.").then(r => setTimeout(() => r.delete(), 10000))
                            }
                        });
                    }

                    message.channel.send("```\n" + keys + "\n```")

                    log_client.send({
                        username: message.author.username,
                        avatarURL: message.author.displayAvatarURL(),
                        content: ("```\n" + keys + "\n```")
                    })


                }else{
                 message.channel.send("Failed to catch number, make sure you didnt provide a string.").then(r => setTimeout(() => r.delete(), 2000))
                }

            }).catch(err => {
                message.channel.send("You timed out.").then(r => setTimeout(() => r.delete(), 2000))
            })

            return;
        }

        HWID.findOne({Key: Key}, async (err, data) =>{  
            if (data) return message.channel.send("This is already a key.")

            const NewData = new HWID({
                _id: Mongo.Types.ObjectId(),
                Key: Key,
                HWID: "",
                UserId: 0
            })

            NewData.save()

            message.channel.send("Added key succesfully!").then(r => setTimeout(() => r.delete(), 2000))
        })
     
    }
}