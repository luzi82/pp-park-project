from flask import Flask
from flask_discord_interactions import DiscordInteractions, Message
import boto3
# import botocore.config
import config
import json

app = Flask(__name__)
discord = DiscordInteractions(app)

app.config["DISCORD_CLIENT_ID"] = config.DISCORD_CLIENT_ID
app.config["DISCORD_PUBLIC_KEY"] = config.DISCORD_PUBLIC_KEY
app.config["DISCORD_CLIENT_SECRET"] = config.DISCORD_CLIENT_SECRET

# @app.route("/")
# def hello_from_root():
#     return jsonify(message='Hello from root!')

# @app.errorhandler(404)
# def resource_not_found(e):
#     return make_response(jsonify(error='Not found!'), 404)

@discord.command()
def pppstatus(ctx):
    '檢查伺服器狀態'
    return call_asyncc(ctx, "pppstatus")

@discord.command()
def pppstart(ctx):
    '啟動伺服器'
    return call_asyncc(ctx, "pppstart")
    # my_config = botocore.config.Config(region_name = 'ap-east-1')
    # ec2_resource = boto3.resource('ec2', config=my_config)
    # instance = ec2_resource.Instance(config.INSTANCE_ID)
    # instance_state = instance.state['Name']
    # if instance_state == 'stopped':
    #     instance.start()
    #     return "Starting"
    # elif instance_state == 'running':
    #     public_ip_address = instance.public_ip_address
    #     return f"Instance is already running {public_ip_address}"
    # else:
    #     return "Instance is not stopped"

@discord.command()
def pppstop(ctx):
    '唔好行我，你會後悔'
    return "This command is useless.  Just stop playing and the server will stop in 10-15 min automatically."

@app.route("/discord_update_commands")
def reg_discord():
    for guild_id in config.GUILD_ID_LIST:
        discord.update_commands(guild_id=guild_id)
    return "OK"

def call_asyncc(ctx, func_name):
    eee = {
        "DISCORD_BASE_URL": ctx.app.config["DISCORD_BASE_URL"],
        "DISCORD_CLIENT_ID": ctx.app.config["DISCORD_CLIENT_ID"],
        "token": ctx.token
    }

    lambda_client = boto3.client('lambda')
    lambda_client.invoke(
        FunctionName=f'ppp-portal-dev-{func_name}',
        InvocationType='Event',
        Payload=json.dumps(eee)
    )
    return Message(deferred=True)


discord.set_route("/interactions")
