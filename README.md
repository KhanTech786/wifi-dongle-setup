# TP-Link Nano 2-in-1 Wi-Fi Dongle Wi-Fi Setup Script For Ubuntu Server (RTL8821AU Dongle)

> 📶 **Complete setup solution for TP-Link Nano 2-in-1 Wi-Fi Dongle with optional Ethernet failover control**

This project provides automated setup for the Realtek RTL8821AU driver on your TP-Link Nano 2-in-1 Wi-Fi Dongle and configures Wi-Fi connectivity on minimal Ubuntu Server installations without Netplan. Includes optional automatic Wi-Fi failover functionality based on Ethernet availability.

## 🚀 Quick Start

### Step 1: Install Wi-Fi Driver & Configure Connection

Run the following one-liner to install the Realtek 8821AU Wi-Fi driver and set up your Wi-Fi connection:

```bash
bash <(curl -s https://raw.githubusercontent.com/KhanTech786/wifi-dongle-setup/master/wifisetup.sh)
```

#### What This Script Does

- ✅ Installs necessary packages and the RTL8821AU driver
- ✅ Prompts for Wi-Fi credentials (SSID, Password, Country Code)
- ✅ Creates and enables systemd services for Wi-Fi connection management
- ✅ Configures `/etc/wpa_supplicant.conf` with your settings

#### Important Setup Instructions

When running the script, follow these prompts carefully:

**For SSID and Password:**
- Enter your credentials normally without quotes
- The script automatically handles special characters and spaces

**When prompted about driver options:**
```
Do you want to edit the driver options file now? (recommended) [Y/n]
```
**Recommended answer:** `n`

**When prompted about rebooting:**
```
Do you want to apply the new options by rebooting now? (recommended) [Y/n]
```
**Recommended answer:** `n`

### Step 2: Verify Wi-Fi Connection

After running the setup script, check that your Wi-Fi service is active:

```bash
systemctl status wpa_supplicant-wifi.service
```

#### Wi-Fi Configuration File

You can manually inspect or modify your Wi-Fi settings at:

```bash
/etc/wpa_supplicant.conf
```

## ⚙️ Optional: Interface Failover Setup

This optional utility provides intelligent network interface management:

- 🔄 Automatically disables Wi-Fi when Ethernet is connected
- 🔄 Re-enables Wi-Fi if Ethernet connection is lost
- 🔄 Prevents interface conflicts and enables seamless failover

### Quick Installation

Choose one of the following methods:

#### Method 1: One-Liner Installation
```bash
bash <(curl -s https://raw.githubusercontent.com/KhanTech786/wifi-dongle-setup/master/wifi_toggle_setup.sh)
```

#### Method 2: Clone Repository
```bash
git clone https://github.com/KhanTech786/wifi-dongle-setup.git
cd wifi-dongle-setup
bash wifi_toggle_setup.sh
```

### Configuration Process

During setup, you'll be prompted to select:

1. **Ethernet interface** (e.g., `enp3s0`)
2. **Wi-Fi interface** (e.g., `wlx306893f7c272`)

### What Gets Installed

| Component | Description |
|-----------|-------------|
| `/usr/local/bin/wifi-toggle.sh` | Core toggle logic script |
| `wifi-toggle.service` | Systemd service for one-shot execution |
| `wifi-toggle.timer` | Systemd timer (runs every 30 seconds) |

## 🔧 Managing the Failover System

### Enable and Start the Service
```bash
sudo systemctl enable --now wifi-toggle.timer
```

### Manual Toggle Execution
```bash
sudo systemctl start wifi-toggle.service
```

### Check System Status
```bash
# Check timer status
sudo systemctl status wifi-toggle.timer

# Check service status
sudo systemctl status wifi-toggle.service
```

### Disable Failover (if needed)
```bash
sudo systemctl disable --now wifi-toggle.timer
```

## 📋 Important Notes

> ⚠️ **Prerequisites:** The Wi-Fi setup (Step 1) must be completed successfully before configuring the failover system.

> ℹ️ **Independence:** The failover script is completely separate from Wi-Fi setup and can be safely skipped if not needed.

> 🔒 **Safety:** The failover system only manages interface states and doesn't modify your Wi-Fi configuration.

## 🛠️ Troubleshooting

### Common Issues

**Wi-Fi service not starting:**
```bash
# Check service logs
journalctl -u wpa_supplicant-wifi.service -n 20

# Restart the service
sudo systemctl restart wpa_supplicant-wifi.service
```

**Interface names not recognized:**
```bash
# List all network interfaces
ip link show
```

**Driver issues:**
```bash
# Check if driver is loaded
lsmod | grep 8821au

# Check USB device recognition
lsusb | grep Realtek
```

## 📞 Support

For issues and contributions, please visit the [GitHub repository](https://github.com/KhanTech786/wifi-dongle-setup).

---

**Made with ❤️ for Linux users**
