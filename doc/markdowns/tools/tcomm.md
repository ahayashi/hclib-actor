# HClib T_COMM profiling

This document gives a brief guidance on how to generate HClib T_COMM profiling for actor applications on COTS (typically x86) systems.

## Step-by-Step Guide

Here we will take Triangle Counting selector version as an example.

### Step 1: Build HClib 
Build the Hclib and setup the environment, please refer to [hclib-actor](https://hclib-actor.com/getting_started/clusters/) setup page.

### Step 2: Enable the TCOM function
Enable the trace function with the macros `ENABLE_TCOMM_PROFILING` in triangle_selector.
User need to put `#define ENABLE_TCOMM_PROFILING`  **BEFORE** the `#include  "selector.h"` header file to enable the trace function.
```
#include  <math.h>
#include  <shmem.h>
...
#define ENABLE_TCOMM_PROFILING
#include  "selector.h"
...
```
**Cautious: Experimental function, user can not define Trace and TCOM at the same time.**

### Step 3: Call the output function
User need to call the output function `print_profiling(char *prefix="")`  to print the results, `prefix` is the label specified as the argument to `print_profiling` function. 

For example in TC:
```
...
#ifdef ENABLE_TCOMM_PROFILING 
	triSelector->print_profiling("tc");
#endif
...
```
### Step 4: Recomplie the application
Add PAPI-related options to the `Makefile` located in `$HCLIB_ROOT/../modules/bale_actor/test`, e.g., for PACE cluster:

```
PAPI_ROOT=/usr/local/pace-apps/manual/packages/papi/7.0.1/usr/local
...
%: %.cpp
        $(CXX) -g -O3 -std=c++11 -DUSE_SHMEM=1 $(HCLIB_CFLAGS) $(HCLIB_LDFLAGS) -o $@ $^ $(HCLIB_LDLIBS) -I${PAPI_ROOT}/include -L${PAPI_ROOT}/lib -lpapi -lspmat -lconvey -lexstack -llibgetput -lhclib_bale_actor -lm
```

Recompile the `triangle_selector.cpp` application located in `$HCLIB_ROOT/../modules/bale_actor/test`

```
rm triangle_selector
make triangle_selector
```

### Step 5: Run the application
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
Running triangle on 8 threads
Model mask (M) = 15 (should be 1,2,4,8,16 for agi, exstack, exstack2, conveyors, alternates
algorithm (a) = 0 (0 for L & L*U, 1 for L & U*L)
Reading file ./small.mtx...
A has 65536 rows/cols and 909917 nonzeros.
L has 65536 rows/cols and 909917 nonzeros.
Run triangle counting ...
Calculated: Pulls = 148076145
            Pushes = 99980803

Running Selector: 
     8.797 seconds:         15673768 triangles
tc [PE6] T_inside_finish (start - done): 697240862 cycles
tc [PE6] T_wait (done - finish): 0 cycles
tc [PE6] T_outside_finish (start - finish): 0 cycles
tc [PE6] T_sends (count=1317585): 657900662 cycles
tc [PE6] T_send_in_process (count=0): 0 cycles
tc [PE6] T_process (count=191674): 19571194 cycles
tc [PE6] T_TOTAL would be much bigger/smaller than T_finish
tc [PE6] TCOMM_PROFILING (T_MAIN, T_COMM, T_PROC, T_TOTAL), 39340200, 638329468, 19571194, 697240862
tc [PE6] TCOMM_PROFILING (T_MAIN/T_TOTAL, T_COMM/T_TOTAL, T_PROC/T_TOTAL), 0.056423, 0.915508, 0.028069
tc [PE2] T_inside_finish (start - done): 8426154822 cycles
tc [PE2] T_wait (done - finish): 0 cycles
tc [PE2] T_outside_finish (start - finish): 0 cycles
...
tc [PE5] T_inside_finish (start - done): 658667996 cycles
tc [PE5] T_wait (done - finish): 0 cycles
tc [PE5] T_outside_finish (start - finish): 0 cycles
tc [PE5] T_sends (count=1221575): 621838414 cycles
tc [PE5] T_send_in_process (count=0): 0 cycles
tc [PE5] T_process (count=181624): 18025404 cycles
tc [PE5] T_TOTAL would be much bigger/smaller than T_finish
tc [PE5] TCOMM_PROFILING (T_MAIN, T_COMM, T_PROC, T_TOTAL), 36829582, 603813010, 18025404, 658667996
tc [PE5] TCOMM_PROFILING (T_MAIN/T_TOTAL, T_COMM/T_TOTAL, T_PROC/T_TOTAL), 0.055915, 0.916718, 0.027366
```
The output generate result for All PEs. 

Please note that for each PEs:
- **TCOMM_PROFILING (T_MAIN, T_COMM, T_PROC, T_TOTAL)**
shows cycles in terms of `rdtsc` [[here](https://www.felixcloutier.com/x86/rdtsc)].
- **TCOMM_PROFILING (T_MAIN/T_TOTAL, T_COMM/T_TOTAL, T_PROC/T_TOTAL)**
shows the percentage.

This profilling function is still experimental, therefore it has the following  limitations/caveats:
-   The function can profile a Selector with multiple mailboxes, but the profiler assumes that the main part only does send to MB0, not MB1, MB2, …
-   Use this function just for getting rough information on what part can be a bottleneck.

## More application examplar result

### Histogram
Sbatch script example
```
#!/bin/bash
#SBATCH -q regular
#SBATCH -N 1
#SBATCH -n 2 --ntasks-per-node=2
#SBATCH -C cpu
#SBATCH -t 00:05:00
#SBATCH -ooshmem_%j_histo_trace.out

source  ./perlmutter_setup.sh
cd  $HCLIB_ROOT/../modules/bale_actor/test
echo  "--------------------------------------------"
srun  --cpu-bind=cores  ./histo_selector
echo  "--------------------------------------------"
```

**Output**
```
Running histo on 2 threads
buf_cnt (number of buffer pkgs)      (-b)= 1024
Number updates / thread              (-n)= 1000000
Table size / thread                  (-T)= 1000
models_mask                          (-M)= 0
     0.055 seconds
histo [PE0] T_inside_finish (start - done): 134534228 cycles
histo [PE0] T_wait (done - finish): 200900 cycles
histo [PE0] T_outside_finish (start - finish): 134735128 cycles
histo [PE0] T_sends (count=1000000): 108622566 cycles
histo [PE0] T_send_in_process (count=0): 0 cycles
histo [PE0] T_process (count=1000129): 25648406 cycles
histo [PE0] TCOMM_PROFILING (T_MAIN, T_COMM, T_PROC, T_TOTAL), 25911662, 83175060, 25648406, 134735128
histo [PE0] TCOMM_PROFILING (T_MAIN/T_TOTAL, T_COMM/T_TOTAL, T_PROC/T_TOTAL), 0.192316, 0.617323, 0.190362
histo [PE1] T_inside_finish (start - done): 133603939 cycles
histo [PE1] T_wait (done - finish): 1096963 cycles
histo [PE1] T_outside_finish (start - finish): 134700902 cycles
histo [PE1] T_sends (count=1000000): 107848089 cycles
histo [PE1] T_send_in_process (count=0): 0 cycles
histo [PE1] T_process (count=999871): 25657456 cycles
histo [PE1] TCOMM_PROFILING (T_MAIN, T_COMM, T_PROC, T_TOTAL), 25755850, 83287596, 25657456, 134700902
histo [PE1] TCOMM_PROFILING (T_MAIN/T_TOTAL, T_COMM/T_TOTAL, T_PROC/T_TOTAL), 0.191208, 0.618315, 0.190477
```

### Index Gather
Sbatch script example
```
#!/bin/bash
#SBATCH -q regular
#SBATCH -N 1
#SBATCH -n 2 --ntasks-per-node=2
#SBATCH -C cpu
#SBATCH -t 00:05:00
#SBATCH -ooshmem_%j_ig_trace.out

source  ./perlmutter_setup.sh
cd  $HCLIB_ROOT/../modules/bale_actor/test
echo  "--------------------------------------------"
srun  --cpu-bind=cores  ./ig_selector
echo  "--------------------------------------------"
```

**Output**
```
Running ig on 2 threads
buf_cnt (number of buffer pkgs)      (-b)= 1024
Number of Request / thread           (-n)= 1000000
Table size / thread                  (-T)= 100000
models_mask                          (-M)= 0
models_mask is or of 1,2,4,8,16 for agi,exstack,exstack2,conveyor,alternate)
     0.120 seconds
ig [PE1] T_inside_finish (start - done): 291840251 cycles
ig [PE1] T_wait (done - finish): 437570 cycles
ig [PE1] T_outside_finish (start - finish): 292277821 cycles
ig [PE1] T_sends (count=1000000): 265550829 cycles
ig [PE1] T_send_in_process (count=1000665): 109491048 cycles
ig [PE1] T_process (count=2000665): 193290221 cycles
ig [PE1] TCOMM_PROFILING (T_MAIN, T_COMM, T_PROC, T_TOTAL), 26289422, 182189226, 83799173, 292277821
ig [PE1] TCOMM_PROFILING (T_MAIN/T_TOTAL, T_COMM/T_TOTAL, T_PROC/T_TOTAL), 0.089947, 0.623343, 0.286711
ig [PE0] T_inside_finish (start - done): 284089186 cycles
ig [PE0] T_wait (done - finish): 8140370 cycles
ig [PE0] T_outside_finish (start - finish): 292229556 cycles
ig [PE0] T_sends (count=1000000): 257481362 cycles
ig [PE0] T_send_in_process (count=999335): 107141854 cycles
ig [PE0] T_process (count=1999335): 186535650 cycles
ig [PE0] TCOMM_PROFILING (T_MAIN, T_COMM, T_PROC, T_TOTAL), 26607824, 186227936, 79393796, 292229556
ig [PE0] TCOMM_PROFILING (T_MAIN/T_TOTAL, T_COMM/T_TOTAL, T_PROC/T_TOTAL), 0.091051, 0.637266, 0.271683
```

More example can also be find within the test directory