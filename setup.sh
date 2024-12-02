#!/bin/bash

set -e

# Function to safely prompt the user
prompt_user() {
  local prompt="$1"
  local input
  echo -n "$prompt: "
  read input
  echo "$input"
}

# Install nvm if not already installed
if [ ! -d "$HOME/.nvm" ]; then
  echo "nvm not found. Installing nvm..."
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash
fi

# Load nvm into the shell
export NVM_DIR="$HOME/.nvm"
if [ -s "$NVM_DIR/nvm.sh" ]; then
  source "$NVM_DIR/nvm.sh"  # Load nvm
else
  echo "Failed to load nvm. Please ensure it is installed correctly."
  exit 1
fi

if [ -s "$NVM_DIR/bash_completion" ]; then
  source "$NVM_DIR/bash_completion"  # Load nvm bash_completion
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
echo "Configuring the bot..."
bot_name=$(prompt_user "Enter the bot name")
client_id=$(prompt_user "Enter the bot client ID")
bot_token=$(prompt_user "Enter the bot token")

# Update the configuration file
config_file="config/index.js"
if [[ -f $config_file ]]; then
  echo "Updating configuration file..."

  # Safely update specific lines with awk
  awk -v bot_name="$bot_name" -v client_id="$client_id" -v bot_token="$bot_token" '
    BEGIN { updated_username=0; updated_clientid=0; updated_token=0 }
    /username: process.env.RPP_DISCORD_USERNAME/ {
      if (!updated_username) {
        print "        username: process.env.RPP_DISCORD_USERNAME || \x27" bot_name "\x27,";
        updated_username=1;
        next;
      }
    }
    /clientId: process.env.RPP_DISCORD_CLIENT_ID/ {
      if (!updated_clientid) {
        print "        clientId: process.env.RPP_DISCORD_CLIENT_ID || \x27" client_id "\x27,";
        updated_clientid=1;
        next;
      }
    }
    /token: process.env.RPP_DISCORD_TOKEN/ {
      if (!updated_token) {
        print "        token: process.env.RPP_DISCORD_TOKEN || \x27" bot_token "\x27,";
        updated_token=1;
        next;
      }
    }
    { print }
  ' "$config_file" > temp_config.js && mv temp_config.js "$config_file"

else
  echo "Configuration file not found: $config_file"
  exit 1
fi

# Install dependencies
echo "Installing dependencies..."
npm install || { echo "Failed to install dependencies"; exit 1; }

echo "Setup complete!"
npm start run
