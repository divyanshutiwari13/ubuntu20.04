#!/bin/bash
set -e

PASSWORD="ntf12345"
run_sudo(){ echo "$PASSWORD" | sudo -S "$@"; }

echo "🔄 Updating system..."
run_sudo apt update && run_sudo apt upgrade -y

echo "🧰 Installing essentials..."
run_sudo apt install -y wget curl gnupg lsb-release apt-transport-https software-properties-common ca-certificates build-essential libfuse2 zsh preload

echo "💻 Installing VS Code..."
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
run_sudo install -o root -g root -m 644 microsoft.gpg /usr/share/keyrings/
run_sudo sh -c 'echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'
rm microsoft.gpg
run_sudo apt update
run_sudo apt install -y code

echo "💬 Installing Slack..."
run_sudo snap install slack --classic

echo "📸 Installing Flameshot..."
run_sudo apt install -y flameshot

echo "🐍 Installing Python3, venv, pip, and Git..."
run_sudo apt install -y python3 python3-venv python3-pip git

echo "🧠 Installing Cursor AI v1.2..."
CUR_VER="Cursor-1.2.0-x86_64.AppImage"
wget -O ~/"$CUR_VER" https://cursor.sh/downloads/$CUR_VER
mkdir -p ~/Applications
mv ~/"$CUR_VER" ~/Applications/cursor.AppImage
chmod +x ~/Applications/cursor.AppImage
wget -O ~/Applications/cursor.png https://cursor.sh/icon.png
cat > ~/.local/share/applications/cursor.desktop <<EOF
[Desktop Entry]
Name=Cursor AI
Exec=$HOME/Applications/cursor.AppImage --no-sandbox
Icon=$HOME/Applications/cursor.png
Type=Application
Categories=Development;
EOF
update-desktop-database ~/.local/share/applications

echo "☕ Installing Java 17..."
run_sudo apt install -y openjdk-17-jdk
echo "export JAVA_HOME=$(dirname $(dirname $(readlink -f $(which javac))))" >> ~/.bashrc
echo 'export PATH="$JAVA_HOME/bin:$PATH"' >> ~/.bashrc

echo "🟢 Installing Node.js (v22 LTS)..."
curl -fsSL https://deb.nodesource.com/setup_22.x | run_sudo bash -
run_sudo apt install -y nodejs

echo "📦 Installing Postman..."
run_sudo snap install postman

echo "🌐 Installing Google Chrome..."
wget -O ~/chrome.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
run_sudo apt install -y ~/chrome.deb
rm ~/chrome.deb

echo "📞 Installing Microsoft Teams..."
wget -O ~/teams.deb https://packages.microsoft.com/repos/ms-teams/pool/main/t/teams/teams_1.6.00.26474_amd64.deb
run_sudo apt install -y ~/teams.deb
rm ~/teams.deb

echo "🧮 Installing MySQL Workbench..."
run_sudo apt install -y mysql-workbench

echo "🧱 Installing LAMP stack..."
run_sudo apt install -y apache2 mysql-server php libapache2-mod-php php-mysql
run_sudo systemctl enable apache2 mysql
run_sudo systemctl start apache2 mysql

echo "🔐 Configuring MySQL root/admin..."
run_sudo mysql <<EOF
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '${PASSWORD}';
CREATE USER IF NOT EXISTS 'admin'@'localhost' IDENTIFIED BY '${PASSWORD}';
GRANT ALL PRIVILEGES ON *.* TO 'admin'@'localhost' WITH GRANT OPTION;
FLUSH PRIVILEGES;
EOF

echo "⚙️ Setting up MySQL Workbench connection profile..."
mkdir -p ~/.mysql/workbench
cat > ~/.mysql/workbench/connections.xml <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<connections>
  <connection>
    <name>Local Admin</name>
    <host>127.0.0.1</host>
    <port>3306</port>
    <username>admin</username>
    <password></password>
    <defaultSchema></defaultSchema>
    <useSSL>0</useSSL>
    <connectionMethod>Standard (TCP/IP)</connectionMethod>
  </connection>
</connections>
EOF

echo "🍃 Installing MongoDB Compass..."
wget -O mongodb-compass.deb https://downloads.mongodb.com/compass/mongodb-compass_1.46.5_amd64.deb
run_sudo apt install -y ./mongodb-compass.deb
rm mongodb-compass.deb

echo "📂 Installing FileZilla..."
run_sudo add-apt-repository universe -y
run_sudo apt update
run_sudo apt install -y filezilla

echo "🛠 Installing Upwork Desktop App..."
if ! wget -O ~/upwork.deb https://www.upwork.com/ab/downloads/latest/upwork_amd64.deb; then
  wget -O ~/upwork.deb https://turbo.getupwork.com/desktop/upwork_5.8.0.33_amd64.deb
fi
run_sudo dpkg -i ~/upwork.deb || run_sudo apt-get install -f -y
rm ~/upwork.deb

echo "🌀 Setting up Zsh and Oh My Zsh..."
run_sudo apt install -y zsh
export RUNZSH=no
export CHSH=no
sh -c "$(wget -qO- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

sed -i 's/^plugins=(git)$/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/' ~/.zshrc
sed -i 's/ZSH_THEME=".*"/ZSH_THEME="agnoster"/' ~/.zshrc

cat << 'EOF' >> ~/.zshrc

# Performance tweaks
export DISABLE_AUTO_TITLE="true"
export HISTSIZE=1000
export SAVEHIST=1000

# Aliases
alias ll='ls -la'
alias gs='git status'
alias update='sudo apt update && sudo apt upgrade -y'
EOF

chsh -s $(which zsh)

echo "🚀 Applying performance tweaks..."
echo 'vm.swappiness=10' | run_sudo tee -a /etc/sysctl.conf
run_sudo systemctl enable fstrim.timer
run_sudo apt install -y preload
gsettings set org.gnome.desktop.interface enable-animations false || true

echo "🔑 Generating SSH RSA key (if not already present)..."
if [ ! -f ~/.ssh/id_rsa ]; then
  ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N "" -C "$USER@$(hostname)"
  echo "🗝️ SSH RSA key generated at ~/.ssh/id_rsa"
else
  echo "🗝️ SSH RSA key already exists, skipping generation."
fi

echo
echo "✅ ALL DONE!"
echo "Installed software list:
1. Visual Studio Code
2. Slack
3. Flameshot
4. Python3, venv, pip
5. Git
6. Cursor AI v1.2
7. Java 17
8. Node.js (v22 LTS)
9. Postman
10. Google Chrome
11. Microsoft Teams
12. MySQL Workbench (+ saved connection)
13. Apache, MySQL, PHP (LAMP)
14. MySQL 'admin' user (pw: ntf12345)
15. MongoDB Compass
16. FileZilla
17. Upwork Desktop App
18. Oh My Zsh + plugins
19. System performance optimizations
20. SSH RSA key (generated if not present)"

read -p "🔁 Reboot now? (Y/n) " REBOOT
if [[ "$REBOOT" =~ ^[Yy]$ || -z "$REBOOT" ]]; then
  echo "Rebooting..."
  run_sudo reboot
else
  echo "Finished! Please reboot manually to apply all changes."
fi
