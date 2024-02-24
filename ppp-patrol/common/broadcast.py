#!/usr/bin/python3

import argparse
import asyncio
import discord
import _config

parser = argparse.ArgumentParser(description='Broadcast a message to a Discord channel')
parser.add_argument('type', type=str, help='The type of message to broadcast')
parser.add_argument('message', type=str, help='The message to broadcast')
args = parser.parse_args()

if args.type == 'NOTICE':
    CHANNEL_ID_LIST = _config.NOTICE_CHANNEL_ID_LIST
elif args.type == 'VERBOSE':
    CHANNEL_ID_LIST = _config.VERBOSE_CHANNEL_ID_LIST
else:
    assert(False)

intents = discord.Intents.default()  #  Creates an Intents object
intents.guilds = True  #  Allowing the bot to receive information about guilds

async def main():
    client = discord.Client(intents=intents)
    await client.login(_config.DISCORD_TOKEN)
    for CHANNEL_ID in CHANNEL_ID_LIST:
        channel = await client.fetch_channel(CHANNEL_ID)
        if channel is not None:
            await channel.send(args.message)
    await client.close()

asyncio.run(main())
