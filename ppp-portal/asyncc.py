import boto3
import botocore.config
import config
import requests
from flask_discord_interactions.models import Message

def pppstatus(event, context):
    eee = event

    my_config = botocore.config.Config(region_name = 'ap-east-1')
    ec2_resource = boto3.resource('ec2', config=my_config)
    instance = ec2_resource.Instance(config.INSTANCE_ID)
    state_name = instance.state['Name']
    if state_name == 'running':
        public_ip_address = instance.public_ip_address
        msg = f'{state_name} {public_ip_address}'
    else:
        msg = state_name

    edit(eee, msg)
    return {
        "statusCode": 200,
    }

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
    """
    Return the followup URL for this interaction. This URL can be used to
    send a new message, or to edit or delete an existing message.

    Parameters
    ----------
    message: str
        The ID of the message to edit or delete.
        If None, sends a new message.
        If "@original", refers to the original message.
    """

    url = (
        f"{eee['DISCORD_BASE_URL']}/webhooks/"
        f"{eee['DISCORD_CLIENT_ID']}/{eee['token']}"
    )
    if message is not None:
        url += f"/messages/{message}"

    return url
