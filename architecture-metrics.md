# Architecture to collect and output metrics data

Metrics integrated with dockers from instruction:

* [Running a three-node network using Docker](./three-node-using-docker.md)

To collect metrics here are used next metrics software (docker images):

* **blockscout/blockscout:latest**
* **prom/prometheus:latest**
* **grafana/grafana:10.1.2**
* **influxdb:1.8.10**
* **chronograf:1.8.10-alpine**
* **telegraf:alpine**
* **kapacitor:alpine**

## Extra steps

### Telegraf

Before running docker, it is necessary to send docker group id (GID) to telegraf container in env variable `CW_OP_TELEGRAF_DOCKER_ID`.

To see number of docker GID, run in terminal:

```
$(stat -c '%g' /var/run/docker.sock)
```

Then, set outputted number for variable `CW_OP_TELEGRAF_DOCKER_ID` in file `docker/prerequisite/envfile`

### InfluxDB

After first run dockers with metrics software it is necessary to create database and user for `op-geth`:

1) **To enter influxDB docker container, run in terminal:**
```
sudo docker exec -it influxdb bash
```

2) **To Create Database and Geth User, run in docker terminal after previous step:**

```
influx -execute "CREATE DATABASE geth"

influx -database 'geth' -execute "CREATE USER geth WITH PASSWORD 'geth' WITH ALL PRIVILEGES"
```

## Metrics Urls

### Metric services:

| URL | Software Name |
|--------------|---------------|
|http://192.168.10.33:4000/| Blockscout    |
|http://192.168.10.43:8888/| Chronograf    |
|http://192.168.10.44:9090/| Prometheus    |
|http://192.168.10.39:3003| Grafana       |

### Prometheus Metrics Urls:

| URL | Service Name |
|--------------|--------------|
|http://192.168.10.31:6060/debug/metrics/prometheus| op-geth      |
|http://192.168.10.32:7300/metrics| op-node      |
|http://192.168.10.14:7300/metrics| op-proposer  |
|http://192.168.10.13:7300/metrics| op-batcher   |


## Grafana Configuration

To configure grafana, it is necessary to define datasources and dashboards.

To enter grafana:
1) go to Grafana url - http://192.168.10.39:3003
2) Enter with creds
   * username: `root`
   * password: `root`

**To add InfluxDB datasource**:

1) go to menu `'Connections' -> 'Data Sources'`
2) click `Add new data source`
3) Choose `InfluxDB`
4) set url http://192.168.10.40:8086
5) set credentials (should exist after influxdb extra step above):
   1) Database: `geth`
   2) User: `geth`
   3) Password `geth`
6) Click `Save & test`

**To add Prometheus datasource**:

1) go to menu `'Connections' -> 'Data Sources'`
2) click `Add new data source`
3) Choose `Prometheus`
4) set url http://192.168.10.44:9090
6) Click `Save & test`

**To add InfluxDB and Prometheus dashboards**:
1) go to menu `Dashboards`
2) click `New`
3) click `Import`
4) in field `Import via grafana.com` enter `13877`. It will add dashboard from grafana website (for influxDB):
   1)  https://grafana.com/grafana/dashboards/13877-single-geth-dashboard/
5) click `Load`
6) in field `InfluxDB` choose your `influxdb datasource`, created above. 
7) click `import`
8) repeat steps 1-3
9) in field `Import via grafana.com` enter `14053`. It will add dashboard from grafana website (for Prometheus):
   1) https://grafana.com/grafana/dashboards/14053-geth-overview/
10) click `Load` 
11) in field `Prometheus` choose your `prometheus datasource`, created above.
12) click `import`

After these steps you should have 2 almost the same dashboards loaded from grafana website.
