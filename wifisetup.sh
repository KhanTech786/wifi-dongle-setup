#!/bin/bash

# Exit on error
set -e

# Constants
DRIVER_REPO="https://github.com/morrownr/8821au-20210708.git"
DRIVER_DIR="$HOME/src/8821au-20210708"
WLAN_IFACE="wlx306893f7c272"  # Replace with your actual interface if needed
SSID="F1-A 4G"                # Replace with your SSID
PASSWORD="1020355"            # Replace with your Wi-Fi password
COUNTRY="US"

echo "🔧 Updating system..."
sudo apt update && sudo apt install -y git build-essential dkms iw wpasupplicant isc-dhcp-client

echo "📥 Cloning Realtek RTL8821AU driver..."
mkdir -p "$HOME/src"
git clone "$DRIVER_REPO" "$DRIVER_DIR"
cd "$DRIVER_DIR"
sudo ./install-driver.sh

echo "📄 Creating wpa_supplicant.conf..."
sudo tee /etc/wpa_supplicant.conf > /dev/null <<EOF
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1
country=$COUNTRY

network={
    ssid="$SSID"
    psk="$PASSWORD"
    key_mgmt=WPA-PSK
}
EOF

echo "⚙️ Creating wpa_supplicant systemd service..."
sudo tee /etc/systemd/system/wpa_supplicant-wifi.service > /dev/null <<EOF
[Unit]
Description=Connect to Wi-Fi using wpa_supplicant
After=network.target

[Service]
ExecStart=/sbin/wpa_supplicant -i $WLAN_IFACE -c /etc/wpa_supplicant.conf
Restart=always

[Install]
WantedBy=multi-user.target
EOF

echo "⚙️ Creating dhclient systemd service..."
sudo tee /etc/systemd/system/dhclient-wifi.service > /dev/null <<EOF
[Unit]
Description=DHCP Client for Wi-Fi
After=wpa_supplicant-wifi.service
Wants=wpa_supplicant-wifi.service

[Service]
ExecStart=/sbin/dhclient $WLAN_IFACE
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

echo "🔗 Enabling and starting services..."
sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable wpa_supplicant-wifi.service dhclient-wifi.service
sudo systemctl start wpa_supplicant-wifi.service dhclient-wifi.service

echo "✅ Wi-Fi setup complete. You should be online after a reboot or a few seconds!"
