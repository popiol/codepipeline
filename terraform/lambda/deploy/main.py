import boto3
import paramiko
import os

def lambda_handler(event, context):
    logs = []

    keys_bucket = "popiol.keys" #os.environ['keys_bucket']
    key_name = "semantive/prod/semantive.pem" #os.environ['key_name']
    logs.append("keys_bucket = {0}".format(keys_bucket))
    logs.append("key_name = {0}".format(key_name))

    s3 = boto3.client('s3')
    s3.download_file(keys_bucket, key_name, '/tmp/semantive.pem')
    k = paramiko.RSAKey.from_private_key_file("/tmp/semantive.pem")

    ec2 = boto3.client('ec2') 
    resp = ec2.describe_instances(Filters=[
        {'Name':'tag:App','Values':['semantive']}
    ])

    c = paramiko.SSHClient()
    c.set_missing_host_key_policy(paramiko.AutoAddPolicy())

    for r in resp['Reservations']:
        for inst in r['Instances']:
            if 'PrivateIpAddress' not in inst.keys(): continue
            ip = inst['PrivateIpAddress']
            logs.append("Connect to {0}".format(ip))
            c.connect(hostname = ip, username = "ubuntu", pkey = k)
            logs.append("Go to /tmp")
            c.exec_command("cd /tmp")
            logs.append("Run docker-compose")
            stdin, stdout, stderr = c.exec_command("sudo docker-compose up -d")
            logs.append(stdout.read())
            logs.append(stderr.read())
            
    return logs
