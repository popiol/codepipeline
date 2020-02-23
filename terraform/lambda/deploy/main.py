import boto3

def lambda_handler(event, context):
    ec2 = boto3.client('ec2') 
    response = ec2.describe_instances(Filters=[{'Name':'tag:App','Values':['semantive']}])
    return "Hello world"
