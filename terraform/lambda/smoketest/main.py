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
        print("keys_bucket =", keys_bucket)
        print("key_name =", key_name)
        print("app =", app)
        print("app_ver =", app_ver)

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
        commands = [
            "curl http://localhost:9000/albums/test",
            "curl http://localhost:9000/albums/no%20album",
            "curl http://localhost:9000/songs/test",
            "curl http://localhost:9000/songs/2002/no%20album"
        ]
        expected = [
            '[{"artist":"test","releaseYear":2002,"albumTitle":"fake album","genre":"no genre","producer":{"name":"Ninja","countryCode":"gb"},"recordLabel":"no record label"}]',
            '[{"artist":"no album","releaseYear":2002,"albumTitle":"fake album","genre":"no genre","producer":{"name":"Ninja","countryCode":"gb"},"recordLabel":"no record label"}]',
            '[{"albumTitle":"no album","artist":"test","genre":"no genre","performers":[],"releaseYear":2002,"songTitle":"no song title","trackNo":0}]',
            '[{"albumTitle":"no album","artist":"no artist","genre":"no genre","performers":[],"releaseYear":2002,"songTitle":"no song title","trackNo":0}]'
        ]
        test_passed = True
        test_res = []

        for r in resp['Reservations']:
            for inst in r['Instances']:
                if 'PrivateIpAddress' not in inst.keys(): continue
                ip = inst['PrivateIpAddress']
                print("Connect to", ip)
                try:
                    c.connect(hostname = ip, username = "ubuntu", pkey = k)
                    for comm_i, command in enumerate(commands):
                        expected_result = expected[comm_i]
                        print("Test command:",command)
                        stdin, stdout, stderr = c.exec_command(command)
                        out1 = stdout.read().decode("utf-8")
                        out1 += stderr.read().decode("utf-8")
                        print("Response:",out1)
                        print("Expected:",expected_result)
                        passed = True if out1 == expected_result else False
                        res = "OK" if passed else "Failed"
                        test_passed = test_passed and passed
                        test_res.append(res)
                        print("Result:",res)
                except Exception as e:
                    err = str(e)
                    failed = True
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
    elif not test_passed:
        print("Test failed") 
        codep.put_job_failure_result(jobId=job_id, failureDetails={'type':'JobFailed','message':"Test failed: {0}".format(" ".join(test_res))})
    else:
        print("Test passed")
        codep.put_job_success_result(jobId=job_id)

