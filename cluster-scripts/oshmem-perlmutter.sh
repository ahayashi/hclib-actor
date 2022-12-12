#!/bin/bash

module load cray-openshmemx/11.5.5
module load cray-pmi/6.1.3

export PLATFORM=ex
export BALE_INSTALL=$HOME/bale/src/bale_classic/build_ex
export HCLIB_ROOT=$HOME/hclib/hclib-install
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$BALE_INSTALL/lib:$HCLIB_ROOT/lib:$HCLIB_ROOT/../modules/bale_actor/lib
export HCLIB_WORKERS=1
export CC=cc
export CXX=CC

