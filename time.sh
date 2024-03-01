#!/bin/bash
GENESIS=$(($(date +%s) + 30)) # 120s until genesis, feel free to increase this to give you more time to everything

# The following are configureable too but you have to make sure they align.
# Take SECONDS_PER_SLOT * SLOTS_PER_EPOCH * CAPELLA_FORK_EPOCH for SHANGHAI
# Take SECONDS_PER_SLOT * SLOTS_PER_EPOCH * EIP4844_FORK_EPOCH for CANCUN
SHANGHAI=$(($GENESIS + 108))
CANCUN=$(($GENESIS + 144))
sed -i -e 's/XXX/'$SHANGHAI'/' ./genesis.json
sed -i  -e 's/YYY/'$CANCUN'/' ./genesis.json