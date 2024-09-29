const Discord = require("discord.js")
const Mongo = require("mongoose")

const HWID = require("../schemes/hwid_schema.js")

module.exports = {
    name: "v2",
    description: "DM's you the script",

    async run  (client, message, args) {

        HWID.findOne({UserId: message.member.id}, async (err, data) => {
            if (!data) return message.reply("This user (<@"+message.member.id+">) is not a buyer.")
            if (data.HWID == "") return message.reply("This user (<@"+message.member.id+">) has no set HWID.")

            let currentHWID = data.HWID

            let hwidPart1 = currentHWID.slice(0,(currentHWID.length/2))
            let hwidPart2 = currentHWID.slice((currentHWID.length/2), currentHWID.length)

            message.author.send('```lua\ngetgenv().Options = {Binds = {Toggle = Enum.KeyCode.RightShift}}\n_G.key1 =  "' + hwidPart1 + '"\n_G.key2 = "' + hwidPart2 + '"\n\nloadstring(game:HttpGet("https://raw.githubusercontent.com/Vezise/vezzyscripts/main/xenonv2_00", true))()```')
            message.reply("I have sent you the script via dms.")
        })

    }
}