const Discord = require("discord.js")
const Mongo = require("mongoose")

const HWID = require("../schemes/hwid_schema.js")

module.exports = {
    name: "v1",
    description: "DM's you the script",

    async run  (client, message, args) {

        HWID.findOne({UserId: message.member.id}, async (err, data) => {
            if (!data) return message.reply("This user (<@"+message.member.id+">) is not a buyer.")
            if (data.HWID == "") return message.reply("This user (<@"+message.member.id+">) has no set HWID.")

            let currentHWID = data.HWID

            let hwidPart1 = currentHWID.slice(0,(currentHWID.length/2))
            let hwidPart2 = currentHWID.slice((currentHWID.length/2), currentHWID.length)

            message.author.send('```lua\n_G.Settings = {\n    ["HideName"] = false,\n    ["HidePicture"] = false,\n\n    ["Auto Hopping"] = {\n        ["Hop Time"] = 30,\n        ["Min"] = 4,\n        ["Max"] = 9,\n        ["Random"] = true\n    }\n}\n\nif _G.Settings["Auto Hopping"].Random then\n    getgenv().HopCount = math.random(_G.Settings["Auto Hopping"].Min, _G.Settings["Auto Hopping"].Max)\nelse\n    getgenv().HopCount = _G.Settings["Auto Hopping"].Min\nend\n\n_G.Theme = "Aqua"\n-- Current themes: "Aqua", "UltraDark" (default), "Original" (original xenon ui theme)\n_G.UltraFPSBoost = false\n_G.FixLag = true\n_G.key1 = "' + hwidPart1 + '"\n_G.key2 = "' + hwidPart2 + '"\n\nloadstring(game:HttpGet("https://raw.githubusercontent.com/Vezise/vezzyscripts/main/xenonv1_31"))()```')
            message.reply("I have sent you the script via dms.")
        })

    }
}