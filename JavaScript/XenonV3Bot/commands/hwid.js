const Discord = require("discord.js")
const Mongo = require("mongoose")

const HWID = require("../schemes/hwid_schema.js")

module.exports = {
    name: "hwid",
    description: "Replies with HWID copier script.",

    async run  (client, message, args) {
        message.reply('```lua\nloadstring(game:HttpGet("https://pastebin.com/raw/gnxPT76h"))()```')
    }  
}   