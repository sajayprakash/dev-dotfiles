#!/bin/bash

# Colors for better readability
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Install the required packages
sudo apt install -y curl unzip zsh git

# Install Oh My Zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Install zsh plugins
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# Install fnm (Fast Node Manager)
curl -fsSL https://fnm.vercel.app/install | bash

# Install pnpm 
curl -fsSL https://get.pnpm.io/install.sh | sh -

# Install bun
curl -fsSL https://bun.sh/install | bash

# Install Github CLI
sudo mkdir -p -m 755 /etc/apt/keyrings && wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
&& sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
&& echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
&& sudo apt update \
&& sudo apt install gh -y

# Install Miniconda
mkdir -p ~/miniconda3
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda3/miniconda.sh
bash ~/miniconda3/miniconda.sh -b -u -p ~/miniconda3
rm -rf ~/miniconda3/miniconda.sh
~/miniconda3/bin/conda init zsh

# Reload the shell
exec zsh

# Prevent miniconda from auto activating env
conda config --set auto_activate_base false

# Finalize
echo -e "${BLUE}Complete the following steps to finalize the setup:${NC}"
echo -e "${YELLOW}Set 'plugins=(zsh-autosuggestions zsh-syntax-highlighting)' in ~/.zshrc"
echo -e "${YELLOW}Setup fnm using 'fnm install --lts'${NC}"
echo -e "${YELLOW}Setup gh cli using 'gh auth login -s delete_repo'${NC}"
