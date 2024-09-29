const Discord = require("discord.js")
const Mongo = require("mongoose")

const HWID = require("../schemes/hwid_schema.js")

module.exports = {
    name: "cmds",
    description: "Gives list of commands.",

    async run  (client, message, args) {
        message.reply('```ini\n[Whitelist Commands]\n>redeem <key>\n>hwid -- gives you a script to execute to get your executors hwid for whitelist purposes\n>sethwid <hwid>\n>rewhitelist <@user> -- rewhitelist yourself if you are a buyer but do not have buyer role\n\n[Script Commands]\n>pvp -- Zantax PvP, best pvp script!\n>v1 -- use this while v3 isnt released yet\n>v2\n>v3 -- not released yet\n\n[Miscellaneous Commands]\n>cmds -- gives a list of commands\n\n[Admin Commands]\n>giveaway\n>reroll <giveawayid>\n>new <keyName> -- create key\n>trial -- start a whitelist trial\n>disable_trial -- disables whitelist trial\n>resethwid <@user>\n>keys```')
    }  
}   