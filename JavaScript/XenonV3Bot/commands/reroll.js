const { MessageEmbed } = require('discord.js')

module.exports = {
    name: "reroll",
    description: "Rerolls a giveaway with id",

    async run  (client, interaction, args) {
        if(!interaction.member.permissions.has('MANAGE_MESSAGES')) return interaction.channel.send('You do not have permission')

        if(!args[0]) return interaction.channel.send('Please specify a message id')

        client.giveawaysManager.reroll(args[0]).then(() => {
            interaction.channel.send('Success! Giveaway rerolled!');
        }).catch((err) => {
            interaction.channel.send(`An error has occurred, please check and try again.\n\`${err}\``);
        });
    }
}