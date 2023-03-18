#!/bin/bash

###  Setup script to run after codespaces dev container built.
###  Should be run as a postCreateCommand via the devcontainer.json file
###  Dotfiles cloning should not run via github settings, will be run here.
###  Assumes will run as vscode user so home will be home for that user
### Assumes devcontainer.json is calling this script via bash -i aka interactive mode

echo "Installing Developer Requirements"
# make aliases expand and work in the script
shopt -s expand_aliases

#  Go to home directory for user
cd ~ || exit

# setup dotfiles management
# assumes .cfg is already in .gitignore, if not needs to be to avoid recursion problems
#don't need this, git clone creates .cfg directory
#git init --bare "$HOME"/.cfg
# clone dotfiles repository
# repo is private, so url includes github PAT token
git clone --bare https://github.com/broander/dotfiles.git "$HOME"/.cfg
#moved next command to postCreateCommand commands so config is defined prior to running the alias below
alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'
config config --local status.showUntrackedFiles no
# stash any conflicting dotfiles so can checkout files from repo
config stash
config checkout
# copy good git config file for this repo so easy to commit config changes for dotfiles
cp ~/.setup_config/backup-git-.cfg-config ~/.cfg/config
# copy the github codespace ssh secret that's already configured in github
echo "$SSH_KEY_GITHUB" >~/.ssh/github
chmod 600 ~/.ssh/github

# add conda init info for shells
conda init
conda init fish
conda init zsh

# # Install powerline
# pip install --user powerline-status

# # update ipython and powerline so it works with ipython
# pip install ipython --upgrade
# pip install ipdb  # for better debugging
# pip install prompt_toolkit --upgrade
# pip install pygments --upgrade
# pip install git+https://github.com/powerline/powerline.git@develop

# Install TMUX Plugin manager
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
~/.tmux/plugins/tpm/scripts/install_plugins.sh

# Update fish to the latest version
# Test if Debian 11
if lsb_release -i | grep -q Debian && lsb_release -d | grep -q 11; then
    echo 'deb http://download.opensuse.org/repositories/shells:/fish:/release:/3/Debian_11/ /' | sudo tee /etc/apt/sources.list.d/shells:fish:release:3.list
    curl -fsSL https://download.opensuse.org/repositories/shells:fish:release:3/Debian_11/Release.key | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/shells_fish_release_3.gpg >/dev/null
    sudo apt-get update && export DEBIAN_FRONTEND=noninteractive && sudo apt-get -y install fish
fi
# Test if Ubuntu
if lsb_release -i | grep -q Ubuntu; then
    sudo apt-add-repository ppa:fish-shell/release-3
    sudo apt-get update && export DEBIAN_FRONTEND=noninteractive && sudo apt-get -y install fish
fi

# Install ohmyfish, and bobthefish
curl https://raw.githubusercontent.com/oh-my-fish/oh-my-fish/master/bin/install >install
fish install --noninteractive --path=~/.local/share/omf --config=~/.config/omf
fish omf install bobthefish

# Install latest version of VIM # not working with miniconda python10...
# mkdir ~/Github
# mkdir ~/Github/BuildClones
# cd ~/Github/BuildClones || exit
# git clone https://github.com/vim/vim.git
# cd vim || exit
# cd src || exit
# # uses customized makefile per vim customization instructions
# #rm Makefile
# #cp ~/.setup_config/vim-Makefile ./Makefile
# ./configure --enable-python3interp --disable-gui --without-x
# sudo apt-get update && export DEBIAN_FRONTEND=noninteractive && sudo apt-get -y install git make clang libtool-bin libpython3-dev
# make reconfig
# make
# sudo make install
# cd ~ || exit

# install vim with conda-forge instead
# fix permissions issue that crops up
#sudo chown -R vscode /opt/conda/lib/python3.10/site-packages/*
#sudo chown -R vscode /opt/conda/lib/*
#conda install -n base -c conda-forge -y mamba
mamba update -n base -y mamba
mamba update -n base -y conda
mamba install -n base -c conda-forge -y vim
mamba update -n base -c conda-forge -y ncurses

# Vundle for VIM
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
#git clone https://github.com/vim-scripts/vundle.git ~/.vim/bundle/Vundle.vim
#git clone https://github.com/Kernelily/Vundle ~/.vim/bundle/Vundle.vim # backup of vundle repo for use while it's down
# Install VIM plugins specified in .vimrc
#vim +PlugInstall +qall
vim --clean '+source ~/.vimrc' +PluginInstall +qall

# Install vim-language-server, which requires NPM
sudo npm install -g vim-language-server

# install YTOP system performance tool; requires rust
# install rust first
curl https://sh.rustup.rs -sSf | sh -s -- -y
source "$HOME/.cargo/env"
# not being maintained, trying alternative below
# ./.cargo/bin/cargo install ytop
# install btm
rustup update stable
# install with rust
# cargo install bottom --locked
# install deb package, less to download
curl -LO https://github.com/ClementTsang/bottom/releases/download/0.8.0/bottom_0.8.0_amd64.deb
sudo dpkg -i bottom_0.8.0_amd64.deb

# Install Universal Ctags
mkdir ~/Github
mkdir ~/Github/BuildClones
cd ~ || exit
cd Github || exit
cd BuildClones || exit
git clone https://github.com/universal-ctags/ctags.git
cd ctags || exit
./autogen.sh
./configure #--prefix=/where/you/want # defaults to /usr/local./configure
make
sudo make install
cd ~ || exit

# # YouCompleteMe language completer for VIM
python3 ~/.vim/bundle/YouCompleteMe/install.py --clangd-completer

# Install latest version of Mosh
# Start by installing prerequisites (assumes Debian or Ubuntu)
# sudo apt-get update && export DEBIAN_FRONTEND=noninteractive && sudo apt-get -y install build-essential \
#     protobuf-compiler libprotobuf-dev pkg-config libutempter-dev zlib1g-dev libncurses5-dev \
#     libssl-dev bash-completion tmux less
# cd ~/Github/BuildClones || exit
# git clone https://github.com/mobile-shell/mosh.git
# cd mosh || exit
# ./autogen.sh
# ./configure
# make
# sudo make install
# cd ~ || exit

# install additional conda env stuff
eval "$CODESPACE_VSCODE_FOLDER/.devcontainer/conda-env-setup.sh"

echo "Developer Requirements Installation Completed"
sleep 3

exit
