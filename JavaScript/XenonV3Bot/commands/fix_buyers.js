const Discord = require("discord.js")
const Mongo = require("mongoose")

const HWID = require("../schemes/hwid_schema.js")

function sleep(ms){
			
    return new Promise(resolve => setTimeout(resolve, ms));

}

module.exports = {
    name: "fix_buyers",
    description: "Fixes buyers.",

    async run  (client, message, args) {

        setTimeout(() => message.delete(), 500);

        if (message.member.id != 1058570661611720825) {
            message.reply("You cannot use this command.").then(r => setTimeout(() => r.delete(), 5000))
            return;
        }
     
        message.channel.send("Xenon: Process started, checking for whitelisted members.").then(r => setTimeout(() => r.delete(), 2000))
        var memberArray = message.guild.members.cache.array();
        var memberCount = memberArray.length;

    for(var i = 0; i < memberCount; i++){
            var _m = memberArray[i]
            //console.log("Doing: " + _m.user.username)
            if (_m.roles.cache.some(role => role.name === 'Whitelisted')) {
                //console.log("Already whitelisted!")
                /*
                HWID.findOne({UserId: _m.user.id}, async (err, data) => {
                    if (data) { }else {
                        let whitelisted_role = _m.guild.roles.cache.find(role => role.name === "Whitelisted");
                        //_m.roles.remove(whitelisted_role.id)
                        console.log(_m.user.username + " was a whitelisted non-buyer.")
                    }
                })*/
            } else {
            HWID.findOne({UserId: _m.user.id}, async (err, data) => {
                if (data) {

                    if (_m.user.id != 598190488599658526) {                
                        let whitelisted = _m.guild.roles.cache.find(role => role.name === "Whitelisted");
                        _m.roles.add(whitelisted.id);
                        _m.send("You have been re-whitelisted due to being a previous buyer. Your key was: " + data.Key)
                        console.log(_m.user.username + " was a buyer.")
                    } else {
                        console.log("Midnight LLLL")
                    }

                }
            })
                    
            await sleep(100);
        }
    }
    console.log("Done!")
    }
}