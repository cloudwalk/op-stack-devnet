# OP-Stack Development Network

This repository contains instructions and scripts to run your own development blockchain based on [OP-Stack](https://stack.optimism.io/).

The blockchain will be operated on a network consisting of one or more nodes, serving as a layer 2 (L2) solution backed by another blockchain, which acts as layer 1 (L1).

The instructions provided in this repository draw heavily from the [OP-Stack Getting Started Guide](https://stack.optimism.io/docs/build/getting-started/). However, we have included several tips based on our practical experience and solutions to found issues.

These instructions are actual for the following versions of OP-Stack repositories:
* [optimism](https://github.com/ethereum-optimism/optimism), tag: `op-node/v1.7.2`;
* [op-geth](https://github.com/ethereum-optimism/op-geth), tag: `v1.101308.2`.

For alternative versions, please refer to the other branches and tags available in this repository.

## Available options
1. [Running a single-node network without Docker](./single-node-no-docker.md): This option provides a fully autonomous startup.
2. [Running a three-node network using Docker](./three-node-using-docker.md): This option requires specific files as outlined in option 1.
3. [Enable Blobs (EIP-4844) For L2 Network](./run-EIP-4844-blobs.md): Based on option 2 and provides a description for configuration and enabling blobs for L2 network. By default, the L2 network is running using common transaction data to store L2 information on L1.

## URLs

The URLs that will be available after implementing an appropriate option mentioned in the previous section.

### For option 1. The single L2 node network without Docker


| URL                        | Software Name       |
|----------------------------|---------------------|
| http://127.0.0.1:8545/     | L2 RPC endpoint     |


### For option 2. The three node network using Docker

#### RPC URLs L2

| URL private                | URL public             | Datasource node |
|----------------------------|------------------------|-----------------|
| http://192.168.10.11:8545/ | http://127.0.0.1:8545/ | node1           |
| http://192.168.10.21:8545/ | http://127.0.0.1:8565/ | node2           |
| http://192.168.10.31:8545/ | http://127.0.0.1:8575/ | node3           |

#### Blockscout explorer UI

| URL private                | URL public             | Software name     | Datasource node |
|----------------------------|------------------------|-------------------|-----------------|
| http://192.168.10.36:3000/ | http://127.0.0.1/      | Blockscout New UI | node3           |
| http://192.168.10.35:4005/ | http://127.0.0.1:4005/ | Blockscout Old UI | node3           |

#### Blockscout explorer DB

```bash
  postgresql://blockscout:ceWb1MeLBEeOIfk65gU8EjF8@db:5432/blockscout
```

#### Metrics services

| URL private                | URL public             | Software name |
|----------------------------|------------------------|---------------|
| http://192.168.10.44:3003/ | http://127.0.0.1:3003/ | Grafana       |
| http://192.168.10.45:9090/ | http://127.0.0.1:9090/ | Prometheus    |

### Debug services

| URL public             | Software name |
|------------------------|---------------|
| http://127.0.0.1:8889/ | Dozzle        |


### For option 3. Activating EIP-4844 blobs

#### Prysm devnet RPC URLs L1

| URL private               | URL public             | Description   |
|---------------------------|------------------------|---------------|
| http://192.168.10.2:3500/ | http://127.0.0.1:3500/ | Beacon RPC    |
| http://192.168.10.3:8545/ | http://127.0.0.1:8555/ | Execution RPC |
