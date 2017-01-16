# Build

##Log Formats

AWS Elastic Beanstalk
![AWS EB Log Setup](https://github.com/MikeGarde/go-access/blob/master/docs/aws-eb-setup.png?raw=true)

```bash
docker build -t go-access . \
    --build-arg aws_access_key_id=xxx \
    --build-arg aws_secret_access_key=xxx \
    --build-arg region=us-east-1 \
    --build-arg uploadBucket=xxx \
    --build-arg cache_breaker=123
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
