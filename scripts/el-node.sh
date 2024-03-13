#!/usr/bin/env bash

source ./scripts/util.sh
set -u +e

cleanup() {
    kill $(jobs -p) 2>/dev/null
}

trap cleanup EXIT

index=$1
boot_enode=$2

el_data_dir $index
datadir=$el_data_dir
address=$(cat $datadir/address)
port=$(expr $BASE_EL_PORT + $index)
rpc_port=$(expr $BASE_EL_RPC_PORT + $index)
http_port=$(expr $BASE_HTTP_PORT + $index)
log_file=$datadir/geth.log

echo "Started the geth node #$index which is now listening at port $port and rpc at port $rpc_port with HTTP server at port $http_port. You can see the log at $log_file"
$GETH_CMD \
    --datadir $datadir \
    --authrpc.addr="0.0.0.0" \
    --authrpc.port $rpc_port \
    --port $port \
    --http \
    --http.addr="0.0.0.0" \
    --http.port $http_port \
    --http.corsdomain "*" \
    --syncmode "full" \
    --bootnodes $boot_enode \
    --networkid $NETWORK_ID \
    --allow-insecure-unlock \
    --unlock $address \
    --password $ROOT/password \
    --nat=extip:20.40.53.142 \
    < /dev/null > $log_file 2>&1

if test $? -ne 0; then
    node_error "The geth node #$index returns an error. The last 10 lines of the log file is shown below.\n\n$(tail -n 10 $log_file)"
    exit 1
fi