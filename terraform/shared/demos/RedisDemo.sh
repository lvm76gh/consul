#! /bin/bash

# Pick the first host and launch Redis via Nomad

HOST=`grep \"public_ip\" terraform.tfstate | awk -F: '{print substr($2,3)}' | sed 's/\",//' | head -n1`


case "$1" in
	start)
		ssh -i consul.key ubuntu@$HOST  "nomad run example.nomad"
		ssh -i consul.key ubuntu@$HOST  "nomad status example"
		ssh -i consul.key ubuntu@$HOST  "nomad server-members"
		;;
	stop)
		ssh -i consul.key ubuntu@$HOST  "nomad stop example"
		;;
	status)
		ssh -i consul.key ubuntu@$HOST  "nomad status example"
		;;
	discover)
		ssh -i consul.key ubuntu@$HOST  "dig @127.0.0.1 -p 8600 redis.service.consul"
		;;
	*)
		echo $"Usage: $0 {start|stop|status|discover}"
		exit 1
esac
