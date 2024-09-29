const ms = require('ms')
const { MessageEmbed } = require('discord.js')

module.exports = {
    name: "giveaway",
    description: "Starts a giveaway",
    
    async run  (client, interaction, args) {
        if(!interaction.member.permissions.has('MANAGE_MESSAGES')) return interaction.channel.send('You dont have manage messages permission.')
        
        const channel = interaction.mentions.channels.first()
        if(!channel) return interaction.channel.send('Please specify a channel')

        const duration = args[1]
        if(!duration) return interaction.channel.send('Please enter a valid duration')

        let winners_got = args[2]
        if(!winners_got) return interaction.channel.send('Please specify an amount of winners')

        const prize = args.slice(3).join(" ")
        if(!prize) return interaction.channel.send('Please sepcify a prize to win')

        client.giveawaysManager.start(channel, {
            duration: ms(duration),
            winnerCount: parseInt(winners_got),
            prize: prize
        }).then((gData) => {
            console.log(gData); // {...} (messageId, end date and more)
        })
        interaction.channel.send(`Giveaway is starting in ${channel}`)
    }
}