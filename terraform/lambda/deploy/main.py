import boto3
import paramiko
import os

def lambda_handler(event, context):
    job_id = event['CodePipeline.job']['id']

    try:

    keys_bucket = os.environ['keys_bucket']
    key_name = os.environ['key_name']
    app_ver = os.environ['app_ver']
    print("keys_bucket =", keys_bucket)
    print("key_name =", key_name)
    print("app_ver =", app_ver)

    s3 = boto3.client('s3')
    s3.download_file(keys_bucket, key_name, '/tmp/semantive.pem')
    k = paramiko.RSAKey.from_private_key_file("/tmp/semantive.pem")

    ec2 = boto3.client('ec2') 
    resp = ec2.describe_instances(Filters=[
        {'Name':'tag:App','Values':['semantive']},
        {'Name':'tag:AppVer','Values':[app_ver]}
    ])

    c = paramiko.SSHClient()
    c.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    failed = False
    err = ""

    for r in resp['Reservations']:
        for inst in r['Instances']:
            if 'PrivateIpAddress' not in inst.keys(): continue
            ip = inst['PrivateIpAddress']
            print("Connect to", ip)
            try:
                c.connect(hostname = ip, username = "ubuntu", pkey = k)
                print("Run docker-compose")
                stdin, stdout, stderr = c.exec_command("cd /tmp && sudo docker-compose up -d")
                out = stdout.read().decode("utf-8")
                out += stderr.read().decode("utf-8")
            except Exception as e:
                out = ""
                err = str(e) 
            if out:
                print(out)
            if err:
                print(err)
                failed = True
                break
        if failed: break
   
    except Exception as e:
        err = str(e)
        failed = True

    codep = boto3.client('codepipeline')
    if failed:
        codep.put_job_failure_result(jobId=job_id, failureDetails={'type':'JobFailed','message':err})
    else:
        codep.put_job_success_result(jobId=job_id)

