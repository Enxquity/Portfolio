const ms = require('ms')

module.exports = {
    name: "end",
    description: "Ends a giveaway",

    async run  (client, interaction, args) {
        if(!interaction.member.permissions.has('MANAGE_MESSAGES')) return interaction.channel.send('You do not have permissions to use this command')
        if(!args[0]) return interaction.channel.send('Please specify a message id')

        client.giveawaysManager.end(args[0]).then(() => {
            interaction.channel.send('Success! Giveaway ended!');
        }).catch((err) => {
            interaction.channel.send(`An error has occurred, please check and try again.\n\`${err}\``);
        });
        
    }
}