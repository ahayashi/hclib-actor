#!/bin/bash

# Setup HClib and its modules
echo "-----------------------------------------------------"
echo "          Loading complier modules                    "
echo "-----------------------------------------------------"

# Load modules
module load cray-openshmemx
module load cray-pmi

# Export environment variables
export PLATFORM=ex
export HCLIB_WORKERS=1
export CC=cc
export CXX=CC

HCLIB=`find $HOME -name "hclib" -print -quit`
export HCLIB_ROOT=$HCLIB/hclib-install

BALE=`find $HOME -name "bale" -print -quit`
export BALE_INSTALL=$BALE/bale/src/bale_classic/build_ex

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$BALE_INSTALL/lib:$HCLIB_ROOT/lib:$HCLIB_ROOT/../modules/bale_actor/lib


# All setups are complete
echo "-----------------------------------------------------"
echo "                      Loading complete               "
echo "-----------------------------------------------------"
