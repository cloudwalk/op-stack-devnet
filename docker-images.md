# Creating Docker images of the OP-stack node apps

This instruction is actual for the following versions of OP-Stack repositories:
* [optimism](https://github.com/ethereum-optimism/optimism), tag: `v1.7.2`;
* [op-geth](https://github.com/ethereum-optimism/op-geth), tag: `v1.101308.2`.

## 1. Prerequisites and Notes

1.  Ensure the following software is installed:
    * `docker`


2.  This instruction was checked on:
    * `Ubuntu 22.04.4 LTS`;
    * `docker version 25.0.4, build 1a576c5` installed according to the [official instructions](https://docs.docker.com/desktop/install/ubuntu/)


3.  Choose a path, name, and tag for the future images, like:
    * <some_image_path>/optimism:v1.7.2;
    * <some_image_path>/op-geth:v1.101308.2.


4. The instruction assumes that all the necessary repositories will be cloned to your home directory (`~/`). If this is not the case, please replace `~` with the path to the required directory.



## 2. Clone, fix, and build repositories

Follow the appropriate section of the instruction [here](./single-node-no-docker.md).


## 3. Create images

1.  Head over to the root directory of this repository, like:
    ```bash
    cd ~/op-stack-devnet
    ```

2.  Copy Docker files from the [dockerfiles](./dockerfiles) directory of this repository to the appropriate directories of `optimism` and `op-geth` repositories, like:
    ```bash
    cp ./dockerfiles/optimism/Dockerfile.with_utils ~/optimism/
    cp ./dockerfiles/op-geth/Dockerfile.with_utils ~/op-geth/
    ```


3. Switch to the Optimism Monorepo directory:
    ```bash
    cd ~/optimism/
    ```


4.  Build the image for apps `op-node`, `op-batcher`, `op-proposer`, like:
    ```bash
    sudo docker build --network=host -f Dockerfile.with_utils -t <some_image_path>/optimism:v1.7.2 .
    ```


5.  If needed, push the built images to a remote repository, like:
    ```bash
    sudo docker image push <some_image_path>/optimism:v1.7.2
    ```


6.  Switch to the `op-geth` repository:
    ```bash
    cd ~/op-geth/
    ```


7.  Build the image of the `op-geth` app, like:
    ```bash
    sudo docker build --network=host -f Dockerfile.with_utils -t <some_image_path>/op-geth:v1.101308.2 .
    ```


8.  If needed, push the built image to a remote repository like:
    ```bash
    sudo docker image push <some_image_path>/op-geth:v1.101308.2
    ```
