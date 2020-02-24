import boto3
import paramiko
import os

def lambda_handler(event, context):
    job_id = event['CodePipeline.job']['id']

    try:
        keys_bucket = os.environ['keys_bucket']
        key_name = os.environ['key_name']
        app = os.environ['app']
        app_ver = os.environ['app_ver']
        account_id = os.environ['account_id']
        aws_region = os.environ['aws_region']
        app_id = app + "_" + app_ver
        print("keys_bucket =", keys_bucket)
        print("key_name =", key_name)
        print("app =", app)
        print("app_ver =", app_ver)
        print("account_id =", account_id)
        print("aws_region =", aws_region)

        s3 = boto3.client('s3')
        s3.download_file(keys_bucket, key_name, '/tmp/semantive.pem')
        k = paramiko.RSAKey.from_private_key_file("/tmp/semantive.pem")

        ec2 = boto3.client('ec2') 
        resp = ec2.describe_instances(Filters=[
            {'Name':'tag:App','Values':[app]},
            {'Name':'tag:AppVer','Values':[app_ver]}
        ])

        c = paramiko.SSHClient()
        c.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        failed = False
        err = ""
        out = ""
        commands = [
            "sudo $(aws ecr get-login --no-include-email --region {0})".format(aws_region),
            "sudo docker pull {0}.dkr.ecr.{1}.amazonaws.com/{2}:latest".format(account_id, aws_region, app_id),
            "sudo docker tag {0}.dkr.ecr.{1}.amazonaws.com/{2}:latest semantive:latest".format(account_id, aws_region, app_id),
            "cd /tmp && sudo docker-compose up -d"
        ]

        for r in resp['Reservations']:
            for inst in r['Instances']:
                if 'PrivateIpAddress' not in inst.keys(): continue
                ip = inst['PrivateIpAddress']
                print("Connect to", ip)
                try:
                    c.connect(hostname = ip, username = "ubuntu", pkey = k)
                    for command in commands:
                        print(command)
                        stdin, stdout, stderr = c.exec_command(command)
                        out1 = stdout.read().decode("utf-8")
                        out1 += stderr.read().decode("utf-8")
                        print(out1)
                        out += out1
                except Exception as e:
                    err = str(e)
                    failed = True
                if out:
                    print(out)
                if err:
                    print(err)
                if failed: break
            if failed: break   
    except Exception as e:
        err = str(e)
        failed = True

    codep = boto3.client('codepipeline')
    if failed:
        print("Failed:",err)
        codep.put_job_failure_result(jobId=job_id, failureDetails={'type':'JobFailed','message':err})
    else:
        print("Success:",out)
        codep.put_job_success_result(jobId=job_id)

