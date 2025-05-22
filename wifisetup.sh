#!/bin/bash
set -e

# 🧠 Detect Wi-Fi interface
WLAN_IFACE=$(ip link | awk -F: '$2 ~ /wl/ {gsub(" ", "", $2); print $2}' | head -n1)

if [[ -z "$WLAN_IFACE" ]]; then
  echo "❌ No Wi-Fi interface detected. Make sure the dongle is plugged in."
  exit 1
fi
echo "✅ Detected Wi-Fi interface: $WLAN_IFACE"

# 🔐 Ask user for Wi-Fi info
read -p "📶 Enter Wi-Fi SSID: " SSID
read -sp "🔑 Enter Wi-Fi PASSWORD: " PASSWORD
echo
read -p "🌍 Enter your 2-letter COUNTRY code (e.g., US, IN): " COUNTRY

# 🔧 Install necessary packages
echo "🔧 Installing required packages..."
sudo apt update && sudo apt install -y git build-essential dkms iw wpasupplicant isc-dhcp-client net-tools

# 📥 Clone and install driver
DRIVER_REPO="https://github.com/morrownr/8821au-20210708.git"
DRIVER_DIR="$HOME/src/8821au-20210708"
echo "📦 Installing Realtek 8821AU driver..."
mkdir -p "$HOME/src"
git clone "$DRIVER_REPO" "$DRIVER_DIR"
cd "$DRIVER_DIR"
sudo ./install-driver.sh

# 📝 Create WPA config
echo "📝 Creating /etc/wpa_supplicant.conf..."
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

# ⚙️ Create wpa_supplicant service
echo "⚙️ Setting up wpa_supplicant service..."
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

# ⚙️ Create DHCP service
echo "⚙️ Setting up dhclient service..."
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

# 🔗 Enable and start services
echo "🔗 Enabling and starting services..."
sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable wpa_supplicant-wifi.service dhclient-wifi.service
sudo systemctl start wpa_supplicant-wifi.service dhclient-wifi.service

# 🧹 Clean up
echo "🧹 Cleaning up driver source..."
rm -rf "$DRIVER_DIR"

# 🔍 Wait a few seconds and show connection info
echo "⏳ Waiting for IP address on $WLAN_IFACE..."
sleep 10

IP_ADDR=$(ip -4 addr show "$WLAN_IFACE" | grep -oP '(?<=inet\s)\d+(\.\d+){3}' || true)
PING_TEST=$(ping -I "$WLAN_IFACE" -c 2 1.1.1.1 > /dev/null && echo "✅ Internet Reachable via $WLAN_IFACE" || echo "❌ No Internet via $WLAN_IFACE")

echo "🔎 Summary:"
echo "───────────────"
echo "Wi-Fi Interface : $WLAN_IFACE"
echo "IP Address      : ${IP_ADDR:-Not Assigned}"
echo "Ping Test       : $PING_TEST"
echo "Default Route   : $(ip route | grep default | grep "$WLAN_IFACE" || echo '⚠️ Not the default route')"
echo "───────────────"

echo "✅ Wi-Fi setup complete. You may reboot if required."
