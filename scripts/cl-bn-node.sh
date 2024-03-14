#!/usr/bin/env bash

source ./scripts/util.sh
set -u +e

cleanup() {
    kill $(jobs -p) 2>/dev/null
}

trap cleanup EXIT

index=$1

cl_data_dir $index
datadir=$cl_data_dir
base_port=$((BASE_CL_PORT + index))
base_http_port=$((BASE_CL_HTTP_PORT + index))

# Function to find an available port
find_available_port() {
    local port=$1
    while lsof -Pi :$port -sTCP:LISTEN -t >/dev/null; do
        port=$((port + 1))
    done
    echo "$port"
}

port=$(find_available_port $base_port)
http_port=$(find_available_port $base_http_port)
log_file=$datadir/beacon_node.log

echo "Started the lighthouse beacon node #$index which is now listening at port $port and http at port $http_port. You can see the log at $log_file"

# --disable-packet-filter is necessary because it's involved in rate limiting and nodes per IP limit
# See https://github.com/sigp/discv5/blob/v0.1.0/src/socket/filter/mod.rs#L149-L186
$LIGHTHOUSE_CMD beacon_node \
    --datadir $datadir \
    --testnet-dir $CONSENSUS_DIR \
    --execution-endpoint http://localhost:$(expr $BASE_EL_RPC_PORT + $index) \
    --execution-jwt $datadir/jwtsecret \
    --enable-private-discovery \
    --staking \
    --enr-address 127.0.0.1 \
    --enr-udp-port $port \
    --enr-tcp-port $port \
    --port $port \
    --http \
    --http-port $http_port \
    --disable-packet-filter \
    < /dev/null > $log_file 2>&1

if test $? -ne 0; then
    node_error "The lighthouse beacon node #$index returns an error. The last 10 lines of the log file is shown below.\n\n$(tail -n 10 $log_file)"
    exit 1
fi
