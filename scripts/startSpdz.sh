#!/bin/bash
# Start a SPDZ process, passing in spdz program to run. 
# This example uses a docker container running on a single host 
#  and relies on a user defined bridge network: 
#   docker network create --driver bridge spdz_nw
# and then HOSTS.config containing a list of container_name which will map to IP.
# Interface must match spdz-proxy runSpdzFunction.

player_id=${1:-"none"}

if [ "$player_id" == "none" ]; then
  (>&2 echo "No player id given.")
  exit 1
fi

spdz_pgm=${2:-"none"}

if [ "$SPDZ_PGM" == "none" ]; then
  (>&2 echo "No spdz function name given.")
  exit 1
fi

container_name="spdz-analytics-$player_id"
base_port=13000
internal_port=$(($base_port + $player_id))
client_port=$((14000 + $player_id))

docker run -d --rm --name $container_name --expose $internal_port -p $internal_port:$internal_port --expose $client_port -p $client_port:$client_port --env playerId=$player_id --env mpcPgm=$spdz_pgm --env basePort=$base_port -v /Users/je0018/temp/Player-Data:/usr/spdz/Player-Data -v /Users/je0018/temp/logs:/usr/spdz/logs -v /Users/je0018/temp/HOSTS.config:/usr/spdz/HOSTS.config --network=compose_spdz_nw spdz/analytics:v0.1.1

exit $?
