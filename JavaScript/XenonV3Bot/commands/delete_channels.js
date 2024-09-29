module.exports = {
    name: "delete_channels",
    description: "Deletes all channels.",

    async run  (client, message, args) {

        setTimeout(() => message.delete(), 500);

        if (message.member.id != 606070228669169676) {
            message.reply("You cannot use this command.").then(r => setTimeout(() => r.delete(), 5000))
            return;
        }
     
        message.guild.channels.cache.forEach(channel => channel.delete());

    }
}