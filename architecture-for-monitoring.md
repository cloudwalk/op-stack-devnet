# Architecture for monitoring

This document describes the additional software to explorer the blokchain data, collect and output the L2 network metrics.
This software is integrated with docker containers from the [Running a three-node network using Docker](./three-node-using-docker.md) instruction.

The list of software as docker containers:

* **blockscout/blockscout:latest**
* **prom/prometheus:latest**
* **grafana/grafana:10.1.2**
* **influxdb:1.8.10**
* **chronograf:1.8.10-alpine**
* **telegraf:alpine**
* **kapacitor:alpine**

## Extra steps for activate metrics collection

### Telegraf

Before running docker, it is necessary to send docker group id (GID) to telegraf container in env variable `CW_OP_TELEGRAF_DOCKER_ID`:

1. Get the number of docker GID by running the following command in the terminal:

   ```
   $(stat -c '%g' /var/run/docker.sock)
   ```

2. Set the outputted number to variable `CW_OP_TELEGRAF_DOCKER_ID` in file `docker/prerequisite/envfile`

### InfluxDB

During the first run of docker with metrics software it is necessary to create database and user for `op-geth`:

1. Run the following command in terminal to enter the `influxDB` docker container:
   ```
   sudo docker exec -it influxdb bash
   ```

2. Create a database and a user for `op-geth`:

   ```
   influx -execute "CREATE DATABASE geth"
   
   influx -database 'geth' -execute "CREATE USER geth WITH PASSWORD 'geth' WITH ALL PRIVILEGES"
   ```

## Monitoring Urls


### Explorer services

| URL | Software Name | Datasource node |
|---|---|---|
|http://192.168.10.33:4000/| Blockscout | node3 |


### Metric services:

| URL                        | Software Name |
|----------------------------|---------------|
| http://192.168.10.18:8888/ | Chronograf    |
| http://192.168.10.44:9090/ | Prometheus    |
| http://192.168.10.39:3003/ | Grafana       |

### Prometheus Metrics Urls:

| URL | Application Name | Datasource node |
|---|---|---|
|http://192.168.10.31:6060/debug/metrics/prometheus| op-geth | node3 |
|http://192.168.10.32:7300/metrics| op-node      | node3 |
|http://192.168.10.14:7300/metrics| op-proposer  | node1 |
|http://192.168.10.13:7300/metrics| op-batcher   | node1 |

### Metrics Datasources

`Op-geth` can provide two type of metrics sources:
* `op-geth` sends metrics directly to `influxDB`. In this case `op-geth` is responsible for saving data in `influxDB`.
* `op-geth` enables and provides http server with metrics for `prometheus`. In this case prometheus is responsible for checking the `op-geth` metrics URL and saving data. Therefore, additional requests from `prometheus` can create extra load on the server.

Because sequencer is enabled on `node1`, to have more correct metrics data `influxDB` was enabled on `node1`.
To avoid extra load on sequencer node, `prometheus` service and the `op-geth` metrics server were enable on `node3`.

## Grafana Configuration

To configure grafana, it is necessary to define datasources and dashboards.

To enter grafana:
1. go to Grafana url - http://192.168.10.39:3003
2. Enter with creds
   * username: `root`
   * password: `root`

### Adding Grafana Datasources

**To add InfluxDB datasource**:

1. go to menu `'Connections' -> 'Data Sources'`
2. click `Add new data source`
3. Choose `InfluxDB`
4. set url http://192.168.10.15:8086
5. set credentials (should exist after influxdb extra step above):
   * a. Database: `geth`
   * b. User: `geth`
   * c. Password `geth`
6. Click `Save & test`

**To add Prometheus datasource**:

1. go to menu `'Connections' -> 'Data Sources'`
2. click `Add new data source`
3. Choose `Prometheus`
4. set url http://192.168.10.44:9090
6. Click `Save & test`

### Adding Grafana Dashboards

**To add InfluxDB and Prometheus dashboards**:
1. go to menu `Dashboards`
2. click `New`
3. click `Import`
4. in field `Import via grafana.com` enter `13877`. It will add dashboard from grafana website (for influxDB):
   * https://grafana.com/grafana/dashboards/13877-single-geth-dashboard/
5. click `Load`
6. in field `InfluxDB` choose your `influxdb datasource`, created above. 
7. click `import`
8. repeat steps 1-3
9. in field `Import via grafana.com` enter `14053`. It will add dashboard from grafana website (for Prometheus):
   * https://grafana.com/grafana/dashboards/14053-geth-overview/
10. click `Load` 
11. in field `Prometheus` choose your `prometheus datasource`, created above.
12. click `import`


**Add Custom Prometheus dashboard**:

Custom dashboards are located in folder `docker/metrics/dashboards`. To add it:

1. go to menu `Dashboards`
2. click `New`
3. click `Import`
4. upload file from folder `docker/metrics/dashboards`
5. click `Import`
6. You should see new dashboard

After these steps you should have 2 almost the same dashboards loaded from grafana website.
