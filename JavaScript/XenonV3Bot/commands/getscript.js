const Discord = require("discord.js")
const Mongo = require("mongoose")

const HWID = require("../schemes/hwid_schema.js")

module.exports = {
    name: "getscript",
    description: "DM's you the script",

    async run  (client, message, args) {

        setTimeout(() => message.delete(), 500);

        
        HWID.findOne({UserId: message.member.id}, async (err, data) => {
            if (!data) return message.channel.send("This user is not a buyer.").then(r => setTimeout(() => r.delete(), 2000))
            if (data.HWID == "") return message.channel.send("This user has no set HWID.").then(r => setTimeout(() => r.delete(), 2000))

            let currentHWID = data.HWID

            let hwidPart1 = currentHWID.slice(0,(currentHWID.length/2))
            let hwidPart2 = currentHWID.slice((currentHWID.length/2), currentHWID.length)

            message.author.send('```lua\n_G.Settings = {\n    ["HideName"] = false,\n    ["HidePicture"] = false,\n\n    ["Auto Hopping"] = {\n        ["Hop Time"] = 30,\n        ["Min"] = 4,\n        ["Max"] = 9,\n        ["Random"] = true\n    }\n}\n\nif _G.Settings["Auto Hopping"].Random then\n    getgenv().HopCount = math.random(_G.Settings["Auto Hopping"].Min, _G.Settings["Auto Hopping"].Max)\nelse\n    getgenv().HopCount = _G.Settings["Auto Hopping"].Min\nend\n\n_G.Theme = "Aqua"\n-- Current themes: "Aqua", "UltraDark" (default), "Original" (original xenon ui theme)\n_G.FixLag = true\n_G.key1 =  "' + hwidPart1 + '"\n_G.key2 = "' + hwidPart2 + '"\n\nloadstring(game:HttpGet("https://raw.githubusercontent.com/Vezise/vezzyscripts/main/xenonv1_31", true))()```')
            message.channel.send("I have sent you the script via dms.").then(r => setTimeout(() => r.delete(), 2000))
        })

    }
}