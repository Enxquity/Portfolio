const Discord = require("discord.js")
const Mongo = require("mongoose")

const HWID = require("../schemes/hwid_schema.js")

const log_client = new Discord.WebhookClient({
    url: "https://discord.com/api/webhooks/1075582700762701946/fFEM-ZuqTyjEFTFvIG8lutsKeec8xPkatHV2vwAuvLLkEYknVzIFqrHjR79eKSCnW9bU"
});

function randomString(length, chars) {
    var result = '';
    for (var i = length; i > 0; --i) result += chars[Math.floor(Math.random() * chars.length)];
    return result;
}

module.exports = {
    name: "whitelist",
    description: "Whitelists a user",
    options: [
        {
            name: "user",
            description: "User to whitelist",
            type: 6,
            required: true
        }
    ],

    async run  (client, interaction, args) {

        //setTimeout(() => message.delete(), 500);

        let is_good_user = (interaction.user.id == 1058570661611720825 || interaction.user.id == 932714600691015711)
        
        if (is_good_user == false) {	
            interaction.reply("You cannot whitelist people.").then(r => setTimeout(() => interaction.deleteReply(), 5000))
            return;
        }

        let Amount  = 1
        let [User] = args
        User = interaction.guild.members.cache.get(User)
        var i = 0;

        let HasKey = false

        await HWID.findOne({UserId: User.id}, async (err, data) => {
            if (data) {
                HasKey = true
            }
        });
        
        if (!isNaN(Amount)) {

            Amount = Number(Amount)

            for (i = 0; i < Amount; i++) {
                if (HasKey == true) return interaction.reply("This user is already whitelisted!");


                let randomKey = randomString(16, '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ');

                HWID.findOne({Key: randomKey}, async (err, data) => {
                    if (!data) {
                        const NewData = new HWID({
                            _id: Mongo.Types.ObjectId(),
                            Key: randomKey,
                            HWID: "",
                            UserId: User.id,
                            IP: ""
                        })

                        NewData.save()

                        let whitelisted = interaction.guild.roles.cache.find(role => role.name === "Whitelisted");
                        User.roles.add(whitelisted.id);

                        User.send(`You were whitelisted by ${interaction.user.username}, with the key: ${randomKey}`)

                        log_client.send({
                            username: User.user.username,
                            avatarURL: User.user.avatarURL,
                            content: (`User ${User.user.username} was whitelisted by ${interaction.user.username} using the key: ${randomKey}!`)
                        })

                        interaction.reply("Whitelisted!")
                    } else {
                        interaction.reply("Failed to create key '" + randomKey + "' due to it already being a key.").then(r => setTimeout(() => interaction.deleteReply(), 10000))
                    }
                });
            }
        }
    }
}