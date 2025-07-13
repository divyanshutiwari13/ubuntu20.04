#!/bin/bash
set -e

PASSWORD="ntf12345"

# Function to run sudo commands with password using expect
run_sudo() {
  expect -c "
    spawn sudo $@
    expect {
      \"Password:\" { send \"$PASSWORD\r\"; exp_continue }
      eof
    }
  "
}

echo "🔍 Checking for Homebrew..."
if ! command -v brew &>/dev/null; then
  echo "🍺 Homebrew not found. Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  # Add brew to PATH for current shell
  echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

echo "🔄 Updating Homebrew..."
brew update

echo "🧰 Installing essentials (git, curl, wget, zsh, node, python3, rbenv, ruby-build)..."
brew install git curl wget zsh node python rbenv ruby-build

echo "💻 Installing Visual Studio Code..."
brew install --cask visual-studio-code

echo "💬 Installing Slack..."
brew install --cask slack

echo "📦 Installing Postman..."
brew install --cask postman

echo "🌐 Installing Google Chrome..."
brew install --cask google-chrome

echo "🧮 Installing MySQL..."
brew install mysql
run_sudo brew services start mysql

echo "🐍 Setting up Python environment..."
python3 -m ensurepip --upgrade
pip3 install --upgrade pip setuptools wheel

echo "💎 Setting up Ruby environment with rbenv..."
if ! grep -q 'rbenv init' ~/.zshrc; then
  echo 'eval "$(rbenv init -)"' >> ~/.zshrc
fi
source ~/.zshrc
LATEST_RUBY=$(rbenv install -l | grep -v - | tail -1 | tr -d ' ')
rbenv install -s "$LATEST_RUBY"
rbenv global "$LATEST_RUBY"
echo "Ruby version: $(ruby -v)"

echo "🌀 Installing Oh My Zsh..."
if [ ! -d ~/.oh-my-zsh ]; then
  RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

echo "🔑 Generating SSH RSA key (if not present)..."
if [ ! -f ~/.ssh/id_rsa ]; then
  ssh-keygen -t rsa -b 4096 -N "" -f ~/.ssh/id_rsa -C "$USER@$(hostname)"
  echo "SSH RSA key generated at ~/.ssh/id_rsa"
else
  echo "SSH RSA key already exists, skipping."
fi

echo
echo "✅ Installation complete! Installed software:"
echo "
1. Git
2. Curl
3. Wget
4. Zsh
5. Node.js
6. Python3 & pip
7. Ruby (via rbenv)
8. Visual Studio Code
9. Slack
10. Postman
11. Google Chrome
12. MySQL
13. Oh My Zsh
14. SSH RSA key generated (if not existing)
"

read -p "🔁 Reboot now? (Y/n): " REBOOT
if [[ "$REBOOT" =~ ^[Yy]$ || -z "$REBOOT" ]]; then
  echo "Rebooting..."
  sudo reboot
else
  echo "Done! Please reboot manually to apply all changes."
fi
