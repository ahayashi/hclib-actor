# ActorProf: A Framework for Profiling and Visualizing Fine-grained Asynchronous Bulk Synchronous Parallel Execution
This document gives a brief guidance on how to generate trace for actor applications on COTS (typically x86) systems using **ActorProf**. For more details about ActorProf, please refer to [our paper](https://conferences.computer.org/sc-wpub/pdfs/SC-W2024-6oZmigAQfgJ1GhPL0yE3pS/555400b599/555400b599.pdf).

## Step-by-Step Guide
Here we will take **Triangle Counting** selector as an example on `Perlmutter`.For other machines, please follow the [Manual installation and run instructions](https://hclib-actor.com/tools/actorprof/#manual-installation-and-run-instructions)

### Step 1: Build `HClib` and `Bale`
Build the HClib and bale libraries to setup the environment. For setting up `HClib` and `Bale` libraries on `Perlmutter`, please source the `perlumtter_setup.sh` script provided.
``` 
source perlumtter_setup.sh
```
Please refer to [HClib-Actor](https://hclib-actor.com/getting_started/clusters/) setup page for more details on how to setup on other machines

**Note: please re-direct to current directory and source the setup script again to set all environment variables every time after you login to a cluster/supercomputer**

### step 2: Allocate interactive compute node
Allocate to run the Actorprof scripts

```
salloc --nodes 1 --qos interactive --time 00:10:00 --constraint cpu --account=mxxx
```

### Step 3: Run Actorprof Script
Run the ActorProf bash script (`run_actorprof.sh`) which has 4 options:

```
   source ./run_actorprof.sh [logical | papi | physical| overall | all] [triangle_selector | triangle_selector_interval] [1...N] [1...N]
   
   [logical | papi | physical | overall | all]                       Selects which type of trace (or all) to generate
   [triangle_selector | triangle_selector_interval] Selects which application to generate the trace (triangle_selector - cyclic distribution or triangle_selector_interval - range distribution)
   [1...N]                                        Selects Scale of the RMATE graph
   [1...N]                                        Selects the number of cores for the run

```

### Logical Trace
E.g. Generate logical trace of triangle selector with **1D Cyclic** distribution on scale of 10 using 2 cores
``` 
source run_actorprof.sh logical triangle_selector 10 2
```

It will generate one trace file `*send.csv` for each PE and a Heatmap `application_logical.png`. In this example, three files `PE0_send.csv`, `PE1_send.csv` and `triangle_selector_logical.png` were generated since we ran this application on two threads.

### HWPC Trace
E.g. Generate HWPC trace of triangle selector with **1D Cyclic** distribution on scale of 10 using 2 cores
``` 
source run_actorprof.sh papi triangle_selector 10 2
```

It will generate two trace file `PE*_send.csv` and `PE*_papi.csv` for each PE, one Heatmap `logical.png`, and a bar graph `papi.png`. In this example, three files `PE0_send.csv`, `PE1_send.csv`, `logical.png`, and `papi.png` were generated since we ran this application on two threads.

### Physical trace
E.g. Generate physical trace of triangle selector with **1D Cyclic** distribution on scale of 10 using 2 cores
``` 
source run_actorprof.sh physical triangle_selector 10 2
```

It will generate one trace file `physical.txt`  and a stacked bar graph `physical.png`.

### Overall Trace
E.g. Generate overall trace of triangle selector with **1D Cyclic** distribution on scale of 10 using 2 cores
``` 
source run_actorprof.sh overall triangle_selector 10 2
```

It will generate the `overall.txt` trace file and a stacked bar graph `overall.png`.

**Note: user can use `all` to generat all four trace mentioned above at once**

## Manual installation and run instructions¶
If user decide to build and run Actorprof manually without using the ActorProf bash script (`run_actorprof.sh`), you can use the guide below. 

### Step 1: Environment Setup

Please refer to [HClib-Actor](https://hclib-actor.com/getting_started/clusters/) setup page for more details on how to build the HClib and bale libraries to setup the environment.

### Step 2: Build Application with trace flag enabled
* `-DENABLE_TRACE` flag for enabling logical message generation macro.
* `-DENABLE_TRACE_PAPI` flag for enabling logical message and HWPC trace generation macro.
* `-DENABLE_TCOMM_PROFILING` flag for enabling overall trace generation macros.
* `-DENABLE_TRACE_PHYSICAL` flag for enabling physical message trace generation macro.

Below is an example of building the **1D-Cyclic Triangle Counting** application on Perlmutter with logical, overall, and physical trace macros respectively using `Makefile`.
```
cd $PWD/hclib/modules/bale_actor/test
make triangle_selector_logical
make triangle_selector_logical_papi
make triangle_selector_overall
make triangle_selector_physical
```

### Step 3: Trace Generation
Here we will take **1D-Cyclic Triangle Counting**  to run as an example on `Perlmutter` interactive node.

1) To generate **Logical Message Trace and HWPC Trace**
```
srun  -N 2 -n 32 --cpu-bind=cores ./triangle_selector_logical_papi -f small.mtx
```

It will generate two trace files (`*send.csv` and `*PAPI.csv`) for each PE. 
In this example, 64 data files, i.e., `PE0_send.csv`, `PE0_PAPI.csv`, `PE1_send.csv`, `PE1_PAPI.csv`,..., will be generated since we ran this application on 32 threads.

**Note: To generate logical trace only, please use triangle_selector_logical execuitable.**

2) To generate **Overall Trace**
```
srun  -N 2 -n 32 --cpu-bind=cores ./triangle_selector_overall -f small.mtx &>overall.txt
```

`overall.txt` contains overall trace for every PE in one `.txt` file.

3) To generate **Physical Message Trace**
```
srun  -N 2 -n 32 --cpu-bind=cores ./triangle_selector_physical -f small.mtx &> physical.txt
```

`physical.txt` contains Physical message trace for every PE in one `.txt` file.

### Step 4: ActorProf Visualization
Four type of graphs can be generated with **ActorProf** with different flags using `actorprof.py`, please put all generated trace into the data directory before running **ActorProf**.

`transfer.sh` can be used to create data dir in correct format and move all generated trace into the data directory. 
```
source transfer.sh
```

**Cautious: Please use the script or manually empty/remove the data directory every time generating a new trace file to aviod trace data overlap, which may lead to incorrect visualizing result.**

Path to the data directory (`path`) and total number of PEs( `-n` or `--num_PEs` ) used to generate the trace files are required for running the **ActorProf**.
1) Logical Message trace Heatmap
`-l` flag is needed to generate Logical Message Trace Heatmap
2) Physical Message trace Heatmap
`-p` option is needed to generate Physical Message Trace Heatmap
&emsp; `0`for Local Send Message trace Heatmap (Default)
&emsp; `1` for Non-blocking Message Trace Heatmap
3) HWPC trace Heatmap
`-lp` flag is needed to generate HWPC Trace bar-graph
4) Overall trace Heatmap
`-s` flag is needed to generate stacked bar-graph for overall absolute and relative execution time

**Note: please specify all flags when trying to profile all result.**

Example to run **ActorProf** visualizer using `actorprof.py` to generate physical trace Heatmap.
```
python actorprof.py ./data -n 32 -p
```

All result will be saved as an  `.png` figure.


## Top-Level Directory Organization
The folder structure of this repository is as follows:

    .
    ├── ActorProf           # Contains files for the ActorProf Tool
    │   ├── hclib           # Contains the HClib library and the  Actor-based runtime
    │   │   ├── ...                                         
    │   └── ─── modules                         
    │   │   │   ├── ...                             
    │   └── ─── ─── bale_actor                       
    │   │   │   │   ├── ...                                
    │   └── ─── ─── ─── test    # Contains the Triangle Counting Selector application files
    │   │   │   │   ├── triangle_selector.cpp   # Triangle Counting code for 1D-Cyclic version
    │   │   │   │   ├── triangle_selector_interval.cpp	# Triangle Counting code for 1D-Range version
    │   │   │   │   ├── small.mtx						# Scale of 16 Triangle Counting graph
    │   └── ─── ─── ─── ...                             
    ├── logical.py          # Visualization for Logical Message Trace
    ├── papi.py             # Visualization for HWPC Trace
    ├── physical.py	        # Visualization for Physical Message Trace
    ├── overall.py          # Visualization for Overall Trace    
    ├── generate_rmate.py   # RMAT Graph generation for applications
    ├── run_actorprof.sh    # Top to down complete run script for using ActorProf 
    └── README.md

## Citation

If you use our application in your work, please cite [our paper](https://conferences.computer.org/sc-wpub/pdfs/SC-W2024-6oZmigAQfgJ1GhPL0yE3pS/555400b599/555400b599.pdf).

> ActorProf: A Framework for Profiling and Visualizing Fine-grained Asynchronous Bulk Synchronous Parallel Execution. Jiawei Yang, Shubhendra Pal Singhal, Jun Shirako, Akihiro Hayashi, Vivek Sarkar. Workshop on Programming and Performance Visualization Tools (ProTools2024, co-located with SC24)


Corresponding author: Jiawei Yang ([jyang810@gatech.edu](mailto:jyang810@gatech.edu)), Shubhendra Pal Singhal([ssinghal74@gatech.edu](mailto:ssinghal74@gatech.edu))