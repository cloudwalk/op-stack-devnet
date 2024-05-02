# Graphana Dashboards


## 1. Adding InfluxDB Datasource

1. Go to menu `'Connections' -> 'Data Sources'`.
2. Click `Add new data source`.
3. Choose `InfluxDB`.
4. Set URL http://192.168.10.15:8086 .
5. Set credentials (should exist after InfluxDB extra step above):
    * a. Database: `geth`.
    * b. User: `geth`.
    * c. Password `geth`.
6. Click `Save & test`.


## 2. Adding Prometheus Datasource

1. Go to menu `'Connections' -> 'Data Sources'`
2. Click `Add new data source`.
3. Choose `Prometheus`.
4. Set URL: http://192.168.10.45:9090 .
5. Click `Save & test`.


## 3. Adding General InfluxDB and Prometheus dashboards

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


## 4. Adding Custom InfluxDB and Prometheus dashboards

Custom dashboards are located in folder `docker/metrics/dashboards`.

To add them:
1. Go to menu `Dashboards`.
2. Click `New`.
3. Click `Import`
4. Upload a file from folder `docker/metrics/dashboards`.
5. Click `Import`.
6. You should see a new dashboard.
