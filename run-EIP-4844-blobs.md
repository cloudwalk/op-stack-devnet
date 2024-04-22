# Enable Blobs (EIP-4844) For L2 Network 

Ganache is not fit for blob transactions yet, you need to run other local L1 network that supports `EIP-4844` and can provide `Beacon node RPC`.
For development [Prysm Devnet](https://docs.prylabs.network/docs/getting-started) can be used. The original Prysm devnet manual is available [here](https://docs.prylabs.network/docs/advanced/proof-of-stake-devnet).

## Step 1. Prerequisites

1. Generate configuration files `genesis.json`, `rollup.json` as described in [Running a single-node manual](./single-node-no-docker.md#1-prerequisites), follow instruction from **Step 1** to **Step 7**..

2. Clone `Prysm` denvet repository and head over to it:

```bash
    git clone https://github.com/Offchainlabs/eth-pos-devnet && cd eth-pos-devnet
```

## Step 2. Configure and run L1 network

1. Update `consensus/config.yml` file. 

Check if Deneb/Cancun fork is enabled. In file should be present variables:

```yaml
    DENEB_FORK_EPOCH: 0
    DENEB_FORK_VERSION: 0x20000093
```

Update time parameters as you need:

```yaml
    SECONDS_PER_SLOT: 2
    SLOTS_PER_EPOCH: 2
```

2. Update `docker-compose.yml` file.

Under `create-beacon-chain-genesis` service change `--fork` parameter in `command` section to:

```yaml
  - --fork=deneb
```

Add network that will be common for L1 and L2 networks at the bottom of file:

```yaml
  networks:
      op-local:
        driver: bridge
        name: op-local
        ipam:
          config:
            - subnet: 192.168.10.0/24
              gateway: 192.168.10.1
```

Update images to latest versions:

```yaml
  beacon-chain:
    image: "gcr.io/prysmaticlabs/prysm/beacon-chain:v5.0.3"
  geth:
    image: "ethereum/client-go:release-1.13"
  validator:
    image: "gcr.io/prysmaticlabs/prysm/validator:v5.0.3"
```

Add static IPs to containers:

```yaml
  beacon-chain:
  ...
    networks:
      op-local:
        ipv4_address: 192.168.10.2
  ...

  geth:
  ...
    networks:
      op-local:
        ipv4_address: 192.168.10.3
  ...

  validator:
  ...
    networks:
      op-local:
        ipv4_address: 192.168.10.4
  ...

```

Update `geth` ports to be accessible from L2 network:

```yaml
  geth:
    ...
    ports:
      - 8561:8551
      - 8555:8545
      - 8556:8546
    ...
```

Update `beacon-chain` ports to be accessible from L2 network:

```yaml
  beacon-chain:
    ...
    ports:
      - 4009:4000
      - 3509:3500
      - 8089:8080
      - 6069:6060
      - 9099:9090
    ...
```

**NOTE** Ports should be changed, because they are already used by L2 network.

3. Run `Prysm` devnet:

```bash
    docker-compose up -d
```

4. L1 network is ready to use, urls:

    * Beacon node RPC: http://192.168.10.2:3500
    * L1 RPC: http://192.168.10.3:8545

## Step 3. Configure and run L2 network

1. Use [Running a three-node network using Docker](./three-node-using-docker.md) manual to configure L2 network, follow from **Step 1** to **Step 3**.

2. Update `CW_OP_L1_BEACON_URL` variable in file `<l2-devnet-dir>/docker/prerequisite/envfile` to L1 Beacon node RPC url:

```bash
    export CW_OP_L1_BEACON_URL="http://192.168.10.2:3500"
```

3. Add beacon node RPC url to each node in `docker-compose.yml` files, example for `node1`:

```yaml
  node1-op-node:
    ...
    command:
      ...
      - --l1.beacon=$CW_OP_L1_BEACON_URL
      ...
    ...
    
```

4. Add fork timestamps to `node1-op-node` service (Sequencer) in `docker-compose.yml` file, they should be before L2 network start timestamp to run it with genesis block:

```yaml
  node1-op-node:
    ...
    command:
      ...
      - --override.canyon=1712742768
      - --override.delta=1712743568
      - --override.ecotone=1712743768
      ...
    ...
    
```

4. Add fork timestamps to `node1-op-geth` service (Execution) in `docker-compose.yml` file, they can be the same as for `node1-op-node`:

```yaml
  node1-op-geth:
    ...
    command:
      ...
      - --override.cancun=1712741768
      - --override.canyon=1712742768
      - --override.ecotone=1712743768
      ...
    ...
    
```

**NOTE** `delta` is not present in Execution service, there is added `cancun`.


5. Run L2 network:

Use [Running a three-node network using Docker](./three-node-using-docker.md) manual to run L2 network, follow from **Step 4** to the end.


## Step 3. Enable Blobs (EIP-4844) For L2 Network

To enable blobs for L2 there are necessary to do some additional steps, because L2 network is not supporting blobs by default. Original manuals:
    - [Prepare nodes for blobs](https://docs.optimism.io/builders/node-operators/management/blobs)
    - [Switch to Using Blobs](https://docs.optimism.io/builders/chain-operators/management/blobs)

1. Define `BaseFeeScalar` and `BlobBaseFeeScalar` and convert them into a single value with `ecotone-scalar utility`:

```bash
    cd ~/optimism/op-chain-ops
    ./bin/ecotone-scalar --scalar=1 --blob-scalar=11
```

Output will be like:
```bash
# base fee scalar     : 1
# blob base fee scalar: 11
# v1 hex encoding  : 0x0100000000000000000000000000000000000000000000000000000b00000001
# uint value for the 'scalar' parameter in SystemConfigProxy.setGasConfig():
452312848583266388373324160190187140051835877600158453279131187578155302913
```

2. Generate payload for setting `BaseFeeScalar` and `BlobBaseFeeScalar`, using `v1 hex encoding` value from previous step:

```bash
    cast calldata 'setGasConfig(uint256,uint256)' 0 0x0100000000000000000000000000000000000000000000000000000b00000001
```

Output will be like:
```bash
    0x935f029e00000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000b00000001
```

3. Find `SystemConfigProxy` contract address in your L1 network deploy file:

```bash
    cd ~/optimism/packages/contracts-bedrock
    cat deployments/local-op-devnet/.deploy | grep -E "(SystemConfigProxy)"
```
Output will be like:
```bash
    "SystemConfigProxy": "0x04C89607413713Ec9775E14b954286519d836FEf",
```

4. Call `setGasConfig` function in `SystemConfigProxy` contract with generated payload:

```bash
    cast send 0x04C89607413713Ec9775E14b954286519d836FEf 0x935f029e00000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000b00000001 -r http://192.168.10.3:8545 --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
```

Where:
    - `0x04C89607413713Ec9775E14b954286519d836FEf` is `SystemConfigProxy` contract address.
    - `-r` is L1 RPC url.
    - `--private-key` is private key of admin account that was used for deploy L2 contracts to L1 network.

5. Check if `BaseFeeScalar` and `BlobBaseFeeScalar` are set correctly:


```bash
    cast call 0x420000000000000000000000000000000000000F 'baseFeeScalar()(uint256)' --gas-price 10000000 --rpc-url http://192.168.10.11:8545
```

```bash
    cast call 0x420000000000000000000000000000000000000F 'blobBaseFeeScalar()(uint256)' --gas-price 10000000 --rpc-url http://192.168.10.11:8545
```

Where:
    - `0x420000000000000000000000000000000000000F` is `GasPriceOracle` predeployed contract address in L2 network.
    - `--rpc-url` is L2 RPC url.

**NOTE** It can take some time (~1min) to update values in L2 network and values should be the same as arguments for `ecotone-scalar` utility above.

6. Enable blobs in batcher by editing `node-01/docker-compose.yml` file:

```yaml
  node1-op-batcher:
    ...
    command:
      ...
      - --max-channel-duration=1500
      - --data-availability-type=blobs
      ...
    ...
```

Where:
    - `--max-channel-duration` is the maximum duration of a channel in seconds, for blobs it should be greater than for calldata.
    - `--data-availability-type` is the type of data availability, it should be set to `blobs` or `calldata`.

7. Restart batcher:

```bash
    cd docker/node-01-main
    sudo docker compose --env-file ../prerequisite/envfile restart node1-op-batcher
```
