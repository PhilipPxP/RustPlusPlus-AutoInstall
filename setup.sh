#!/bin/bash

# Function to get user input with a prompt
prompt_user() {
  local prompt="$1"
  local result
  read -p "$prompt" result
  echo "$result"
}

# Install nvm if not already installed
if [ ! -d "$HOME/.nvm" ]; then
  echo "nvm not found. Installing nvm..."
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash
else
  echo "nvm is already installed."
fi

# Load nvm into the shell
export NVM_DIR="$HOME/.nvm"
if [ -s "$NVM_DIR/nvm.sh" ]; then
  . "$NVM_DIR/nvm.sh"  # Load nvm
else
  echo "Failed to load nvm. Please ensure it is installed correctly."
  exit 1
fi

if [ -s "$NVM_DIR/bash_completion" ]; then
  . "$NVM_DIR/bash_completion"  # Load nvm bash_completion
fi

# Install Node.js
echo "Installing Node.js version 22..."
nvm install 22 || { echo "Failed to install Node.js"; exit 1; }

# Clone the repository
echo "Cloning the repository..."
git clone https://github.com/alexemanuelol/rustplusplus.git || { echo "Failed to clone repository"; exit 1; }

# Navigate to the project directory
cd rustplusplus || { echo "Failed to navigate to repository"; exit 1; }

# Ask for bot details
bot_name=$(prompt_user "Enter the bot name: ")
client_id=$(prompt_user "Enter the bot client ID: ")
bot_token=$(prompt_user "Enter the bot token: ")

# Update the configuration file
config_file="config/index.js"
if [[ -f $config_file ]]; then
  echo "Updating configuration file..."
  sed -i "s/username: process.env.RPP_DISCORD_USERNAME || '[^']*'/username: process.env.RPP_DISCORD_USERNAME || '$bot_name'/" "$config_file"
  sed -i "s/clientId: process.env.RPP_DISCORD_CLIENT_ID || '[^']*'/clientId: process.env.RPP_DISCORD_CLIENT_ID || '$client_id'/" "$config_file"
  sed -i "s/token: process.env.RPP_DISCORD_TOKEN || '[^']*'/token: process.env.RPP_DISCORD_TOKEN || '$bot_token'/" "$config_file"
else
  echo "Configuration file not found: $config_file"
  exit 1
fi

# Install dependencies
echo "Installing dependencies..."
npm install || { echo "Failed to install dependencies"; exit 1; }

echo "Setup complete!"
