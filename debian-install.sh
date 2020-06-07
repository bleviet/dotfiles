#!/usr/bin/bash

function install {
  which $1 &> /dev/null

  if [ $? -ne 0 ]; then
    echo "Installing: ${1}..."
    sudo apt-get install $1
  else
    echo "Already installed: ${1}"
  fi
}

sudo apt-get update
install fonts-powerline
install git
install gitk
install vim
install ctags
install tmux

# Install VS Code repository and key
curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -o root -g root -m 644 packages.microsoft.gpg /usr/share/keyrings/
sudo sh -c 'echo "deb [arch=amd64 signed-by=/usr/share/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'

install apt-transport-https
sudo apt-get update
install code # or code-insiders
sudo update-alternatives --set editor /usr/bin/code # set code as default editor

# Install Miniconda with Anaconda
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh
bash ~/miniconda.sh -b -p $HOME/miniconda
conda update -n base conda
conda install anaconda

# VHDL Dev
## Install Symbolator
install libcairo2
install libcairo2-dev
install python-cairo
install python3-gi
conda config --add channels conda-forge
conda create --name symbolator
conda activate symbolator
conda install pip pygobject pango
/opt/anaconda3/envs/symbolator/bin/pip install --upgrade symbolator