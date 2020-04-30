#!/bin/bash
# description: Starts and stops the Prysm Beacon service

service_dir="/prysm"
service_name="eth-beacon"
prysm_service=${service_dir}/prysm.sh
prysm_pid_file=${service_dir}/prysm-beacon.pid

test -x $prysm_service || {
	echo "$service_name service file missing"
	exit 1
}

RETVAL=0


start() {
	KIND="$service_name"
	echo -n $"Starting $service_name : "
	$prysm_service beacon-chain --datadir=$service_dir/beacon-chain & pid=$!
	echo "$pid" >> $prysm_pid_file
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
			if [ "$(cat ${pid_dir}/stat | awk '{print $2}' | tr -d '()')" == "eth-beacon" ]
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
