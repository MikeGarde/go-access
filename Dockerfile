FROM fedora:25

# Update and install GoAccess needed libraries
RUN dnf update -y
RUN dnf install glib2 glib2-devel glibc make geoip-devel gcc ncurses-devel unzip zlib-devel bzip2-devel tokyocabinet goaccess awscli findutils -y


# Our Variables
ARG aws_access_key_id
ARG aws_secret_access_key
ARG region
ARG s3_log_location
ARG output_bucket
ARG cache_breaker

ARG RUN_EB
ARG RUN_LB

ENV RUN_EB ${RUN_EB:-false}
ENV RUN_LB ${RUN_LB:-false}


# AWS Setup
RUN aws configure set aws_access_key_id $aws_access_key_id
RUN aws configure set aws_secret_access_key $aws_secret_access_key
RUN aws configure set default.region $region


# Get Logs From AWS
RUN mkdir ~/logs

RUN if [ ${RUN_EB} == 'true' ]; then echo $cache_breaker && aws s3 cp $s3_log_location ~/logs --recursive --exclude "*" --include "*access_log*"; fi
RUN if [ ${RUN_LB} == 'true' ]; then echo $cache_breaker && aws s3 cp $s3_log_location ~/logs --recursive; fi

RUN gunzip -r ~/logs
RUN find ~/logs -type f -name "*.gz" -delete
RUN find ~/logs -type f -name "*" -print0 | xargs -0 -I file cat file > ~/AWS-access.log

# Move assembled log to S3 (optional, good for debugging)
#RUN aws s3 cp ~/AWS-access.log s3://{BUCKET}/AWS-access-$(date -d "today" +"%Y%m%d%H%M").log


# Generate Report
RUN if [ ${RUN_EB} == 'true' ]; then goaccess -f ~/AWS-access.log -a -o ~/report.html --log-format='%^ (%h) %^ %^ [%d:%t %^] "%r" %s %b "%R" "%u"' --date-format='%d/%b/%Y' --time-format='%H:%M:%S'; fi
RUN if [ ${RUN_LB} == 'true' ]; then goaccess -f ~/AWS-access.log -a -o ~/report.html --log-format='%^ %dT%t.%^ %^ %h:%^ %^ %^ %T %^ %s %^ %^ %b "%r" "%u" %^ %^ %^ %^' --date-format='%Y-%m-%d' --time-format='%H:%M:%S'; fi

RUN aws s3 cp ~/report.html s3://api---logs/report-$(date -d "today" +"%Y%m%d-%H%M").html


# Remove AWS Credentials
RUN aws configure set aws_access_key_id none
RUN aws configure set aws_secret_access_key none
