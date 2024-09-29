const xenon_config = {
    token: "NO TOKEN",
    prefix: ">",
    database_entry: "NO DATABASE",

    statuses: [
        "STATUS 1",
        "STATUS 2",
        "STATUS 3"
    ],
    
    guild_id: "NO GUILD ID",
    client_id: "NO CLIENT ID"
}

const Discord = require('discord.js')
const Client = new Discord.Client({intents: [
    Discord.Intents.FLAGS.GUILD_MESSAGE_REACTIONS,
    Discord.Intents.FLAGS.DIRECT_MESSAGES,
    Discord.Intents.FLAGS.GUILDS,
    Discord.Intents.FLAGS.GUILD_MESSAGES,
    Discord.Intents.FLAGS.GUILD_MEMBERS,
    Discord.Intents.FLAGS.GUILD_INTEGRATIONS,
]}); 
const Mongo = require("mongoose")
const FS = require("fs")
const Path = require("path")
const { GiveawaysManager } = require('discord-giveaways');
const { ThreadChannel } = require('discord.js');
const { url } = require('inspector');
const { measureMemory } = require('vm');
const { REST } = require("@discordjs/rest");
const { Routes } = require('discord-api-types/v9');

const clamp = (num, min, max) => Math.min(Math.max(num, min), max);

const BotStart = Date.now()

let BotStarted = false;

Client.Commands = new Discord.Collection();
Client.giveawaysManager = new GiveawaysManager(Client, {
    storage: './giveaways.json',
    default: {
        botsCanWin: false,
        embedColor: '#FF0000',
        embedColorEnd: '#000000',
        reaction: '🎉'
    }
});

const commandFiles = FS.readdirSync(Path.join(__dirname, "commands")).filter(file => file.endsWith(".js"));

for (const file of commandFiles) {
    const Command = require(Path.join(__dirname, "commands", `${file}`));
    Client.Commands.set(Command.name, Command);
}

function sleep(ms) {
 return new Promise(
    resolve => setTimeout(resolve, ms)
 );
}

async function random_status(delay, message) {
    // Generate random number
    var ran_num = clamp(Math.random()*xenon_config.statuses.length, 1, xenon_config.statuses.length)
    var ran_type = Math.floor(Math.random() * 2) 

    if (ran_type == 0) {
        ran_type = "WATCHING"
    } else {
        ran_type = "PLAYING"
    }

    Client.user.setPresence({
        status: "idle", 
        activities: [{
            name: xenon_config.statuses[Math.floor(ran_num)],
            type: ran_type,
            url: "https://bit.ly/3JChei6"
        }]
    })

    if (message != null) {
         message.channel.send(
            "Done, new presence: " + ran_type + " " + xenon_config.statuses[Math.floor(ran_num)]
        )
    }
}

function xenon_log(message) {
  console.log("(" + (Date.now()-BotStart) + "ms since bot start) XenonV3Bot: " + message)
}

// connection to mongo
Mongo.connect(xenon_config.database_entry, {
    useNewUrlParser: true,
    useUnifiedTopology: true
})

xenon_log("Success, connected to database.")

Client.on("guildMemberAdd", async member => {
    if (!Client.Commands.has("auto_rewhitelist")) return xenon_log("Not have command"); 
    Client.Commands.get("auto_rewhitelist").run(Client, member);
})

// message command handler

Client.on("messageCreate", async message => {
    if(message.author.Client) return;
    if(message.author.bot) return;
    if(message.channel.type === 'dm') return;
    if(message.guild === null) return;
    if(message.guild.id != 1068426300274004018) return message.channel.send("Xenon V3 Bot Error: Message vez#1944 to check output logs.")

    if(message.content.startsWith(xenon_config.prefix)) {
        const args = message.content.slice(xenon_config.prefix.length).trim().split(/ +/);

        const command = args.shift().toLowerCase();

        if (command == "refresh_status") {
            random_status(false, message)
        }

        if(!Client.Commands.has(command)) return;
        try {
            Client.Commands.get(command).run(Client, message, args);

        } catch (error){
            console.log(error);
        }
    }
});

Client.Interactions = new Discord.Collection()

const interactionFiles = FS.readdirSync(Path.join(__dirname, "interactions")).filter(file => file.endsWith(".js"));

for (const file of interactionFiles) {
    const Command = require(Path.join(__dirname, "interactions", `${file}`));
    Client.Interactions.set(Command.name, Command);
}

Client.on("interactionCreate", async (interaction) => {
    if (BotStarted == false) { 
        xenon_log("Protected bot from running interaction before start!");
        interaction.channel.send("Interaction was ignored due to bot starting up!");
        return;
    }
    if (interaction.isCommand()) {
        //await interaction.defer({ ephemeral: false }).catch(() => {});
        //await interaction.deferReply( { ephemeral: false } ).catch(() => {});

        const cmd = Client.Interactions.get(interaction.commandName);
        if (!cmd) 
            return interaction.followUp({ content: "An error has occured!" });

        const args = [];
        //interaction.options.array().map((x) => {
           // args.push(x.value);
        //});
        for (let option of interaction.options.data) {
            if (option.type === "SUB_COMMAND") {
                option.options?.forEach((x) => {
                    if (x.value) args.push(option.value);
                });
            } else if (option.value) args.push(option.value)
        };
        
        try {
            cmd.run(Client, interaction, args);

        } catch (error){
            console.log(error);
        }
    }
});

const rest = new REST({ version: '9' }).setToken(xenon_config.token);

(async() => {
    try {
        xenon_log("Attempting to add slash commands!");

        await rest.put(
            Routes.applicationGuildCommands(
                xenon_config.client_id,
                xenon_config.guild_id,
            ),
            { body: Client.Interactions }
        )

        xenon_log("Slash commands were added!");
    } catch (error) {
        console.log(`There was an error registering slash commands! Error ${error}`);
    }
})();

Client.on("ready", async (idk) => {
    xenon_log("Bot is ready!")

    setTimeout(() => {
        BotStarted = true;
    }, 2000)
    while (true) {
        random_status(true)
        await sleep(300000)
    }
})

// actually start the bot
Client.login(xenon_config.token)