#! /bin/bash

# script to install additional conda environment stuff.  Most often executed
# as part of the dev_tools script run in container builds.

# assumes that desired channel priority is defined in the ~/.condarc
# channel priority probably needs to be conda-forge first given what is
# typically installed

# first update the base install to be up-to-date
echo "updating base conda environment"
mamba update -n base -y --all
mamba install -c conda-forge jupyterlab

# now create a clone of base environment
echo "creating a clone of base environment named 'altair'"
mamba create --name altair --clone base

# make sure the clone is up-to-date
echo "updating 'altair' environment"
mamba update -n altair -y --all

# install additional packages in the new cloned env
echo "installing additional packages in 'altair' environment"
mamba install -n altair -y altair vega_datasets altair_viewer jupyterlab
