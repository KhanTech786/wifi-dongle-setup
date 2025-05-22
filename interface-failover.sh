#!/bin/bash
set -e

echo "🔍 Detecting interfaces..."
ip link show | awk -F': ' '/^[0-9]+: / {print $2}' | grep -Ev '^lo|docker|br' | nl

read -p "🖧 Enter your Ethernet interface name (e.g., enp3s0): " ETH_IF
read -p "📡 Enter your Wi-Fi interface name (e.g., wlx306893f7c272): " WIFI_IF

echo "✅ Using Ethernet: $ETH_IF"
echo "✅ Using Wi-Fi:    $WIFI_IF"

### === WIFI FAILOVER SCRIPT === ###
echo "📄 Creating /usr/local/bin/wifi-toggle.sh"
sudo tee /usr/local/bin/wifi-toggle.sh > /dev/null <<EOF
#!/bin/bash

ETH_STATE=\$(cat /sys/class/net/$ETH_IF/operstate)

if [[ "\$ETH_STATE" == "up" ]]; then
    logger -t wifi-toggle "[+] Ethernet ($ETH_IF) is UP — Disabling Wi-Fi ($WIFI_IF)"
    ip link set $WIFI_IF down
else
    logger -t wifi-toggle "[!] Ethernet ($ETH_IF) is DOWN — Enabling Wi-Fi ($WIFI_IF)"
    ip link set $WIFI_IF up
    systemctl restart wpa_supplicant-wifi.service
    systemctl restart dhclient-wifi.service
fi
EOF

sudo chmod +x /usr/local/bin/wifi-toggle.sh

### === SYSTEMD SERVICE === ###
echo "📄 Creating /etc/systemd/system/wifi-toggle.service"
sudo tee /etc/systemd/system/wifi-toggle.service > /dev/null <<EOF
[Unit]
Description=Disable Wi-Fi when Ethernet is up

[Service]
Type=oneshot
ExecStart=/usr/local/bin/wifi-toggle.sh
EOF

### === SYSTEMD TIMER === ###
echo "📄 Creating /etc/systemd/system/wifi-toggle.timer"
sudo tee /etc/systemd/system/wifi-toggle.timer > /dev/null <<EOF
[Unit]
Description=Run Wi-Fi toggle every 30 seconds

[Timer]
OnBootSec=30
OnUnitActiveSec=30s
Unit=wifi-toggle.service

[Install]
WantedBy=timers.target
EOF

### === ENABLE SERVICES === ###
echo "🔗 Enabling toggle timer..."
sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable --now wifi-toggle.timer

echo "✅ Done: Wi-Fi will now be toggled based on Ethernet status."
