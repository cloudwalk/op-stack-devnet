# Architecture for monitoring

This document describes the additional software to explorer the blokchain data, collect and output the L2 network metrics.
This software is integrated with docker containers from the [Running a three-node network using Docker](./three-node-using-docker.md) instruction.

The list of software as docker containers:

* **blockscout/blockscout:6.3.0**
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

During the first run of docker with metrics software it is necessary to create database and user for `op-geth`. To do it, run script:

```
   sudo scripts/influxdb.sh 
```

## Monitoring URLs


### Explorer services

| URL                        | Software name       | Datasource node |
|----------------------------|---------------------|-----------------|
| http://192.168.10.35:4000/ | Blockscout (old UI) | node3           |
| http://192.168.10.36:3000/ | Blockscout (new UI) | node3           |


### Metric services:

| URL                        | Software name |
|----------------------------|---------------|
| http://192.168.10.18:8888/ | Chronograf    |
| http://192.168.10.45:9090/ | Prometheus    |
| http://192.168.10.44:3003/ | Grafana       |

### Prometheus Metrics URLs:

| URL                                                | Application name | Datasource node |
|----------------------------------------------------|------------------|-----------------|
| http://192.168.10.31:6060/debug/metrics/prometheus | op-geth          | node3           |
| http://192.168.10.32:7300/metrics                  | op-node          | node3           |
| http://192.168.10.14:7300/metrics                  | op-proposer      | node1           |
| http://192.168.10.13:7300/metrics                  | op-batcher       | node1           |

### Metrics Datasources

`Op-geth` can provide two type of metrics sources:
* `op-geth` sends metrics directly to `influxDB`. In this case `op-geth` is responsible for saving data in `influxDB`.
* `op-geth` enables and provides http server with metrics for `prometheus`. In this case prometheus is responsible for checking the `op-geth` metrics URL and saving data. Therefore, additional requests from `prometheus` can create extra load on the server.

Because sequencer is enabled on `node1`, to have more correct metrics data `influxDB` was enabled on `node1`.
To avoid extra load on sequencer node, `prometheus` service and the `op-geth` metrics server were enable on `node3`.

## Grafana Configuration

To configure Grafana, it is necessary to login Grafana as an administrator, then define datasources and dashboards.

### Login Grafana

1. Go to Grafana URL: http://192.168.10.44:3003 .
2. Login with the creds:
   * Username: `root`.
   * Password: `root`.

### Adding Grafana Datasource

#### Adding InfluxDB Datasource

1. Go to menu `'Connections' -> 'Data Sources'`.
2. Click `Add new data source`.
3. Choose `InfluxDB`.
4. Set URL http://192.168.10.15:8086 .
5. Set credentials (should exist after InfluxDB extra step above):
   * a. Database: `geth`.
   * b. User: `geth`.
   * c. Password `geth`.
6. Click `Save & test`.

#### Adding Prometheus Datasource

1. Go to menu `'Connections' -> 'Data Sources'`
2. Click `Add new data source`.
3. Choose `Prometheus`.
4. Set URL: http://192.168.10.45:9090 .
6. Click `Save & test`.

### Adding Grafana Dashboards

#### Adding General InfluxDB and Prometheus dashboards

1. Go to menu `Dashboards`.
2. Click `New`.
3. Click `Import`.
4. In field `Import via grafana.com` enter `13877`. It will add the dashboard from the Grafana website (for InfluxDB):
   * https://grafana.com/grafana/dashboards/13877-single-geth-dashboard/
5. Click `Load`.
6. In field `InfluxDB` choose your `influxdb datasource`, created above. 
7. Click `import`.
8. Repeat steps 1-3.
9. In field `Import via grafana.com` enter `14053`. It will add the dashboard from the Grafana website (for Prometheus):
   * https://grafana.com/grafana/dashboards/14053-geth-overview/
10. Click `Load`.
11. In field `Prometheus` choose your `prometheus datasource`, created above.
12. Click `import`.


#### Adding Custom InfluxDB and Prometheus dashboards

Custom dashboards are located in folder `docker/metrics/dashboards`.

To add them:
1. Go to menu `Dashboards`.
2. Click `New`.
3. Click `Import`
4. Upload a file from folder `docker/metrics/dashboards`.
5. Click `Import`.
6. You should see a new dashboard.
