#!/bin/bash
aws=$(which aws)
topic_arn="arn:aws:sns:us-west-1:810013023562:services-check"
beacon_status=$(ps -aux | grep -w "\/beacon-chain" | echo $?)
validator_status=$(ps -aux | grep -w "\/validator" | echo $?)

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
