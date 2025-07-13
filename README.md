# Ubuntu 20.04 Dev Setup Script

This script automates the installation and configuration of essential developer tools and environment on Ubuntu 20.04.

---

## What this script installs:

- System updates and essentials (wget, curl, git, build tools, etc.)
- Visual Studio Code
- Slack (via snap)
- Flameshot (screenshot tool)
- Python3, pip, venv, and Git
- Cursor AI App (AppImage)
- OpenJDK 17
- Node.js (v22 LTS)
- Postman (via snap)
- Google Chrome
- Microsoft Teams
- MySQL Workbench
- LAMP stack (Apache, MySQL, PHP)
- MySQL user `admin` with password `admin12345`
- MongoDB Compass
- FileZilla
- Upwork Desktop App
- Zsh with Oh My Zsh and plugins (autosuggestions & syntax highlighting)
- System performance optimizations (swappiness, preload, disable animations)
- SSH RSA key generation (if not present)

---

## MySQL Credentials

- **Username:** `user`
- **Password:** `password`

---

## How to use

1. Download or copy the script to your Ubuntu 20.04 system.
2. Make the script executable:
   ```bash
   chmod +x setup.sh
Run the script:

bash
Copy
Edit
./setup.sh
The script will prompt for a reboot once finished. You can reboot immediately or later.
