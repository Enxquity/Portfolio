const Discord = require("discord.js")
const Mongo = require("mongoose")
const db = require("quick.db")
const ms = require("ms")

const HWID = require("../schemes/hwid_schema.js")

function randomString(length, chars) {
    var result = '';
    for (var i = length; i > 0; --i) result += chars[Math.floor(Math.random() * chars.length)];
    return result;
}

module.exports = {
    name: "sethwid",
    description: "Sets a HWID",

    async run  (client, message, args) {

        setTimeout(() => message.delete(), 500);

        let cooldown = 43200000/2; // 6 hours in ms

        let lastSet = await db.fetch(`shwid_${message.author.id}`);
      
        if (lastSet !== null && cooldown - (Date.now() - lastSet) > 0) {
          let timeObj = ms(cooldown - (Date.now() - lastSet)); // timeObj.hours = 12
          message.reply(`Please wait another ${timeObj} before setting your HWID again.`).then(r => setTimeout(() => r.delete(), 15000))
        
          return;
        }

        let Args =  message.content.split(" ").slice(1)
        let HwidSent = Args[0]
        if (!HwidSent) return message.channel.send("Please provide a HWID!").then(r => setTimeout(() => r.delete(), 2000))
        if (HwidSent.length < 6) return message.channel.send("Your HWID is too short.").then(r => setTimeout(() => r.delete(), 2000))
        if (HwidSent.toLowerCase().includes("loadstring") | HwidSent.toLowerCase().includes("httpget") | HwidSent.toLowerCase().includes("github") | HwidSent.toLowerCase().includes("true") | HwidSent.toLowerCase().includes(":") | HwidSent.toLowerCase().includes("game")) return message.channel.send("Your HWID contains a script, please make sure you aren't trying to set it as the identifier copier script.").then(r => setTimeout(() => r.delete(), 2000))

        HWID.findOne({UserId: message.member.id}, async (err, data) => {
            /*
            if (data) {
                if (data.HWID != "") {
                    message.channel.send("You already have a HWID set. Please DM a mod or the owner to reset it.").then(r => setTimeout(() => r.delete(), 2000))
                    return;
                }
            }*/

            if (!data) {
                /*
                if(!message.member.roles.cache.some(role => role.name === 'Whitelisted')) {
                    message.channel.send("You are not whitelisted.")
                } else {
    
                    var randomKey = randomString(16, '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ');
                    const NewData = new HWID({
                        _id: Mongo.Types.ObjectId(),
                        Key: randomKey,
                        HWID: "",
                        UserId: message.author.id
                    })
    
                    NewData.save()
    
                    message.channel.send("Due to us moving to a new and improved bot, we now have a fresh database; however do not worry, we have moved your current key into our new system, you can now reuse the command. I also sent your new key in your dms!").then(r => r.delete({timeout: 17500}))
                    message.author.send("```\n" + randomKey + "\n```")
                }*/
                
                message.channel.send("You are not whitelisted.")
                return;
            }

            var myquery = { UserId: message.member.id };
            var newvalues = { HWID: HwidSent };

            HWID.updateOne(myquery, newvalues, function(err, res) {
                if (err) return message.channel.send("XenonBot Error: " + err);
                message.channel.send("Set.").then(r => setTimeout(() => r.delete(), 2000))
                db.set(`shwid_${message.author.id}`, Date.now());
            })
        }).catch(err => {
            message.channel.send("XenonBot: I just caught an error! - " + err)
        })
    }
}