#!/bin/bash
aws=$(which aws)
topic_arn="arn:aws:sns:us-west-1:810013023562:services-check"
beacon_status=$(ps -aux | grep -w "\/beacon-chain" | echo $?)
validator_status=$(ps -aux | grep -w "\/validator" | echo $?)
beacon_service=$(systemctl status eth-beacon | grep -ohP "(?<=Active:\s)([a-z]*)(\b)")
validator_service=$(systemctl status eth-validator | grep -ohP "(?<=Active:\s)([a-z]*)(\b)")
instance_id=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
timestamp=$(date)
disk_state=$(df -k /boot | grep -ohP "[0-9]?[0-9]?[0-9]%")

status_message=("instance_id":"${instance_id}","timestamp":"${timestamp}","beacon_status":"${beacon_service}","validator_status":"${validator_service}","disk_util":"${disk_state}")

sudo aws sqs send-message --queue-url https://sqs.us-east-1.amazonaws.com/80398EXAMPLE/MyQueue --message-body "$status_message" --delay-seconds 10

send=false
status_message="Status:"

if [ "$beacon_status" = "0" ]
then
    	status_message="${status_message} beacon-service is down"
        send=true
        echo "$status_message"
fi

if [ "$validator_status" = "0" ]
then
    	status_message="${status_message} validator-service is down"
        send=true
        echo "$status_message"
fi


if [ "$send" = true ]
then
    	echo "${status_message} sending message"
        sudo aws sns publish --topic-arn "$topic_arn" --message "$status_message" --region us-west-1
fi
