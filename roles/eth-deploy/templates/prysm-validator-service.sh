#!/bin/bash
# description: Starts and stops the Prysm Validator service

service_dir="/home/eth_usr/prysm"
service_name="eth-validator"
prysm_service=${service_dir}/prysm.sh
prysm_pid_file=${service_dir}/prysm-validator.pid
prysm_cred=${service_dir}/cred

test -x $prysm_service || {
	echo "$service_name service file missing"
	exit 1
}

test -e  $prysm_cred || {
	echo "$service_name cred file missing"
	exit 1
}

test -e  $prysm_cred/validator || {
	echo "$service_name validator keystore not configured"
	exit 1
}

RETVAL=0


start() {
	echo -n $"Starting $service_name : "
	cred=$(cat $prysm_cred)
	$prysm_service validator --keystore-path=$service_dir/validator --password=$cred &
	echo $!> $prysm_pid_file
	echo "."
	return 0
}

stop() {
	echo -n $"Shutting down $service_name : "
	if [ -f "$prysm_pid_file" ]
	then
		pid=$(cat $prysm_pid_file)
		if [ -n "$pid" -a -d /proc/$pid ]
		then
			kill $pid
			sudo rm -rf $prysm_pid_file
		fi
	fi
	echo "."
	return 0
}

restart() {
	stop
	sleep 3
	start
}

status() {
	if [ -f "$prysm_pid_file" ]
	then
		exp_pid=$(cat $prysm_pid_file)
		pid_dir="/proc/$exp_pid"
		if [ -d "$pid_dir" ]
		then
			if [ "$(cat ${pid_dir}/stat | awk '{print $2}' | tr -d '()')" == "eth-validator" ]
			then
				echo "$service_name is running"
				return 0
			fi
		fi
	fi
	echo "$service_name is not running"
	return 3
}

case "$1" in
	start)
		start
		;;
	stop)
		stop
		;;
	restart)
		restart
		;;
	status)
		status
		;;
	*)
		echo $"Usage: $0 {start|stop|restart|status}"
		exit 1
esac

exit $?
