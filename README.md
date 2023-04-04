<!-- @format -->

<h4 align="center">
	<img src="https://img.shields.io/github/last-commit/legendsSystems/legendsDiscordLogs">
	<img src="https://img.shields.io/github/contributors/legendsSystems/legendsDiscordLogs.png">
</h4>

<div align="center">
  <a href="https://github.com/legendsSystems/legendsDiscordLogs">
    <img src=https://avatars.githubusercontent.com/u/127198147?s=200&v=4">
  </a>

  <h1 align="center">legendsDiscordLogs</h1>

  <p align="center">
    New legendsDiscordLogs Server logger.
    <br />    
    <a href="https://discord.gg/legendsSystems">Report Bug</a>
    ·
    <a href="https://discord.gg/legendsSystems">Request Feature</a>
    ·
    <a href="https://legends.systems/legendsDiscordLogs/">Documentation</a>
  </p>
</div>

### 🛠 Requirements

-   FXServer With at least build: `5562`
-   screenshot-basic
-   A Discord Server

### ✅ Main Features

-   Basic logs:
    -   Chat Logs (Messages typed in chat.)
    -   Join Logs (When i player is connecting to the sever.)
    -   Leave Logs (When a player disconnects from the server.)
    -   Death Logs (When a player dies/get killed.)
    -   Shooting Logs (When a player fires a weapon.)
    -   Resource Logs (When a resouce get started/stopped.)
    -   Explotion Logs (When a player creates an explotion.)
    -   Namechange Logs (When someone changes their steam name.)
-   Screenshot Logs (You can add screenshot of the players game to your logs.)
-   Optional custom logs
    -   Easy to add with the export.

### 🔧 Download & Installation

1. Download the latest version from [github](https://github.com/legendsSystems/legendsDiscordLogs/)

-   Click the `Code` button and then `Download ZIP`
    ![](https://legendsSystems.com/i/424808e1-f68a-4af3-b697-5c7e8cd32290 'Clone Screen')

2. Put the legendsDiscordLogs folder in the server resource directory
    - Make sure to rename the folder to legendsDiscordLogs.
3. Get yourself the bot token(s) and add them in the config/config.json
    - Not sure how to get a bot token? [How to get a bot token](https://forum.legendsSystems.com/d/12-how-to-get-a-discord-bot-token).
    - The bots need to have the following intents enabled:
        - Presence Intent
        - Server Members Intent
        - Message Content Intent
4. Add this to your server.cfg

```cfg
ensure legendsDiscordLogs
```

5. Start the resource once and let it build.
6. Go to your discord where you invited the bot (The one where you want your new main logs to be.) 7. and use the command !legendsDiscordLogs setup.
    - Make sure the first bot (The one with the token at 1) has permissions to send messages, create channels and create webhooks.
    - All other bots just need permission to send messages in the channels.
7. Restart your server and you will see the logs on your discord.

### 📈 Resmon Values.

![](https://legendsSystems.com/i/7418e619-a9c9-4787-b3ac-b59ad4860768 'Resmon legendsDiscordLogs')
Info | |
--- | --- |
Code is accessible | Yes
Requirements | [Yes](https://github.com/legendsSystems/legendsDiscordLogs#-requirements)
Documentation | [Here](https://docs.legendsSystems.com/legendsDiscordLogs/)
Support | Yes, we have a [Discord](https://discord.gg/legendsSystems) server at your disposal
