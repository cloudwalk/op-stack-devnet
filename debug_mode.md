# Running Environment with Debug Mode

This option was added to allow manage docker containers logs with web interface.

For this purpose there was added new docker container [Dozzle](https://dozzle.dev/) that output logs from all containers in real time.

## 1. Prerequisites

This instruction is an addiction and should be followed after [Running a single-node network without Docker](./single-node-no-docker.md) instruction.

## 2. Running Environment with Debug Mode

To run the environment with debug mode, it is necessary to add `--debug` flag to [up.sh](./docker/up.sh) command:

    ```bash
    sudo ./up.sh --debug
    ```

## 3. Stop Environment with Debug Mode

Stopping debug mode is implemented with the same command as stopping the environment without debug mode:

    ```bash
    sudo ./down.sh
    ```