#!/bin/bash

# openmpi is for mpiexec
module load gcc python openmpi/4.1.4

export CC=oshcc
export CXX=oshc++

# bale
if [ ! -d bale ]; then
    git clone https://github.com/jdevinney/bale.git
    cd bale/src/bale_classic/
    ./bootstrap.sh
    PLATFORM=oshmem ./make_bale -s -f
    cd ../../../
fi

# hclib
if [ ! -d hclib ]; then
    git clone https://github.com/srirajpaul/hclib
    cd hclib
    git fetch && git checkout bale3_actor
    ./install.sh
    cd modules/bale_actor && make
    cd benchmarks
    unzip ../inc/boost.zip -d ../inc/
    cd ../../../../
fi

export BALE_INSTALL=$PWD/bale/src/bale_classic/build_oshmem
export HCLIB_ROOT=$PWD/hclib/hclib-install
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$BALE_INSTALL/lib:$HCLIB_ROOT/lib:$HCLIB_ROOT/../modules/bale_actor/lib
export HCLIB_WORKERS=1
