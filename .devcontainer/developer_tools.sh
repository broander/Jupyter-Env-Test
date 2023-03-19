#!/bin/bash

###  Setup script to run after codespaces dev container built.
###  Should be run as a postCreateCommand via the devcontainer.json file
###  Dotfiles cloning should not run via github settings, will be run here.
###  Assumes will run as vscode user so home will be home for that user
### Assumes devcontainer.json is calling this script via bash -i aka interactive mode

echo "Installing Developer Requirements"
# make aliases expand and work in the script
shopt -s expand_aliases

# echo the workspace path and save as an environment variable
echo "Devcontainer workspace path is $PWD"
export DEVCONTAINER_WORKSPACE_PATH=$PWD

#  Go to home directory for user
cd ~ || exit

conda init

conda install -n base ipykernel --update-deps --force-reinstall

conda create --name test-env --clone base -y

echo "Developer Requirements Installation Completed"
sleep 3

exit
