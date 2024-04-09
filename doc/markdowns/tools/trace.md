# HClib Network Trace Generation
This document gives a brief guidance on how to generate trace for actor applications.

## Step-by-Step Guide

Here we will take Triangle Counting selector version as an example.

### Step 1: Build HClib 
Build the Hclib and setup the environment, please refer to [hclib-actor](https://hclib-actor.com/getting_started/clusters/) setup page.

### Step 2: Enable the Trace function
Enable the trace function with the macros `ENABLE_TRACE` in triangle_selector.
User need to put `#define ENABLE_TRACE`  **BEFORE** the `#include  "selector.h"` header file to enable the trace function.
```
#include  <math.h>
#include  <shmem.h>
...
#define ENABLE_TRACE
#include  "selector.h"
...
```
**Cautious: Experimental function, user may encounter redefinition issue.**

### Step 3: Recomplie the application
Recompile the `triangle_selector.cpp` application located in `$HCLIB_ROOT/../modules/bale_actor/test`

```
rm triangle_selector
make triangle_selector
```

### Step 4: Run the application
Sbatch script example
```
#!/bin/bash
#SBATCH -q regular
#SBATCH -N 1
#SBATCH -n 2 --ntasks-per-node=2
#SBATCH -C cpu
#SBATCH -t 00:05:00
#SBATCH -ooshmem_%j_TC_trace.out

source  ./oshmem-perlmutter.sh
cd  $HCLIB_ROOT/../modules/bale_actor/test
echo  "--------------------------------------------"
srun  --cpu-bind=cores  ./triangle_selector  -f  small.mtx
echo  "--------------------------------------------"
```

**Output**
```
Running triangle on 2 threads
Model mask (M) = 15 (should be 1,2,4,8,16 for agi, exstack, exstack2, conveyors, alternates
algorithm (a) = 0 (0 for L & L*U, 1 for L & U*L)
Reading file small.mtx...
A has 65536 rows/cols and 909917 nonzeros.
L has 65536 rows/cols and 909917 nonzeros.
Run triangle counting ...
Calculated: Pulls = 148076145
            Pushes = 99980803

Running Selector: 
   113.592 seconds:         15673768 triangles
Logical actor message trace enabled
PE:0, Node 0
PE:1, Node 0
```
It will also generate data files for each PE. In this example, two data file `PE0_send.dat` and `PE1_send.dat` were generated since we ran this application on two thread.

The Format of the data is show as below:

**SourceID (node,PE), DestID (node,pe), pkt size, <Timestamp (seconds)>**

E.g. 3, 15, 1, 5, 16, 1689905738.916986
