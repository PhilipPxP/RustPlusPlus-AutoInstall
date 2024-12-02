#!/bin/bash

# Function to get user input with a prompt
prompt_user() {
  local prompt="$1"
  local result
  read -p "$prompt" result
  echo "$result"
}

# Install nvm
echo "Installing nvm..."
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash

# Source nvm to use it in the script
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Install Node.js
echo "Installing Node.js version 22..."
nvm install 22

# Clone the repository
echo "Cloning the repository..."
git clone https://github.com/alexemanuelol/rustplusplus.git

# Navigate to the project directory
cd rustplusplus || exit

# Ask for bot details
bot_name=$(prompt_user "Enter the bot name: ")
client_id=$(prompt_user "Enter the bot client ID(Application ID): ")
bot_token=$(prompt_user "Enter the bot token: ")

# Update the configuration file
config_file="config/index.js"
if [[ -f $config_file ]]; then
  echo "Updating configuration file..."
  sed -i "s/username: process.env.RPP_DISCORD_USERNAME || '.*'/username: process.env.RPP_DISCORD_USERNAME || '$bot_name'/" "$config_file"
  sed -i "s/clientId: process.env.RPP_DISCORD_CLIENT_ID || '.*'/clientId: process.env.RPP_DISCORD_CLIENT_ID || '$client_id'/" "$config_file"
  sed -i "s/token: process.env.RPP_DISCORD_TOKEN || '.*'/token: process.env.RPP_DISCORD_TOKEN || '$bot_token'/" "$config_file"
else
  echo "Configuration file not found: $config_file"
  exit 1
fi

# Install dependencies
echo "Installing dependencies..."
npm install

echo "Setup complete!"
echo "Starting Bot"
npm  start run
