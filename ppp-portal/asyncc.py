import boto3
import botocore.config
import config
import requests
from flask_discord_interactions.models import Message

handler_name_to_func_dict = {}
def reg_handler(func):
    handler_name_to_func_dict[func.__name__] = func
    return func

def handler(event, context):
    eee = event
    func_name = eee['func_name']
    if func_name in handler_name_to_func_dict:
        return handler_name_to_func_dict[func_name](event, context)
    else:
        return {"statusCode": 404}

@reg_handler
def pppstatus(event, context):
    eee = event

    my_config = botocore.config.Config(region_name = 'ap-east-1')
    ec2_resource = boto3.resource('ec2', config=my_config)
    instance = ec2_resource.Instance(config.INSTANCE_ID)
    state_name = instance.state['Name']
    if state_name == 'running':
        public_ip_address = instance.public_ip_address
        msg = f'state={state_name}, IP = {public_ip_address}:8211'
    else:
        msg = f'state={state_name}'

    edit(eee, msg)
    return {"statusCode": 200}

@reg_handler
def pppstart(event, context):
    eee = event

    my_config = botocore.config.Config(region_name = 'ap-east-1')
    ec2_resource = boto3.resource('ec2', config=my_config)
    instance = ec2_resource.Instance(config.INSTANCE_ID)
    instance_state = instance.state['Name']
    if instance_state == 'stopped':
        instance.start()
        msg = "Starting..."
    elif instance_state == 'running':
        public_ip_address = instance.public_ip_address
        msg = f"Instance is already running, IP={public_ip_address}"
    else:
        msg = f"Instance is not stopped, state={instance_state}.  Try again later."

    edit(eee, msg)
    return {"statusCode": 200}

# copy from https://github.com/breqdev/flask-discord-interactions/blob/main/flask_discord_interactions/context.py
def edit(eee, updated: str, message: str = "@original"):
    updated = Message.from_return_value(updated)

    response, mimetype = updated.encode(followup=True)
    updated = requests.patch(
        followup_url(eee, message),
        data=response,
        headers={"Content-Type": mimetype},
    )
    updated.raise_for_status()

def followup_url(eee, message: str = None):
    url = (
        f"{eee['DISCORD_BASE_URL']}/webhooks/"
        f"{eee['DISCORD_CLIENT_ID']}/{eee['token']}"
    )
    if message is not None:
        url += f"/messages/{message}"

    return url
