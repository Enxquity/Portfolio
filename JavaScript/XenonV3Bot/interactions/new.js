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
    name: "new",
    description: "Creates a new key",
    options: [
        {
            name: "amount",
            description: "Amount of keys to create",
            type: 4,
            required: true
        }
    ],

    async run  (client, interaction, args) {

        //setTimeout(() => message.delete(), 500);

        let is_good_user = (interaction.user.id == 1058570661611720825 || interaction.user.id == 932714600691015711)
        
        if (is_good_user == false) {	
            interaction.reply("You cannot create keys.").then(r => setTimeout(() => interaction.deleteReply(), 5000))
            return;
        }

        let [Amount]  = args
        var keys = "";
        var i = 0;

        if (!isNaN(Amount)) {

            Amount = Number(Amount)

            for (i = 0; i < Amount; i++) {
                let randomKey = randomString(16, '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ');

                keys = (keys + randomKey + "\n")

                HWID.findOne({Key: randomKey}, async (err, data) => {
                    if (!data) {
                        const NewData = new HWID({
                            _id: Mongo.Types.ObjectId(),
                            Key: randomKey,
                            HWID: "",
                            UserId: 0,
                            IP: ""
                        })

                        NewData.save()

                    } else {
                        interaction.reply("Failed to create key '" + randomKey + "' due to it already being a key.").then(r => setTimeout(() => interaction.deleteReply(), 10000))
                    }
                });
            }

            interaction.reply("```\n" + keys + "\n```")

            log_client.send({
                username: interaction.user.username,
                avatarURL: interaction.user.avatarURL,
                content: ("```\n" + keys + "\n```")
            })
        }
    }
}