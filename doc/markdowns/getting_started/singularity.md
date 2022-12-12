# Singularity

This document discusses setting up a singularity container both locally and on PACE (Georgia Tech cluster resources).

# Setting up Singularity Locally


## Prerequisites

* a windows/linux/mac machine with `singularity` installed.
    
!!! warning

    This singularity environment is primarily for testing and is not supposed to be used for performance runs. For performance runs, see the clusters/supercomputer section.

    
## Download the `Singularity Definition File`

Currently, there are two versions of `Definition File`: one is based on the latest version of the bale library (3.x) and another is based on bale 2.x. We would recommend using the `bale3` version unless there is a specific reason to use `bale_old` version.

=== "For bale3"

    * [Def File for bale3](https://github.com/srirajpaul/hclib/blob/bale3_actor/modules/bale_actor/singularity/Singularity.def)

=== "For bale_old"

    * [Def File for bale_old](https://github.com/srirajpaul/hclib/blob/bale_actor/modules/bale_actor/singularity/Singularity.def)


## Build the `Singularity Def File`


```
sudo singularity build --sandbox actor Singularity.def
```

!!! note 
    
    This creates a sandbox container to allow for read-write operations. For more details on `singularity build`, please see [the official document](https://docs.sylabs.io/guides/3.0/user-guide/build_a_container.html)


## Use the container

```
sudo singularity shell actor
```

!!! note 
    
    For more details on `singularity shell`, please see [the official document](https://docs.sylabs.io/guides/3.1/user-guide/cli/singularity_shell.html)


!!! tip

    Once you run the container, you can safely `exit` from it and automatically keep any edits made. You can resume the session by using the same above command.
    
Within the container, the following environment variables are defined 

| Var             | Value    | Description |
| :--             | :------- | :---------- |
| LOCAL           | /usr/local | The location of the OpenSHMEM toolchain is installed | 
| CC              | /usr/local/bin/oshcc | The OpenSHMEM C compiler |
| CXX             | /usr/local/bin/oshc++ | The OpenSHMEM C++ compiler |
| OSHRUN          | /usr/local/bin/oshrun | The OpenSHMEM launcher |
| BALE_INSTALL    | /usr/local/bale/build_unknown | The location of the Bale library |
| HCLIB_ROOT      | /usr/hclib/hclib-install | The location of the HClib |
| LD_LIBRARY_PATH | LD_LIBRARY_PATH=$LOCAL/lib:$BALE_INSTALL/lib:$HCLIB_ROOT/lib:$HCLIB_ROOT/../modules/bale_actor/lib | The locations of static/dynamic libraries |
| HCLIB_WORKERS   | 1 | The number of HClib workers per each PE | 


!!! warning
  
    Do NOT change the value of `HCLIB_WORKER`. In the current implementation, we exploit the OpenSHMEM PE-level parallelism, where each PE is associated with a physical/virtual CPU core, and creating multiple workers per PE can degrade the performance and cause an error.
    

## Run the histogram example

Now that the container is running, let's build and run the selector version of the histogram benchmark. You can make it by doing `make histo_selector` and  launch it with 2 PEs using `$OSHRUN`. 

```
cd actor/usr/local/hclib/modules/bale_actor/test
make histo_selector
$OSHRUN -n 2 ./histo_selector -n 100                                                                                                                             WARNING: Failed dynamically loading /usr/local/hclib/hclib-install/lib/libhclib_bale_actor.so for "bale_actor" dependency
WARNING: HCLIB_LOCALITY_FILE not provided, generating sane default locality information
WARNING: HCLIB_WORKERS provided, creating locale graph based on 1 workers
WARNING: Failed dynamically loading /usr/local/hclib/hclib-install/lib/libhclib_bale_actor.so for "bale_actor" dependency
WARNING: HCLIB_LOCALITY_FILE not provided, generating sane default locality information
WARNING: HCLIB_WORKERS provided, creating locale graph based on 1 workers
Running histo on 2 threads
buf_cnt (number of buffer pkgs)      (-b)= 1024
Number updates / thread              (-n)= 100
Table size / thread                  (-T)= 1000
models_mask                          (-M)= 0
     0.719 seconds
```

!!! note

    Recall that OSHRUN is an environment variable and do not forget to add the dollar sign ($) before OSHRUN.



# Setting up Singularity on PACE@GATech

## Setting up the environment

Load the following modules into the PACE environment:

```
module load pace-community
module load hclib-pace
```
    
## Use the container

```
singularity shell ${HCLIB_PACE_SIF}
```

!!! note 
    
    For more details on `singularity shell`, please see [the official document](https://docs.sylabs.io/guides/3.1/user-guide/cli/singularity_shell.html)


!!! note

    This is a read-only container, meaning all the libraries and benchmarks have already been precompiled and are ready for use (see section regarding running benchmarks).

!!! tip

    Once you run the container, you can safely `exit` from it.
    
Within the container, the following environment variables are defined 

| Var             | Value    | Description |
| :--             | :------- | :---------- |
| LOCAL           | /usr/local | The location of the OpenSHMEM toolchain is installed | 
| CC              | /usr/local/bin/oshcc | The OpenSHMEM C compiler |
| CXX             | /usr/local/bin/oshc++ | The OpenSHMEM C++ compiler |
| OSHRUN          | /usr/local/bin/oshrun | The OpenSHMEM launcher |
| BALE_INSTALL    | /usr/local/bale/build_unknown | The location of the Bale library |
| HCLIB_ROOT      | /usr/hclib/hclib-install | The location of the HClib |
| LD_LIBRARY_PATH | LD_LIBRARY_PATH=$LOCAL/lib:$BALE_INSTALL/lib:$HCLIB_ROOT/lib:$HCLIB_ROOT/../modules/bale_actor/lib | The locations of static/dynamic libraries |
| HCLIB_WORKERS   | 1 | The number of HClib workers per each PE | 


!!! warning
  
    Do NOT change the value of `HCLIB_WORKER`. In the current implementation, we exploit the OpenSHMEM PE-level parallelism, where each PE is associated with a physical/virtual CPU core, and creating multiple workers per PE can degrade the performance and cause an error.
    

## Run the histogram example

Now that the container is running, let's build and run the selector version of the histogram benchmark. It has been precompiled so you can launch it with 2 PEs using `$OSHRUN`. 

```
cd actor/usr/local/hclib/modules/bale_actor/test
$OSHRUN -n 2 ./histo_selector -n 100                                                                                                                             WARNING: Failed dynamically loading /usr/local/hclib/hclib-install/lib/libhclib_bale_actor.so for "bale_actor" dependency
WARNING: HCLIB_LOCALITY_FILE not provided, generating sane default locality information
WARNING: HCLIB_WORKERS provided, creating locale graph based on 1 workers
WARNING: Failed dynamically loading /usr/local/hclib/hclib-install/lib/libhclib_bale_actor.so for "bale_actor" dependency
WARNING: HCLIB_LOCALITY_FILE not provided, generating sane default locality information
WARNING: HCLIB_WORKERS provided, creating locale graph based on 1 workers
Running histo on 2 threads
buf_cnt (number of buffer pkgs)      (-b)= 1024
Number updates / thread              (-n)= 100
Table size / thread                  (-T)= 1000
models_mask                          (-M)= 0
     0.719 seconds
```

!!! note

    Recall that OSHRUN is an environment variable and do not forget to add the dollar sign ($) before OSHRUN.






