# ZimaBoard Wi-Fi Setup Script (RTL8821AU Dongle)

.

📶 TP-Link Nano 2-in-1 Wi-Fi Dongle Setup & Optional Failover Control
This project helps you set up Realtek RTL8821AU driver For Your TP-Link Nano 2-in-1 Wi-Fi Dongle and configures Wi-Fi on a minimal Ubuntu Server without Netplan
Optionally configure automatic Wi-Fi failover based on Ethernet availability.

🚀 Step 1: Install Wi-Fi Driver & Setup Wi-Fi
Use the following command to install the Realtek 8821AU Wi-Fi driver and configure Wi-Fi on your ZimaBoard:

bash
Copy
Edit
bash <(curl -s https://raw.githubusercontent.com/KhanTech786/wifi-dongle-setup/master/wifisetup.sh)
🛠️ What This Script Does:
Installs necessary packages and the 8821AU driver

Prompts you to enter your Wi-Fi SSID, Password, and Country Code

Creates and enables systemd services for Wi-Fi connection

Sets up /etc/wpa_supplicant.conf

📋 Prompt Instructions:
Enter SSID and Password normally — do not use quotes, even if your SSID has spaces (the script handles quoting).

When prompted:

pgsql
Copy
Edit
Do you want to edit the driver options file now? (recommended) [Y/n]
→ Recommended answer: n

When prompted:

pgsql
Copy
Edit
Do you want to apply the new options by rebooting now? (recommended) [Y/n]
→ Recommended answer: n

✅ Check Wi-Fi Status
After running the script, verify that Wi-Fi is running with:

bash
Copy
Edit
systemctl status wpa_supplicant-wifi.service
🗂️ Wi-Fi Config File Location
You can manually inspect or edit your Wi-Fi configuration here:

bash
Copy
Edit
/etc/wpa_supplicant.conf


⚙️ (Optional) Step 2: Interface Failover Script
This is an optional utility that:

Disables Wi-Fi when Ethernet is active

Re-enables Wi-Fi if Ethernet goes down

Useful for avoiding conflicts or testing failover logic.

✅ Run with One-Liner:
bash
Copy
Edit
bash <(curl -s https://raw.githubusercontent.com/KhanTech786/wifi-dongle-setup/master/wifi_toggle_setup.sh)
✅ Or Clone the Repo:
bash
Copy
Edit
git clone https://github.com/KhanTech786/wifi-dongle-setup.git
cd wifi-dongle-setup
bash wifi_toggle_setup.sh
📋 What This Script Does:
Prompts you to select:

Ethernet interface (e.g., enp3s0)

Wi-Fi interface (e.g., wlx306893f7c272)

Installs:

/usr/local/bin/wifi-toggle.sh — the toggle logic

wifi-toggle.service — one-shot toggle

wifi-toggle.timer — runs every 30 seconds

🔧 Managing the Toggle System:
Enable and start:

bash
Copy
Edit
sudo systemctl enable --now wifi-toggle.timer
Manually trigger toggle:

bash
Copy
Edit
sudo systemctl start wifi-toggle.service
Check status:

bash
Copy
Edit
sudo systemctl status wifi-toggle.timer
sudo systemctl status wifi-toggle.service
Disable if no longer needed:

bash
Copy
Edit
sudo systemctl disable --now wifi-toggle.timer
📝 Notes:
This script does not touch your Wi-Fi setup — it's a separate utility.

Wi-Fi setup must be completed first for toggling to work properly.

This is optional and safe to skip unless you need dynamic interface control.


---
