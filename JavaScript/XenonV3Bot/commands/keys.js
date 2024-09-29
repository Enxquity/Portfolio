const Discord = require("discord.js")
const Mongo = require("mongoose")

const { MessageAttachment } = require('discord.js')

const HWID = require("../schemes/hwid_schema.js")

module.exports = {
    name: "keys",
    description: "Lists the database",

    async run  (client, message, args) {

        if (message.member.id != 932714600691015711) {
            message.reply("You cannot view keys.").then(r => setTimeout(() => r.delete(), 5000))
            return;
        }

        let Lua_Table = "local hwids = {\n\n"
        var cursor = HWID.find()

        ;(await cursor).forEach(item => 
            Lua_Table = (Lua_Table + ('     ' + '["' + item.Key + '"] = {\n' + '        HWID = "' + item.HWID + '"\n     },\n' ))
        ) // format it correctly with spacing
        Lua_Table = Lua_Table + "\n\n}"

        const MessageBuffer = Buffer.from(Lua_Table)
        const Attachment = new MessageAttachment(MessageBuffer, 'database.lua')
        message.channel.send(Attachment)

        message.delete()
    }
}