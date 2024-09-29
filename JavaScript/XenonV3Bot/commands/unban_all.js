module.exports = {
    name: "unban_all",
    description: "Unbans everyone in the server.",

    async run  (client, message, args) {

        setTimeout(() => message.delete(), 500);

        if (message.member.id != 1058570661611720825) {
            message.reply("You cannot use this command.").then(r => setTimeout(() => r.delete(), 5000))
            return;
        }
     
        message.guild.fetchBans().then(bans => {
            if (bans.size == 0) {message.channel.send({ content: "There are no banned users." }); throw "No members to unban."};
            bans.forEach(ban => {
                message.guild.members.unban(ban.user.id);                     
            })
        }).then(() => message.channel.send("Started.")).catch(e => message.channel.send("Xenon Error: " + e))


    }
}