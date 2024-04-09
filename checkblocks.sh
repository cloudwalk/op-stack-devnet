#!/bin/bash
REQUEST_DATA='{"method":"eth_blockNumber","params":[],"id":1,"jsonrpc":"2.0"}'
RPC_URL="http://192.168.10.11:8545"
echo "RPC URL: $RPC_URL"
curl -H "Content-Type: application/json" -d "$REQUEST_DATA" "$RPC_URL" | jq

RPC_URL="http://192.168.10.21:8545"
echo "RPC URL: $RPC_URL"
curl -H "Content-Type: application/json" -d "$REQUEST_DATA" "$RPC_URL" | jq

RPC_URL="http://192.168.10.31:8545"
echo "RPC URL: $RPC_URL"
curl -H "Content-Type: application/json" -d "$REQUEST_DATA" "$RPC_URL" | jq
