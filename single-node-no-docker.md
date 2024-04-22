# Running a single-node L2 network based on OP-Stack without Docker

This instruction is actual for the following versions of OP-Stack repositories:

* [optimism](https://github.com/ethereum-optimism/optimism), tag: `v1.7.2`;
* [op-geth](https://github.com/ethereum-optimism/op-geth), tag: `v1.101308.2`.

*WARING:* The instruction below is for test purposes only and should not be used in production. At least you should
protect private keys of accounts that are used to create and run the L2 network and appropriate contracts on the L1
network. It is strongly recommended to use hardware keys or special services to generate and use private keys
like [OpenZeppelin Defender](https://docs.openzeppelin.com/defender/).

## Step 1. Prerequisites and notes

1. Ensure that the following software is installed on your local machine:
    * `curl`;
    * `direnv`;
    * `foundry`;
    * `git`;
    * `go`;
    * `jq`;
    * `node`;
    * `make`;
    * `pnpm`.

   *IMPORTANT:* `direnv` should be [hooked](https://direnv.net/docs/hook.html) into your shell. E.g. for `bash` add
   line `eval "$(direnv hook bash)"` in file `~/.bashrc`.

2. This instruction was checked on:
    * `Ubuntu 22.04.4 LTS`;
    * `curl`, `direnv`, `git`, `jq`, `make` installed as `sudo apt install -y curl direnv git jq make`;
    * `foundry 0.2.0` installed as `curl -L https://foundry.paradigm.xyz | bash; foundryup -v 1.20`;
    * `go 1.21.3` installed
      as `sudo apt update; wget https://go.dev/dl/go1.21.3.linux-amd64.tar.gz; tar xvzf go1.21.3.linux-amd64.tar.gz; sudo cp go/bin/go /usr/bin/go; sudo mv go /usr/lib; echo export GOROOT=/usr/lib/go >> ~/.bashrc`;
    * `node 20.11.0` installed via [nvm](https://github.com/nvm-sh/nvm);
    * `pnpm 8.6.12` installed as `sudo npm install -g pnpm@8.6.12`;


3. Chose a name for your network configuration like:
   ```
   local-op-devnet
   ```
   This name will be used for some directory and file names.


4. Chose the chain ID for your L2 network, like:
   ```
   3007
   ```

5. Select the L1 network to use. It can be `Ethereum Mainnet`, `Polygon`, `Goerli`, or a locally
   running [Ganache](https://trufflesuite.com/ganache/) or locally
   running [Hardhat](https://hardhat.org/hardhat-network/docs/overview), or any other EVM-compatible network. You need
   to know the following parameters of the chosen L1 network:
    * the RPC URL;
    * the chain ID (network ID).

   This instruction was checked using `Ganache` as the L1 network with the RPC URL `http://localhost:8333` and the
   following `Ganache` settings:
    * IP4 address for accepted RPC connections: `0.0.0.0` (any address);
    * TCP port for connection: `8333`;
    * chain ID (network ID): `1337`;
    * automine: `false`;
    * mining block time (seconds): `2`;
    * gas limit: `15000000`;
    * autogenerate mnemonic: `false`;
    * accounts' mnemonic:
      Hardhat [test one](https://hardhat.org/hardhat-network/docs/reference#initial-state) `test test test test test test test test test test test junk`.


6. This instruction assumes that all the necessary repositories will be cloned to your home directory (`~/`). If this is
   not the case, please replace `~` with the path to the required directory.

## Step 2. Clone, fix, and build repositories

*Tip:* Subsections 2.1 and 2.2 below can be executed in parallel.

### 2.1. Optimism Monorepo

1. Clone [Optimism Monorepo](https://github.com/ethereum-optimism/optimism.git) and check out tag `v1.7.2`:
   ```bash
   cd ~
   git clone https://github.com/ethereum-optimism/optimism.git
   cd optimism
   git checkout v1.7.2
   git submodule update --init --recursive
   ```


2. Fix a bug by replacing `blockHash.String()` => `"latest"` in the file `~/optimism/op-service/sources/eth_client.go`. There should
   be 2 replacements in function `ReadStorageAt`.


3. If you are using [nvm](https://github.com/nvm-sh/nvm) replace the NodeJs version in the `./.nvmrc` file with the
   version you are currently using:
   ```bash
   echo "v20.11.0" > ./.nvmrc
   ```


4. Build Optimism Monorepo:
   ```bash
   pnpm install
   make op-node op-batcher op-proposer cannon-prestate
   pnpm build
   ```

### 2.2. Op-geth

1. Clone another Optimism repository, `op-geth`: https://github.com/ethereum-optimism/op-geth.git, and check out
   tag `v1.101308.2`:
   ```bash
   cd ~
   git clone https://github.com/ethereum-optimism/op-geth.git
   cd op-geth
   git checkout v1.101308.2
   ```


2. Build `op-geth`:
   ```bash
   make geth
   ```

## Step 3. Generate accounts and fund them

1. Chose a mnemonic and generate 4 accounts using it: `Admin`, `Batcher`, `Proposer`, `Sequencer`. This instruction uses
   the Hardhat [test mnemonic](https://hardhat.org/hardhat-network/docs/reference#initial-state):
   ```
   Mnemonic: test test test test test test test test test test test junk

   Admin:
   Address:     0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266
   Private Key: 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80

   Batcher:
   Address:     0x70997970C51812dc3A010C7d01b50e0d17dc79C8
   Private Key: 0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d

   Proposer:
   Address:     0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC
   Private Key: 0x5de4111afa1a4b94908f83103eb1f1706367c2e68ca870fc3fb9a804cdab365a

   Sequencer:
   Address:     0x90F79bf6EB2c4f870365E785982E1f101E93b906
   Private Key: 0x7c852118294e51e653712a81e05800f419141751be58f605c371e15141b007a6
   ```


2. Generate a random account for Batch Inbox:
   ```
   Batch Inbox (random):
   Address:     0xdC1b47B5bf778faA50C22a6f3E4566B3550E744C
   Private Key: a000000000000000000000000000000bc000000000000000000000000000000d
   ```


3. Fund the first three accounts (`Admin`, `Batcher`, `Proposer`) with some native tokens in your L1 network.
   Recommended funding for Goerli:
   ```
   Admin — 2 ETH
   Proposer — 5 ETH
   Batcher — 10 ETH
   ```
   *Tip:* If you use Ganache with the settings provided in p.1.5, all the accounts are already funded at the Ganache
   startup.

## Step 4. Configure the network

1. In the Optimism root directory, copy the environment file:
   ```bash
   cd ~/optimism
   cp .envrc.example .envrc
   ```

2. Fill out the environment variables in the `.envrc` file as follows:

```bash
   ##################################################
   #                 Getting Started                #
   ##################################################
   
   # Admin account
   export GS_ADMIN_ADDRESS=0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266
   export GS_ADMIN_PRIVATE_KEY=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
   
   # Batcher account
   export GS_BATCHER_ADDRESS=0x70997970C51812dc3A010C7d01b50e0d17dc79C8
   export GS_BATCHER_PRIVATE_KEY=0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d
   
   # Proposer account
   export GS_PROPOSER_ADDRESS=0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC
   export GS_PROPOSER_PRIVATE_KEY=0x5de4111afa1a4b94908f83103eb1f1706367c2e68ca870fc3fb9a804cdab365a
   
   # Sequencer account
   export GS_SEQUENCER_ADDRESS=0x90F79bf6EB2c4f870365E785982E1f101E93b906
   export GS_SEQUENCER_PRIVATE_KEY=0x7c852118294e51e653712a81e05800f419141751be58f605c371e15141b007a6
   
   ##################################################
   #              op-node Configuration             #
   ##################################################
   
   # The kind of RPC provider, used to inform optimal transactions receipts
   # fetching. Valid options: alchemy, quicknode, infura, parity, nethermind,
   # debug_geth, erigon, basic, any.
   export L1_RPC_KIND=any
   
   ##################################################
   #               Contract Deployment              #
   ##################################################
   
   # RPC URL for the L1 network to interact with
   export L1_RPC_URL=http://localhost:8333
   
   # Salt used via CREATE2 to determine implementation addresses
   # NOTE: If you want to deploy contracts from scratch you MUST reload this
   #       variable to ensure the salt is regenerated and the contracts are
   #       deployed to new addresses (otherwise deployment will fail)
   export IMPL_SALT=$(openssl rand -hex 32)
   
   # Name for the deployed network
   export DEPLOYMENT_CONTEXT=local-op-devnet
   
   # Optional Tenderly details for simulation link during deployment
   export TENDERLY_PROJECT=
   export TENDERLY_USERNAME=
   
   # Optional Etherscan API key for contract verification
   export ETHERSCAN_API_KEY=
   
   # Private key to use for contract deployments, you don't need to worry about
   # this for the Getting Started guide.
   export PRIVATE_KEY=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80

   export L2OOP_ADDRESS="" # Address of the "L2OutputOracleProxy" contract on L1 (should be set after deployment L1 contracts)

```

3. Pull the environment variables into context using `direnv`:
   ``` bash
   direnv allow .
   ```

4. In the Optimism root directory, navigate to the `packages/contracts-bedrock` directory:
   ```bash
   cd ~/optimism/packages/contracts-bedrock
   ```

5. Pick an L1 block to serve as the starting point for your L2 network. It's best to use a finalized L1 block as the
   starting block:
    ```bash
    cast block finalized --rpc-url $L1_RPC_URL | grep -E "(timestamp|hash|number)"
    ```

   The result will look like:
    ```
    hash                 0xf0f2e9f4acf9d7d8492bb049e1aef7612f16b7ce469f5ea09d613cfd00b61a33
    number               504
    timestamp            1711461698
    ```


6. Create a configuration JSON file in the `deploy-config` subdirectory like:
   ```bash
   touch deploy-config/local-op-devnet.json
   ```

   Fill the new file like:
   ```json
   {
     "finalSystemOwner": "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266",
     "superchainConfigGuardian": "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266",
    
     "l1StartingBlockTag": "0xf0f2e9f4acf9d7d8492bb049e1aef7612f16b7ce469f5ea09d613cfd00b61a33",

     "l1ChainID": 1337,
     "l2ChainID": 3007,
     "l1BlockTime": 2,
     "l2BlockTime": 1,

     "maxSequencerDrift": 600,
     "sequencerWindowSize": 3600,
     "channelTimeout": 300,

     "p2pSequencerAddress": "0x90F79bf6EB2c4f870365E785982E1f101E93b906",
     "batchInboxAddress": "0xdC1b47B5bf778faA50C22a6f3E4566B3550E744C",
     "batchSenderAddress": "0x70997970C51812dc3A010C7d01b50e0d17dc79C8",

     "l2OutputOracleSubmissionInterval": 120,
     "l2OutputOracleStartingBlockNumber": 0,
     "l2OutputOracleStartingTimestamp": 1711461698,

     "l2OutputOracleProposer": "0x70997970C51812dc3A010C7d01b50e0d17dc79C8",
     "l2OutputOracleChallenger": "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266",

     "finalizationPeriodSeconds": 12,

     "proxyAdminOwner": "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266",
     "baseFeeVaultRecipient": "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266",
     "l1FeeVaultRecipient": "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266",
     "sequencerFeeVaultRecipient": "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266",

     "baseFeeVaultMinimumWithdrawalAmount": "0x8ac7230489e80000",
     "l1FeeVaultMinimumWithdrawalAmount": "0x8ac7230489e80000",
     "sequencerFeeVaultMinimumWithdrawalAmount": "0x8ac7230489e80000",
     "baseFeeVaultWithdrawalNetwork": 0,
     "l1FeeVaultWithdrawalNetwork": 0,
     "sequencerFeeVaultWithdrawalNetwork": 0,

     "gasPriceOracleOverhead": 1,
     "gasPriceOracleScalar": 1,

     "enableGovernance": true,
     "governanceTokenSymbol": "OP",
     "governanceTokenName": "Optimism",
     "governanceTokenOwner": "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266",

     "l2GenesisBlockGasLimit": "0x3fffffff",
     "l2GenesisBlockBaseFeePerGas": "0x1",
     "l2GenesisRegolithTimeOffset": "0x0",

     "eip1559Denominator": 50,
     "eip1559Elasticity": 10,
     "EIP1559DenominatorCanyon": 50,

     "fundDevAccounts": true,
     "faultGameWithdrawalDelay": 604800,
     "systemConfigStartBlock": 0,
     "requiredProtocolVersion": "0x0000000000000000000000000000000000000000000000000000000000000000",
     "recommendedProtocolVersion": "0x0000000000000000000000000000000000000000000000000000000000000000",
     "useFaultProofs": false,
     "proofMaturityDelaySeconds": 12,
     "disputeGameFinalityDelaySeconds": 6,
     "respectedGameType": 0,
     "faultGameAbsolutePrestate": "0x0000000000000000000000000000000000000000000000000000000000000000",
     "faultGameMaxDepth": 8,
     "faultGameSplitDepth": 4,
     "faultGameMaxDuration": 1200,
     "faultGameGenesisBlock": 0,
     "faultGameGenesisOutputRoot": "0x0000000000000000000000000000000000000000000000000000000000000000",
     "preimageOracleMinProposalSize": 10000,
     "preimageOracleChallengePeriod": 120,
     "l2GenesisCanyonTimeOffset": "0x0",
     "l2GenesisDeltaTimeOffset": "0x0",
     "l2GenesisEcotoneTimeOffset": "0x0"
   }

   ```

   The default values can be found in the `packages/contracts-bedrock/deploy-config/getting-started.json` file of
   Optimism Monorepo.

   Notes about the modified fields above (from top to bottom):
    * `finalSystemOwner`, `superchainConfigGuardian`, `l2OutputOracleChallenger`, `proxyAdminOwner`, `baseFeeVaultRecipient`, `l1FeeVaultRecipient`, `sequencerFeeVaultRecipient`, `governanceTokenOwner` --
      the address of account `Admin` chosen in [section 3](#3-generate-accounts-and-fund-them);
    * `l1StartingBlockTag` -- the hash of the starting L1 block obtained in the previous step;
    * `l1ChainID` -- the chain ID of the selected L1 network;
    * `l2ChainID` -- the chain ID of the future L2 network chosen in [section 1](#1-prerequisites-and-notes);
    * `l2BlockTime` -- the block time of the future L2 network in seconds;
    * `p2pSequencerAddress` -- the address of account `Sequencer` chosen
      in [section 3](#3-generate-accounts-and-fund-them);
    * `batchInboxAddress` -- the address of account `Batch Inbox` chosen
      in [section 3](#3-generate-accounts-and-fund-them);
    * `batchSenderAddress` -- the address of account `Batcher` chosen
      in [section 3](#3-generate-accounts-and-fund-them);
    * `l2OutputOracleSubmissionInterval` -- is the number of L2 blocks between outputs that are submitted to the L2OutputOracle contract located on L1.
    * `l2OutputOracleStartingBlockNumber` -- is the starting block number for the L2OutputOracle. Must be greater than or equal to the first Bedrock block. The first L2 output will correspond to this value plus the submission interval.
    * `l2OutputOracleStartingTimestamp` -- the timestamp of the starting L1 block obtained in the previous step.
    * `l2OutputOracleProposer` -- the address of account `Proposer` chosen
      in [section 3](#3-generate-accounts-and-fund-them);
    * `gasPriceOracleOverhead`, `gasPriceOracleScalar` -- gas price related fields, they were set to the minimum
      possible value (zero is not allowed here);
    * `l2GenesisBlockGasLimit` -- the initial block gas limit, a very large but theoretically safe value is set here.
    * `fundDevAccounts` -- the "true" value of this field will cause large initial balances of native tokens for some
      accounts in the future L2 network,
      including [Hardhat test accounts](https://hardhat.org/hardhat-network/docs/reference#initial-state).
    * `faultGameWithdrawalDelay` -- is the number of seconds that users must wait before withdrawing ETH from a fault game.
    * `systemConfigStartBlock` -- represents the block at which the op-node should start syncing from. It is an override to set this value on legacy networks where it is not set by  default. It can be removed once all networks have this value set in their storage.
    * `requiredProtocolVersion`, `recommendedProtocolVersion` -- indicates the protocol version that are required and recommended for nodes to adopt, to stay in sync with the network.
    * `useFaultProofs` -- is a flag that indicates if the system is using fault proofs instead of the older output oracle mechanism.
    * `proofMaturityDelaySeconds` -- is the number of seconds that a proof must be mature before it can be used to finalize a withdrawal.
    * `disputeGameFinalityDelaySeconds` -- is an additional number of seconds a dispute game must wait before it can be used to finalize a withdrawal.
    * `respectedGameType` -- is the dispute game type that the OptimismPortal contract will respect for finalizing withdrawals.
    * `faultGameAbsolutePrestate` -- is the absolute prestate of Cannon. This is computed by generating a proof from the 0th -> 1st instruction and grabbing the prestate from the output JSON. All honest challengers should agree on the setup state of the program.
    * `faultGameMaxDepth` -- is the maximum depth of the position tree within the fault dispute game. `2^{FaultGameMaxDepth}` is how many instructions the execution trace bisection game supports. Ideally, this should be conservatively set so that there is always enough room for a full Cannon trace.
    * `faultGameSplitDepth` -- is the depth at which the fault dispute game splits from output roots to execution trace claims.
    * `faultGameMaxDuration` -- is the maximum amount of time (in seconds) that the fault dispute game can run for before it is ready to be resolved. Each side receives half of this value on their chess clock at the inception of the dispute.
    * `faultGameGenesisBlock` -- is the block number for genesis.
    * `faultGameGenesisOutputRoot` -- is the output root for the genesis block.
    * `preimageOracleMinProposalSize` is the minimum number of bytes that a large preimage oracle proposal can be.
    * `preimageOracleChallengePeriod` -- is the number of seconds that challengers have to challenge a large preimage proposal.
    * `l2GenesisCanyonTimeOffset` -- is the number of seconds after genesis block that Canyon hard fork activates. **Set it to 0 to activate at genesis**. **Nil** to disable Canyon.
    * `l2GenesisDeltaTimeOffset` -- is the number of seconds after genesis block that Delta hard fork activates. **Set it to 0 to activate at genesis**. **Nil** to disable Canyon.
    * `l2GenesisEcotoneTimeOffset` -- is the number of seconds after genesis block that Ecotone hard fork activates. **Set it to 0 to activate at genesis**. **Nil** to disable Canyon.

**NOTE** remove last 3 lines (`l2GenesisCanyonTimeOffset`, `l2GenesisDeltaTimeOffset`, `l2GenesisEcotoneTimeOffset`), to run single node locally without needed beacon node and ecoton. It should be used only if it is necessary to enable latest features (EIP-4844).

## Step 5. Deploy the Create2 Factory (Optional)

>   This step is typically only necessary if you are deploying your OP Stack chain to custom L1 chain. If you are deploying your OP Stack chain to Sepolia, you can safely skip this step.

1. Check if the factory exists
   
   The Create2 factory contract will be deployed at the address 0x4e59b44847b379578588920cA78FbF26c0B4956C. You can check if this contract has already been deployed to your L1 network with a block explorer or by running the following command:

   ```
   cast codesize 0x4e59b44847b379578588920cA78FbF26c0B4956C --rpc-url $L1_RPC_URL
   ```

   If the command returns `0` then the contract has not been deployed yet. If the command returns `69` then the contract has been deployed and you can safely skip this section.


2. Fund the factory deployer

   Send at least `1 ETH` to address `0x3fAB184622Dc19b6109349B94811493BF2a45362`

   You will need to send some ETH to the address that will be used to deploy the factory contract. 
   This address can only be used to deploy the factory contract and will not be used for anything else.


3. Deploy the factory

   ```bash
   cast publish --rpc-url $L1_RPC_URL 0xf8a58085174876e800830186a08080b853604580600e600039806000f350fe7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe03601600081602082378035828234f58015156039578182fd5b8082525050506014600cf31ba02222222222222222222222222222222222222222222222222222222222222222a02222222222222222222222222222222222222222222222222222222222222222
    ```

## Step 6. Deploy the L1 contracts

1. Navigate to the `packages/contracts-bedrock` directory within the Optimism Monorepo:
   ```bash
   cd ~/optimism/packages/contracts-bedrock
   ```


2. Create a deployment directory like:
   ```bash
   mkdir deployments/$DEPLOYMENT_CONTEXT
   ```

3. Deploy the L1 smart contracts by calling
   ```bash
   forge script scripts/Deploy.s.sol:Deploy --private-key $GS_ADMIN_PRIVATE_KEY --broadcast --rpc-url $L1_RPC_URL --slow
   ```

   Contract deployment can take up to 15 minutes. Please wait for all smart contracts to be fully deployed before
   proceeding to the next step.

   Flag `--slow` in the first command is needed to be sure that transactions are minted one by one, not in a single
   block.

   >  Issues:
   >  1. If you see a nondescript error that includes `EvmError: Revert` and `Script failed` then you likely need to change the `IMPL_SALT` environment variable. This variable determines the addresses of various smart contracts that are deployed via CREATE2. If the same IMPL_SALT is used to deploy the same contracts twice, the second deployment will fail. You can generate a new IMPL_SALT by running `direnv allow` anywhere in the Optimism Monorepo.
   >  2. If you see another error logs, check if you ran `make cannon-prestate` from step `2.4`


4. Retrieve the address of the newly deployed contracts `L2OutputOracleProxy` in the L1 network:
   ```bash
   cat deployments/local-op-devnet/.deploy | grep -E "(L2OutputOracleProxy)"
   ```

   The result will look like:
   ```
   "L2OutputOracleProxy": "0xc6e7DF5E7b4f2A278906862b61205850344D4e7d",
   ```

## Step 7. Generate L2 configuration files

1. Add `L2OutputOracleProxy` address in `~/optimism/.envrc` file:
   ```bash
   export L2OOP_ADDRESS="0xc6e7DF5E7b4f2A278906862b61205850344D4e7d"
   ```

2. Pull the environment variables into context using `direnv` (command should be run in any place in folder `~/optimism`):
   ``` bash
   direnv allow .
   ```

3. Head over to the `op-node` directory:
   ```bash
   cd ~/optimism/op-node
   ```


4. Generate the genesis and rollup configuration JSON files:
   ```bash
   go run cmd/main.go genesis l2 \
   --deploy-config ../packages/contracts-bedrock/deploy-config/$DEPLOYMENT_CONTEXT.json \
   --l1-deployments ../packages/contracts-bedrock/deployments/$DEPLOYMENT_CONTEXT/.deploy \
   --outfile.l2 genesis.json \
   --outfile.rollup rollup.json \
   --l1-rpc $L1_RPC_URL
   ```
   You should find the `genesis.json` and `rollup.json` files within the `op-node` directory.

5. Generate the `jwt.txt` file (used for communication between different apps) with the following command:
   ```bash
   openssl rand -hex 32 > jwt.txt
   ```

6. You have now prepared the L1 network and obtained all the necessary
   files (`jwt.txt`, `genesis.json`, `rollup.json`) to initialize and run your L2 network.


## Step 8. Initialize L2

1. If you skipped previous sections and obtained the configuration files (`genesis.json`, `rollup.json`, `op_env.sh`)
   from someone else:
    * put files `genesis.json`, `rollup.json` into the `~/optimism/op-node/` directory;
    * put file `op_env.sh` into your home directory.


2. Head over to the op-node package:
   ```bash
   cd ~/optimism/op-node
   ```

4. Copy files `genesis.json` and `jwt.txt` into `op-geth` so they can be used to initialize and run `op-geth` in just a
   minute:
   ```bash
   cp genesis.json ~/op-geth
   cp jwt.txt ~/op-geth
   ```


5. Head over to the `op-geth` repository directory and initialize it:
   ```bash
   cd ~/op-geth # Switch to the needed directory
   rm -rf datadir # Remove the previous data
   mkdir datadir
   ./build/bin/geth init --datadir=datadir genesis.json
   ```

## Step 9. Run and manage the L2 node software

1. Run `op-geth` from the appropriate directory:
   ```bash
   cd ~/op-geth  # Switch to the needed directory
   ./build/bin/geth \
      --datadir=./datadir \
      --http \
      --http.corsdomain="*" \
      --http.vhosts="*" \
      --http.addr=0.0.0.0 \
      --http.port=8545 \
      --http.api=web3,debug,eth,txpool,net,engine \
      --ws \
      --ws.addr=0.0.0.0 \
      --ws.port=8546 \
      --ws.origins="*" \
      --ws.api=debug,eth,txpool,net,engine \
      --syncmode=full \
      --gcmode=archive \
      --nodiscover \
      --maxpeers=0 \
      --networkid=3007 \
      --authrpc.vhosts="*" \
      --authrpc.addr=0.0.0.0 \
      --authrpc.port=8551 \
      --authrpc.jwtsecret=./jwt.txt \
      --rollup.disabletxpoolgossip=true
    ```

   If you got an error stop the app and try to execute steps of section [7](#7-initialize-l2) again. Then run `op-geth`
   again.

   `networkid` - should be your L2 network ID, `3007` in this case (as it is chosen in `~/optimism/packages/contracts-bedrock/deploy-config/local-op-devnet.json`).


2. Open another terminal and run `op-node` from the appropriate directory:
   ```bash
   cd ~/optimism/op-node # Switch to the needed directory
   ./bin/op-node \
      --l2=http://localhost:8551 \
      --l2.jwt-secret=./jwt.txt \
      --sequencer.enabled \
      --sequencer.l1-confs=3 \
      --verifier.l1-confs=3 \
      --rollup.config=./rollup.json \
      --rpc.addr=0.0.0.0 \
      --rpc.port=8547 \
      --rpc.enable-admin \
      --p2p.disable \
      --p2p.sequencer.key=$GS_SEQUENCER_PRIVATE_KEY \
      --l1=$L1_RPC_URL \
      --l1.rpckind=$L1_RPC_KIND \
      --l1.beacon=$L1_RPC_BEACON_NODE
    ```


3. Open another terminal and run `op-batcher` from the appropriate directory, like:
   ```bash
   cd ~/optimism/op-batcher # Switch to the needed directory
   ./bin/op-batcher \
      --l2-eth-rpc=http://localhost:8545 \
      --rollup-rpc=http://localhost:8547 \
      --poll-interval=1s \
      --sub-safety-margin=6 \
      --num-confirmations=1 \
      --safe-abort-nonce-too-low-count=3 \
      --resubmission-timeout=30s \
      --rpc.addr=0.0.0.0 \
      --rpc.port=8548 \
      --rpc.enable-admin \
      --l1-eth-rpc=$L1_RPC_URL \
      --private-key=$GS_BATCHER_PRIVATE_KEY \
      --max-channel-duration=15
   ```
   *Tip:* The `--max-channel-duration=n` setting tells the batcher to write all the data to L1 every `n` L1 blocks. When
   it is low, transactions are written to L1 frequently, withdrawals are quick, and other nodes can synchronize from L1
   fast. When it is high, transactions are written to L1 less frequently, and the batcher spends less ETH.


4. Open another terminal and run `op-proposer` from the appropriate directory, like:
   ```bash
   cd ~/optimism/op-proposer # Switch to the needed directory
   ./bin/op-proposer \
      --poll-interval=12s \
      --rpc.port=8560 \
      --rollup-rpc=http://localhost:8547 \
      --l2oo-address=$L2OOP_ADDRESS \
      --private-key=$GS_PROPOSER_PRIVATE_KEY \
      --l1-eth-rpc=$L1_RPC_URL
   ```

5. To stop the network just terminate the applications run previously.


6. To reinitialize the network stop it and repeat steps of section [7](#7-initialize-l2) again.

## Step 9. Use the newly created L2 network

1. The URL to access RPC API endpoint of the network is: `http://localhost:8545`.


2. You can verify that blocks are being produced with the following script:
   ```bash
   RPC_URL="http://localhost:8545"
   REQUEST_DATA='{"method":"eth_blockNumber","params":[],"id":1,"jsonrpc":"2.0"}'
   curl -H "Content-Type: application/json" -d "$REQUEST_DATA" "$RPC_URL" | jq
   ```


3. If you previously set `"fundDevAccounts": true` in the section [4](#4-configure-the-network) you will
   have [Hardhat test accounts](https://hardhat.org/hardhat-network/docs/reference#initial-state) with a generous amount
   of native tokens (ETH) in the newly created L2 network to use.

   Otherwise, to obtain some ETH in an L2 account, you will need to transfer the desired amount of ETH from that account
   to the `L1StandardBridgeProxy` contract within the L1 network and wait for the amount to appear in the L2 network.
   You can find the contract's address in the `op_env.sh` file.
