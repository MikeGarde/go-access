# Build

The Build code you run will be dependent on the type of AWS Log you wish to run through [GoAccess](https://goaccess.io/).
As of now building this Docker container will generate a static GoAccess report and upload it to an S3 bucket of
your choice.

AWS stores seemingly similar logs in different formats so please see the examples below for the build example that 
is appropriate for you.

Tip: create a notes file of your arguments to make future reports faster.

##Log Formats

### AWS Elastic Beanstalk

![AWS EB Log Setup](https://github.com/MikeGarde/go-access/blob/master/docs/aws-eb-setup.png?raw=true)

Your log files will be stored in the following location, note, you can get your environment ID by going to your 
Elastic Beanstalk Dashboard, the ID will be at the top and formatted "e-[a-z0-9]+"

```
s3://elasticbeanstalk-{region}-{accountNumber}/resources/environments/logs/publish/{environmentID}/ 
```

After you are logging requests you will need to setup a bucket to record the results of GoAccess, in this example
I am using "go-access-reports"

```bash
docker build -t go-access . \
    --build-arg aws_access_key_id=XXX \
    --build-arg aws_secret_access_key=XXX \
    --build-arg region=us-east-1 \
    --build-arg s3_log_location='s3://elasticbeanstalk-us-east-1-XXX/resources/environments/logs/publish/e-XXX/' \
    --build-arg RUN_EB=true \
    --build-arg output_bucket='go-access-reports' \
    --build-arg cache_breaker=123
```

### Load Balancer

Unlike Elastic Beanstalk logs you will specify where your logs are stored.
* Goto your EC2 Dashboard
* Click Load Balancers
* Select the Load Balancer you wish to log
* Under Attributes set your location

![AWS LB Log Setup](https://github.com/MikeGarde/go-access/blob/master/docs/aws-lb-setup.png?raw=true)

Fill in the following blanks and run this command.

```bash
docker build -t go-access . \
    --build-arg aws_access_key_id=XXX \
    --build-arg aws_secret_access_key=XXX \
    --build-arg region=us-east-1 \
    --build-arg s3_log_location='s3://{YOU_CHOOSE}/{THIS}/AWSLogs/{accountNumber}/elasticloadbalancing/us-east-1/' \
    --build-arg RUN_LB=true \
    --build-arg output_bucket='go-access-reports' \
    --build-arg cache_breaker=123
```

### Output

Notice the second to last argument is output_bucket, the results of GoAccess will be stored there. If you wish you can
comment this out in Dockerfile and use the following to fetch the file from your Docker Container.

Get the Container ID with docker ps then copy the file

```bash
docker ps
docker cp {containerID}:/root/report.html /{localFolder}/report.html
```

# Debugging

Install AWS CLI

On your mac

```bash
aws configure
chmod 644 ~/.aws/*
```

Access with your AWS Creds (debugging)

```bash
docker run -it --rm -e "HOME=/home" -v $HOME/.aws:/home/.aws go-access /bin/bash

```

Exit

```bash
exit
```

## Get Merged Logs

Uncomment line 40 in Dockerfile and provide an S3 bucket/location.

```bash
RUN aws s3 cp ~/AWS-access.log s3://{BUCKET}/AWS-access-$(date -d "today" +"%Y%m%d%H%M").log
```