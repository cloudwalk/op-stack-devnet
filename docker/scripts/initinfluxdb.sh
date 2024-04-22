#!/bin/bash

set -euo pipefail # see https://gist.github.com/mohanpedala/1e2ff5661761d3abd0385e8223e16425

#InfluxDB creation
#echo "Creating InfluxDB database and user"
sudo docker exec -it influxdb influx -execute "CREATE DATABASE geth"
sudo docker exec -it influxdb influx -database 'geth' -execute "CREATE USER geth WITH PASSWORD 'geth' WITH ALL PRIVILEGES"
