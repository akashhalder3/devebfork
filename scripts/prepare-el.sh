#!/usr/bin/env bash

source ./scripts/util.sh
set -eu

mkdir -p $EXECUTION_DIR

new_account() {
    local node=$1
    local datadir=$2

    # Generate a new account for each geth node
    address=$($GETH_CMD --datadir $datadir account new --password $ROOT/password 2>/dev/null | grep -o "0x[0-9a-fA-F]*")
    echo "Generated an account with address $address for geth node $node and saved it at $datadir"
    echo $address > $datadir/address

    # Add the account into the genesis state
    alloc=$(echo $genesis | jq ".alloc + { \"${address:2}\": { \"balance\": \"$INITIAL_BALANCE\" } }")
    genesis=$(echo $genesis | jq ". + { \"alloc\": $alloc }")
}