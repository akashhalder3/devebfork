#!/usr/bin/env bash

source ./scripts/util.sh
set -eu

mkdir -p $CONSENSUS_DIR

if ! test -e ./web3/node_modules; then
    echo "The package ./web3 doesn't have node modules installed yet. Installing the node modules now"
    npm --prefix ./web3 install >/dev/null 2>/dev/null
    echo "Node modules are already installed"
fi

# Use the signing node as a node to deploy the deposit contract
output=$(NODE_PATH=./web3/node_modules node ./web3/src/deploy-deposit-contract.js --endpoint $SIGNER_EL_DATADIR/geth.ipc)
address=$(echo "$output" | grep "address" | cut -d ' ' -f 2)
transaction=$(echo "$output" | grep "transaction" | cut -d ' ' -f 2)
block_number=$(echo "$output" | grep "block_number" | cut -d ' ' -f 2)

echo "Deployed the deposit contract of the address $address in the transaction $transaction on the block number $block_number"

echo $address > $ROOT/deposit-address
echo $block_number > $CONSENSUS_DIR/deploy_block.txt
