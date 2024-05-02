# Running a three-node L2 network based on OP-Stack using Docker

This instruction is actual for the following versions of OP-Stack repositories:
* [optimism](https://github.com/ethereum-optimism/optimism), tag: `v1.7.2`;
* [op-geth](https://github.com/ethereum-optimism/op-geth), tag: `v1.101308.2`.

*WARING:* The instruction below is for test purposes only and it should not be used in production. At least you should protect private keys of accounts that are used to create and run the L2 network and appropriate contracts on L1 network. It is strongly recommended to use hardware keys or special services to generate and use private keys (like OpenZeppelin Defender).

## 1. Prerequisites and notes

1. The following software should be installed:

    * `docker`;
    * `jq`.

2. This instruction was checked on:

    * `Ubuntu 22.04.4 LTS`;
    * `docker version 25.0.4, build 1a576c5` installed according to the [official instructions](https://docs.docker.com/desktop/install/ubuntu/);
    * `jq` installed as `sudo apt install -y jq`.

3. *IMPORTANT!* The following conditions must be met:
    * a. The network that is used as L1 is up and running.
    * b. All the needed L1 contracts have been deployed in it.
    * c. You have the following files to run the L2 network:
        * `genesis.json` contains the genesis information of the L2 network;
        * `rollup.json` contains the configuration of the L2 network.
    * d. No other L2 nodes with the same set of `genesis.json` and `rollup.json` files are running. 

    If one of the conditions is not met follow the instruction [here](./single-node-no-docker.md). Execute all the steps in order until you meet all the mentioned conditions.

4. The following Docker images are used in this instruction:
    * [philpher/optimism:v1.7.2](https://hub.docker.com/layers/philpher/optimism/v1.7.2/images/sha256-976c69724115e6515dbc9921868dcaa6ededed058d8e9f62e981cb0ea8155f74?context=explore);
    * [philpher/op-geth:v1.101308.2](https://hub.docker.com/layers/philpher/op-geth/v1.101308.2/images/sha256-e1ce183978b9be208b13f74a22f4744d3a396fd2d553e7832c1f78748f6181f1?context=repo);

    If you want to use your own images created from scratch follow the instruction [here](./docker-images.md).

5. Be sure subnet `192.168.10.0/24` is not used on your local machine and there is no Docker network named `op-local`.

6. All the docker commands in this instruction are executed from the superuser using the `sudo` prefix.


## 2. Generate P2P keys and IDs for nodes

1. Generate or select some 32-bit (64 hex chars) private keys, like:

    ```
    d01aba27820aeeb60ead4aed481eb30107426c18fd2e3133f1abac8fcd570d01
    d02aba27820aeeb60ead4aed481eb30107426c18fd2e3133f1abac8fcd570d02
    d03aba27820aeeb60ead4aed481eb30107426c18fd2e3133f1abac8fcd570d03
    ```

    Those keys are needed to organize P2P communications between nodes of the future L2 network.

2. For each private key generate the appropriate P2P ID with the following commands:

    ```bash
    sudo docker run -itd --name op_node_p2p_generation philpher/optimism:v1.7.2
    sudo docker exec op_node_p2p_generation sh -c 'echo "<put_first_private_key_here>" | op-node p2p priv2id'
    sudo docker exec op_node_p2p_generation sh -c 'echo "<put_second_private_key_here>" | op-node p2p priv2id'
    sudo docker exec op_node_p2p_generation sh -c 'echo "<put_third_private_key_here>" | op-node p2p priv2id'
    sudo docker rm -f op_node_p2p_generation
    ```

    With the private keys from above you'll get the following IDs:

    ```
    16Uiu2HAmFj2KVQEQQtgURtJKSWUmCgRsgeGs4piWP1YCREe64VLZ
    16Uiu2HAmMgZfTriZqMDDrHCUAibcaKyv8ByV8qWuSFXLpss8Rjxb
    16Uiu2HAmDKq53ypBfPNfAnwKvKwxXWjmVZ2viQahhWaaGntEqtPC
    ```

    The IDs are needed to organize P2P communications between nodes of the future L2 network.

## 3. Configure the infrastructure

1. Head over to the [docker/prerequisite](./docker/prerequisite) directory of this repository:

    ```bash
    cd ./docker/prerequisite
    ```

    This directory contains files with settings of the future L2 network.


2. Replace files `genesis.json` and `rollup.json` with ones your have.


3. Open file [envfile](./docker/prerequisite/envfile). Replace its content with appropriate data and data you've got previously, like:

    ```bash
    #!/bin/bash
    # Main parameters
    export CW_OP_SEQUENCER_KEY="7c852118294e51e653712a81e05800f419141751be58f605c371e15141b007a6"
    export CW_OP_SEQUENCER_ADDRESS="0x90F79bf6EB2c4f870365E785982E1f101E93b906"
    export CW_OP_L1_RPC_URL="http://dockerhost:8333"
    export CW_OP_L1_RPC_KIND="basic" # Available options are: alchemy, quicknode, parity, nethermind, debug_geth, erigon, basic, and any
    export CW_OP_BATCHER_KEY="5de4111afa1a4b94908f83103eb1f1706367c2e68ca870fc3fb9a804cdab365a"
    export CW_OP_PROPOSER_KEY="59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d"
    export CW_OP_L2OOP_ADDRESS="0xDc64a140Aa3E981100a9becA4E685f962f0cF6C9" # Address of the "L2OutputOracleProxy" contract on L1
    export CW_OP_CONFIG_NAME="local-op-devnet"
    export CW_OP_L2_NETWORK_ID=3007
    
    # P2P parameters
    export CW_OP_P2P_PRIVATE_KEY_NODE1="d01aba27820aeeb60ead4aed481eb30107426c18fd2e3133f1abac8fcd570d01"
    export CW_OP_P2P_PRIVATE_KEY_NODE2="d02aba27820aeeb60ead4aed481eb30107426c18fd2e3133f1abac8fcd570d02"
    export CW_OP_P2P_PRIVATE_KEY_NODE3="d03aba27820aeeb60ead4aed481eb30107426c18fd2e3133f1abac8fcd570d03"
    export CW_OP_P2P_ID_NODE1="16Uiu2HAmFj2KVQEQQtgURtJKSWUmCgRsgeGs4piWP1YCREe64VLZ"
    export CW_OP_P2P_ID_NODE2="16Uiu2HAmMgZfTriZqMDDrHCUAibcaKyv8ByV8qWuSFXLpss8Rjxb"
    export CW_OP_P2P_ID_NODE3="16Uiu2HAmDKq53ypBfPNfAnwKvKwxXWjmVZ2viQahhWaaGntEqtPC"
    
    # Docker images for node apps
    export CW_OP_IMAGE_OP_STACK="philpher/optimism:v1.7.2"
    export CW_OP_IMAGE_OP_GETH="philpher/op-geth:v1.101308.2"
    ```

    *Tip:* If your use the L1 network running locally on your machine do not forget to replace the `CW_OP_L1_RPC_URL` env variable from `localhost` to `dockerhost`. Otherwise, Docker containers will not be able to access you machine.


## 4. Run and manage containers

1. Head over to the [docker](./docker) directory of this repository:

    ```bash
    cd ./docker
    ```

    The subdirectories like `node-0x...` of this directory contains `docker-compose` files and scripts to run Docker containers with node apps of the future L2 network.

2. If you want to change or completely remove the forwarding ports from the containers to your local machine edit `ports` sections in all `docker-compose.yaml` files in the directory.

    <details>
    <summary>The current set of forwarded ports is in this hidden section</summary>
        
        ```yaml
        node1:
          op-geth:
            ports:
              - "8551" # Authenticated RPC, to communicate with the `op-node`
              - "8545" # RPC
              - "8546" # WebSocket
          op-node:
            ports:
              - "8547" # Rollup RPC, to execute special commands of the node
          op-batcher:
            ports:
              - "8548" # Batcher RPC, to safe stop and maybe some other commands
          op-proposer:
            ports:
              - "8560" # Proposer RPC, just for possible future usage
           
        node2:
          op-geth:
            ports:
              - "8571" # Authenticated RPC, to communicate with the `op-node`
              - "8565" # RPC
              - "8566" # WebSocket
          op-node:
            ports:
              - "8567" # Rollup RPC, to execute special commands of the node
        
        node3:
          op-geth:
            ports:
              - "8581" # Authenticated RPC, to communicate with the `op-node`
              - "8575" # RPC
              - "8576" # WebSocket
          op-node:
            ports:
              - "8577" # Rollup RPC, to execute special commands of the node
        ```
    </details>

3. Execute the [init.sh](./docker/init.sh) script to initialize all the needed files to run the containers:
    ```bash
    sudo ./init.sh
    ```
    Be sure there is no warnings and errors during its execution.

4. Execute the [up.sh](./docker/up.sh) script to up and run all the containers:
    ```bash
    sudo ./up.sh
    ```

5. Be sure that all containers are working using the command:
    ```bash
    sudo docker ps -a --format 'table {{.ID}}\t{{.Image}}\t{{.Command}}\t{{.RunningFor}}\t{{.Status}}\t{{.Names}}'
    ```
    You should see something like:
    ```
    CONTAINER ID   IMAGE                                    COMMAND                  CREATED          STATUS                      NAMES
    1ca8355b0a57   chronograf:1.8.10-alpine                 "/entrypoint.sh chro…"   14 seconds ago   Up 13 seconds               chronograf
    f064a9c8c3eb   telegraf:alpine                          "/entrypoint.sh tele…"   15 seconds ago   Up 14 seconds               telegraf
    b75961b9ad2b   amir20/dozzle:latest                     "/dozzle"                11 minutes ago   Up 11 minutes               dozzle
    5317a381401c   nginx                                    "/docker-entrypoint.…"   11 minutes ago   Up 11 minutes               proxy
    5cfde2dd49ef   ghcr.io/blockscout/frontend:latest       "./entrypoint.sh nod…"   11 minutes ago   Up 11 minutes               frontend
    8beff3536c23   ghcr.io/blockscout/stats:latest          "./stats-server"         11 minutes ago   Up 11 minutes               stats
    61122b0f4956   blockscout/blockscout-optimism:6.3.0     "sh -c 'bin/blocksco…"   11 minutes ago   Up 11 minutes               backend
    f6d21b99ce6c   postgres:15                              "docker-entrypoint.s…"   11 minutes ago   Up 11 minutes (healthy)     stats-db
    00655118417f   postgres:15                              "docker-entrypoint.s…"   11 minutes ago   Up 11 minutes (healthy)     db
    5f9c9b270540   postgres:15                              "sh -c 'chown -R 200…"   11 minutes ago   Exited (0) 11 minutes ago   explorer-stats-db-init-1
    717e223c33f0   postgres:15                              "sh -c 'chown -R 200…"   11 minutes ago   Exited (0) 11 minutes ago   explorer-db-init-1
    5d4d39eadc4b   redis:alpine                             "docker-entrypoint.s…"   11 minutes ago   Up 11 minutes               redis-db
    fb8120997a7b   ghcr.io/blockscout/visualizer:latest     "./visualizer-server"    11 minutes ago   Up 11 minutes               visualizer
    d33eca03975a   ghcr.io/blockscout/sig-provider:latest   "./sig-provider-serv…"   11 minutes ago   Up 11 minutes               sig-provider
    2cdda666fad0   kapacitor:alpine                         "/entrypoint.sh kapa…"   11 minutes ago   Up 11 minutes               kapacitor
    50a73546a490   prom/prometheus:latest                   "/bin/prometheus --c…"   11 minutes ago   Up 11 minutes               prometheus
    0e2b4715a1d4   grafana/grafana:10.1.2                   "/run.sh"                11 minutes ago   Up 11 minutes               grafana
    82cbf33b56c5   influxdb:1.8.10                          "/entrypoint.sh infl…"   11 minutes ago   Up 11 minutes               influxdb
    a371260fb736   philpher/optimism:v1.7.2                 "op-node --l2=http:/…"   11 minutes ago   Up 11 minutes               node3-op-node
    90329bf5950d   philpher/op-geth:v1.101308.2             "geth --datadir=/dat…"   11 minutes ago   Up 11 minutes               node3-op-geth
    f28c589fe070   philpher/optimism:v1.7.2                 "op-node --l2=http:/…"   11 minutes ago   Up 11 minutes               node2-op-node
    f4751c143bb2   philpher/op-geth:v1.101308.2             "geth --datadir=/dat…"   11 minutes ago   Up 11 minutes               node2-op-geth
    134e97552393   philpher/optimism:v1.7.2                 "op-proposer --poll-…"   11 minutes ago   Up 11 minutes               node1-op-proposer
    375c9d912625   philpher/optimism:v1.7.2                 "op-batcher --l2-eth…"   11 minutes ago   Up 11 minutes               node1-op-batcher
    0fcaf31dd04c   philpher/optimism:v1.7.2                 "op-node --l2=http:/…"   11 minutes ago   Up 11 minutes               node1-op-node
    cc4fe6d140c8   philpher/op-geth:v1.101308.2             "geth --datadir=/dat…"   11 minutes ago   Up 11 minutes               node1-op-geth
    ```
    If some containers are stopped, just repeat the previous step again. Usually `proposer` or `batcher` might not start the first time due to delays in other containers.

    If after 3 tries some containers are still stopped (especially `op-node` or `op-geth`), explorer their logs using the appropriate docker command, like:
    ```bash
    sudo docker logs node1-op-node
    ```

6. To stop and remove all the containers (but not their data) execute the [down.sh](./docker/down.sh) script:
    ```bash
    sudo ./down.sh
    ```
    After that, if you execute the [up.sh](./docker/up.sh) script again the network will start with the already existing blockchain history (minted blocks and transactions).

7. To delete the data of all containers after stopping them execute the [clear.sh](./docker/clear.sh) script:
    ```bash
    sudo ./clear.sh
    ```
    After that, you'll have to execute the [init.sh](./docker/init.sh) script before running the network again. In that case the network will start from scratch (without previously minted blocks and transactions, except the genesis block).


## 5. Use the newly created L2 network

1. The nodes of the network can be accessed through their Docker internal IP addresses and ports or through the forwarded ports if you configured them (see the `docker-compose.yml` files). E.g. the default RPC URL of nodes are listed in the table bellow:
    
    | Node | Container     | In-container RPC URL      | Forwarded port RPC URL |
    |------|---------------|---------------------------|------------------------|
    | 1    | node1-op-node | http://192.168.10.11:8545 | http://127.0.0.1:8545  |
    | 2    | node2-op-node | http://192.168.10.21:8545 | http://127.0.0.1:8565  |
    | 3    | node3-op-node | http://192.168.10.31:8545 | http://127.0.0.1:8575  |

2. You can check that blocks are being produced and can be accessed through each node with the following script:

    ```bash
    sh docker/scripts/checkblocks.sh
    ```

    The last block number of all three nodes should differ by no more than 1.

3. Information about getting native tokens (ETH) inside the newly created L2 network see [here](single-node-no-docker.md#9-use-the-newly-created-l2-network).

## 6. Additional software for monitoring

This docker installation includes also software for:
* exploring the blockchain data (blocks, transactions, etc.);
* gathering and display various metrics of the L2 network.

### 6.1. Pre-installed software

* [Blockscout(blockscout/blockscout:6.3.0)](https://docs.blockscout.com/) -- a block explorer preconfigured for `Geth`. It works by requesting blocks data and other information from `op-geth`.
* [Grafana(grafana/grafana:10.1.2)](https://grafana.com/) -- a monitoring platform to collect and output metrics data. It works with Prometheus and InfluxDB as datasources.
* [Prometheus(prom/prometheus:latest)](https://prometheus.io/) -- a system for monitoring and collecting metrics data, output data and provide data to Grafana dashboards. It collects data from all node applications: `op-geth`, `op-node`, `op-proposer`, `op-batcher`.  
* [InfluxDB(influxdb:1.8.10)](https://www.influxdata.com/) -- a database to collect and provide metrics data to Grafana. It is used only by `op-geth` to send the metrics directly as opposed to Prometheus, which periodically polls applications to gather the necessary metrics.
* [Chronograf(chronograf:1.8.10-alpine)](https://www.influxdata.com/time-series-platform/chronograf/) -- a user interface for `InfluxDB`.
* [Telegraf(telegraf:alpine)](https://www.influxdata.com/time-series-platform/telegraf/) -- an agent for collecting and sending all metrics. It works with `InfluxDB` and `Chronograf`.
* [Kapacitor(kapacitor:alpine)](https://www.influxdata.com/time-series-platform/kapacitor/) -- a data processing engine. It works with `InfluxDB` and `Chronograf`.

**Note:** All metric software docker-compose configuration files are stored in folder [docker/metrics](docker/metrics).
All explorer software docker-compose configuration files are stored in folder [docker/explorer](docker/explorer).

### 6.2. Metrics Datasources

`Op-geth` can provide two type of metrics sources:
* `op-geth` sends metrics directly to `influxDB`. In this case `op-geth` is responsible for saving data in `influxDB`.
* `op-geth` enables and provides http server with metrics for `prometheus`. In this case prometheus is responsible for checking the `op-geth` metrics URL and saving data. Therefore, additional requests from `prometheus` can create extra load on the server.

Because sequencer is enabled on `node1`, to have more correct metrics data `influxDB` was enabled on `node1`.
To avoid extra load on sequencer node, `prometheus` service and the `op-geth` metrics server were enable on `node3`.

### 6.3. Enabling the block explorer

No changes in configuration of nodes is needed. The explorer requests blocks and additional information from `op-geth` on `node3` through the JSON RPC.

To allow Blockscout explorer to collect data from `op-geth` on `node3` the following flags were updated to the appropriate `docker-compose.yml` file:
```
  --http.api=debug,admin,db,eth,web3,net,personal,txpool,clique
  --ws.api=debug,admin,db,eth,web3,net,personal,txpool
```

### 6.4. Enabling metrics

`op-geth` allows to collect data in `InfluxDB` and `Prometheus`.

To allow `InfluxDB` metrics collection for `op-geth` on `node1` the following flags were added to the appropriate `docker-compose.yml` file:

```
  - --metrics
  - --metrics.expensive
  - --metrics.influxdb
  - --metrics.influxdb.endpoint=http://192.168.10.15:8086 #influxdb container IP
  - --metrics.influxdb.username=geth
  - --metrics.influxdb.password=geth
  - --metrics.influxdb.database=geth
  - --metrics.addr=192.168.10.11
```

To allow `Prometheus` metrics collection for `op-geth` on `node3` the following flags were added to the appropriate `docker-compose.yml` file:

```
  - --metrics
  - --metrics.addr=192.168.10.31
  - --metrics.expensive
```

To allow metrics collection for `op-node` on `node3` and  `op-batcher`, `op-proposer` on `node1` the following flag were added to the appropriate `docker-compose.yml` files:
```
- --metrics.enabled
```

### 6.5. Telegraf activation

Before running docker, it is necessary to send docker group id (GID) to telegraf container in env variable `CW_OP_TELEGRAF_DOCKER_ID`:

1. Get the number of docker GID by running the following command in the terminal:

   ```
   $(stat -c '%g' /var/run/docker.sock)
   ```

2. Set the outputted number to variable `CW_OP_TELEGRAF_DOCKER_ID` in file `docker/prerequisite/envfile`

### 6.6. InfluxDB activation

During the first run of docker with metrics software it is necessary to create database and user for `op-geth`. To do it, run script:

```bash
sudo scripts/influxdb.sh 
```

### 6.7. Explorer services URLs

| URL                        | Software name       | Datasource node |
|----------------------------|---------------------|-----------------|
| http://192.168.10.35:4000/ | Blockscout (old UI) | node3           |
| http://192.168.10.36:3000/ | Blockscout (new UI) | node3           |


### 6.8. Metric services URLs

| URL                        | Software name |
|----------------------------|---------------|
| http://192.168.10.18:8888/ | Chronograf    |
| http://192.168.10.45:9090/ | Prometheus    |
| http://192.168.10.44:3003/ | Grafana       |

### 6.9. Prometheus Metrics URLs

| URL                                                | Application name | Datasource node |
|----------------------------------------------------|------------------|-----------------|
| http://192.168.10.31:6060/debug/metrics/prometheus | op-geth          | node3           |
| http://192.168.10.32:7300/metrics                  | op-node          | node3           |
| http://192.168.10.14:7300/metrics                  | op-proposer      | node1           |
| http://192.168.10.13:7300/metrics                  | op-batcher       | node1           |

### 6.10. Grafana Configuration

To configure Grafana, it is necessary to login Grafana as an administrator, then define datasources and dashboards.

#### 6.10.1. Grafana Login

1. Go to Grafana URL: http://192.168.10.44:3003 .

2. Login with the creds:
    * Username: `root`.
    * Password: `root`.

#### 6.10.2. Graphan Dashboards

Use [Graphana Dashboards](./graphana-dashboards.md) instruction to add datasources and dashboards. 

## 7. Debug Mode

This option was added to allow manage docker containers logs with web interface.

For this purpose there was added new docker container [Dozzle](https://dozzle.dev/) that output logs from all containers in real time.

### 7.1. Debug service URL

| URL                        | Software Name       |
|----------------------------|---------------------|
| http://localhost:8889/     | Dozzle log viewer   |


### 7.2. Running Environment with Debug Mode

To run the environment with debug mode, it is necessary to add `--debug` flag to [up.sh](./docker/up.sh) command:

```bash
sudo ./up.sh --debug
```

### 7.3. Stop Environment with Debug Mode

Stopping debug mode is implemented with the same command as stopping the environment without debug mode:

```bash
sudo ./down.sh
```
