#!/bin/bash

YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to prompt user with validation
prompt_user() {
  local prompt_message=$1
  local response
  while true; do
    read -p "$prompt_message (Y/n): " response
    response=${response:-Y}
    case "$response" in
      [Yy]* ) return 0 ;;  # Yes
      [Nn]* ) return 1 ;;  # No
      * ) echo "Invalid input. Please enter 'y' or 'n'." ;;  # Invalid input
    esac
  done
}

# Prompt user for confirmation to update and upgrade system packages
if prompt_user "Do you want to update system packages?"; then
  sudo apt update && sudo apt upgrade -y
else
  echo "Skipping update and upgrade of system packages."
fi

# Check if Oh My Zsh is installed
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "Oh My Zsh is not installed. Installing..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
  echo "Oh My Zsh is already installed."
fi

# Switch to Zsh shell if not already using it
if [ "$SHELL" != "$(which zsh)" ]; then
  echo "Switching to Zsh shell..."
  exec zsh
else
  echo "Already using Zsh shell."
fi


# Install Zsh plugins if not already installed
ZSH_CUSTOM=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
  echo "Installing zsh-autosuggestions plugin..."
  git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
else
  echo "zsh-autosuggestions plugin is already installed."
fi

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
  echo "Installing zsh-syntax-highlighting plugin..."
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
else
  echo "zsh-syntax-highlighting plugin is already installed."
fi

# Append plugins to ~/.zshrc if not already present
if grep -q "plugins=(.*zsh-autosuggestions.*zsh-syntax-highlighting.*)" ~/.zshrc; then
  echo -e "${YELLOW}Plugins 'zsh-autosuggestions' and 'zsh-syntax-highlighting' are already set in ~/.zshrc${NC}"
else
  sed -i '/^plugins=/ s/)/ zsh-autosuggestions zsh-syntax-highlighting)/' ~/.zshrc
  echo -e "${YELLOW}Done setting 'plugins=(zsh-autosuggestions zsh-syntax-highlighting)' in ~/.zshrc${NC}"
  exec zsh
fi

# Function to check if a command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Install fnm (Fast Node Manager) if not installed
if command_exists fnm; then
  echo "fnm is already installed."
else
  echo "Installing fnm (Fast Node Manager)..."
  curl -fsSL https://fnm.vercel.app/install | bash
  exec zsh
  fnm install --lts
fi

# Install pnpm if not installed
if command_exists pnpm; then
  echo "pnpm is already installed."
else
  echo "Installing pnpm..."
  curl -fsSL https://get.pnpm.io/install.sh | sh -
fi

# Install bun if not installed
if command_exists bun; then
  echo "bun is already installed."
else
  echo "Installing bun..."
  curl -fsSL https://bun.sh/install | bash
fi

# Install gh (GitHub CLI) if not installed
if command_exists gh; then
  echo "gh (GitHub CLI) is already installed."
else
  echo "Installing gh (GitHub CLI)..."
  sudo mkdir -p -m 755 /etc/apt/keyrings \
  && wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
  && sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
  && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
  && sudo apt update \
  && sudo apt install gh -y
fi

# Install Miniconda if not installed
if command_exists conda; then
  echo "Miniconda is already installed."
else
  echo "Installing Miniconda..."
  mkdir -p ~/miniconda3
  wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda3/miniconda.sh
  bash ~/miniconda3/miniconda.sh -b -u -p ~/miniconda3
  rm -rf ~/miniconda3/miniconda.sh
  ~/miniconda3/bin/conda init zsh
  exec zsh
  conda config --set auto_activate_base false
fi

# Prompt user for confirmation to update Git configuration
if prompt_user "Do you want to update Git configuration (email and username)?"; then
  # Prompt for Git user email and name
  read -p "Enter your Git user email: " git_email
  read -p "Enter your Git user name: " git_name

  # Setup Git configuration
  git config --global user.email "$git_email"
  git config --global user.name "$git_name"
  echo "Git configured with email $git_email and name $git_name."
else
  echo "Skipping Git configuration."
fi

# Prompt user for GitHub CLI setup
if prompt_user "Do you want to set up GitHub CLI"; then
  echo "Setting up GitHub CLI..."
  gh auth login -s delete_repo
else
  echo "Skipping GitHub CLI setup."
fi

# Prompt user for setting up .tmux.conf
if prompt_user "Do you want to set up .tmux.conf using my file?"; then
  if [ ! -f "./.tmux.conf" ]; then
    echo "Error: .tmux.conf file not found in the script's directory."
  else
    if [ -f ~/.tmux.conf ]; then
      # Prompt user for confirmation to overwrite existing ~/.tmux.conf
      if prompt_user "~/.tmux.conf already exists. Do you want to overwrite it?"; then
        echo "Overwriting ~/.tmux.conf..."
        cp ./.tmux.conf ~/.tmux.conf
        echo "Successfully set up .tmux.conf."
      else
        echo "Skipping tmux setup."
      fi
    else
      echo "Setting up .tmux.conf..."
      cp ./.tmux.conf ~/.tmux.conf
      echo "Successfully set up .tmux.conf."
    fi
  fi
else
  echo "Skipping tmux setup."
fi

echo -e "${YELLOW}If no errors were found, setup is complete!${NC}"
