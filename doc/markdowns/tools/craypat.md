
## Introduction

CrayPat (Cray Performance Measurement and Analysis toolset) is Cray’s performance analysis tool offered by Cray. It can be used for profiling, tracing and counter based hardware performance analysis. It has a large feature set and provides access to a wide variety of performance experiments that measure how an executable program consumes resources while it is running, as well as several different user interfaces that provide access to the experiment and reporting functions. 

As it is supported by Perlmutter. We going give a brief step-by-step guidance on how to using it on **Perlmutter**

## Step-by-Step Guide
Here we will take Triangle Counting selector as an example

### Step 1: Load CrayPat necessary module
```
module unload darshan
module load perftools-base perftools
```
### Step 2: Build the application as normal but please **keep `.o` files**
Change to triangle counting example directory
```
cd $HOME/hclib/modules/bale_actor/test/
```
Build the triangle counting object file (.o file)
```
CC -g -O3 -std=c++11 -DUSE_SHMEM=1 -I/$HOME/hclib/hclib-install/include -I/$HOME/bale/src/bale_classic/build_ex/include -I/$HOME/hclib/hclib-install/../modules/bale_actor/inc -L/$HOME/hclib/hclib-install/lib -L/$HOME/bale/src/bale_classic/build_ex/lib -L/$HOME/hclib/hclib-install/../modules/bale_actor/lib -c triangle_selector.o  triangle_selector.cpp -lhclib -lrt -ldl -lspmat -lconvey -lexstack -llibgetput -lhclib_bale_actor -lm
```
Build the excutable triangle counting file
```
CC -g -O3 -std=c++11 -DUSE_SHMEM=1 -I/$HOME/hclib/hclib-install/include -I/$HOME/bale/src/bale_classic/build_ex/include -I/$HOME/hclib/hclib-install/../modules/bale_actor/inc -L/$HOME/hclib/hclib-install/lib -L/$HOME/bale/src/bale_classic/build_ex/lib -L/$HOME/hclib/hclib-install/../modules/bale_actor/lib -o triangle_selector  triangle_selector.o -lhclib -lrt -ldl -lspmat -lconvey -lexstack -llibgetput -lhclib_bale_actor -lm
```

### Step 3: Instrument the application using `pat_build`
 Generate new instrumented executable with name  `triangle_selector+pat` by default
  `pat_build triangle_selector`
!!! note
`pat_build` has different option that can trace specific function as user defined
	- `-u`: trace all user functions routine by routine
	- `-T -w`: trace function
		- eg. `pat_build –w –T <FUNCTION>`
  
### Step 4: Run the instrumented executable to get a performance data

#### Option 1: Run the executable with interactive batch job 
Allocating resources 
```
salloc --nodes 1 --qos interactive --time 00:05:00 --constraint cpu --account=mxxx
```
Run the excutable to generate a directory (e.g. `triangle_selector+pat+174621-8716327t`) containing performance data files with the`.xf` suffix. 
```
srun  -n 128 --cpu-bind=cores ./triangle_selector+pat
```
#### Option 2: Run the executable with sbatch script

```
#!/bin/bash
#SBATCH -q regular
#SBATCH -N 1
#SBATCH -C cpu
#SBATCH -t 0:05:00
#SBATCH -ooshmem_%j_tri_cout.out    

source ./oshmem-perlmutter.sh

module unload darshan
module load perftools-base perftools
export LD_LIBRARY_PATH=$CRAY_LD_LIBRARY_PATH:$LD_LIBRARY_PATH

cd $HOME/hclib/modules/bale_actor/test
echo "--------------------------------------------"
srun  -n 128 --cpu-bind=cores ./triangle_selector+pat
echo "--------------------------------------------"
```

### Step 5: Generate human-readable content with `pat_report`
Run pat_report on the generated directory name, it will output atext report in the terminal and creates files with different suffices, `.ap2` and `.apa` inside the directory
`pat_report ./triangle_selector+pat+174621-8716327t`
!!! note
`.ap2` is used to view performance data graphically with the Cray Apprentice2 tool
`.apa` is for suggested `pat_build` options for more detailed tracing experiments.



## Specifying profiling region
CrayPat performance API can be use to identify the region of interest (ROG) for analysis.
- `PAT_record(int state)`
	- Setting the recording state to **PAT_STATE_ON** or **PAT_STATE_OFF**
	- Needs to be inserted before the ROG
- `PAT_region_begin(int id, char *label)` 
	- Defines the boundaries of a region
	- Needs to be inserted at the start the ROG
- `PAT_region_end(int id);` 
	- regions must be either separate or nested
	- Needs to be inserted at the end of ROG

### Example
```
#include <pat_api.h>
...
PAT_record(PAT_STATE_ON);
PAT_region_begin(1,"selector_function");
triangle_selector();
PAT_region_end(1);
...
```
This will generate a trace of interest in the performance data which can be found in the `pat_report`

## Collecting hardware performance counters (HPWC)

The Performance Application Programming Interface (PAPI) supplies a consistent interface and methodology for collecting performance counter information from various hardware and software components, including most major CPUs, GPUs, accelerators, interconnects, I/O systems, and power interfaces, as well as virtual cloud environments.

### step 1: Find available hardware counters 
Available hardware counters can be find by `papi_avail`

### step 2: Selecting the hardware counters
Setting environment variable `PAT_RT_PERFCTR` to specific events/group
 - Predefined Counter Groups, e.g. `export PAT_RT_PERFCTR=0`
 - specify individual events (maximum of 4 event at a time), e.g. `export PAT_RT_PERFCTR="PAPI_L2_DCM,PAPI_L2_ICM"`

!!! note
Predefined Counter Groups can be found in slides 38 of [NERSC PerformanceTools](https://www.nersc.gov/assets/Uploads/PerformanceTools.pdf)

### step 3: Build and run the instrumented excutable with CrayPat
Repeat same with the step in the above Step-by-Step section
- Generate the instrumented excutable with `pat_build` 
- Run the excutable to get performance data
- Generate human-readable content with `pat_report`


## Using Apprenyice2 for analyzing results

Cray Apprentice2 is a graphical analysis tool used to further explore visualize performance data instrumented with the CrayPat tool

For installing local Cray Apprentice2 visualizer, you can find the installer in Perlmutter as below
`$CRAYPAT_ROOT/share/desktop_installers`

After installing Apprentice2 visualizer, the open the corresponding generated folder can see the visual analyzing results.	

!!! note
`/some/path/./a.out: error while loading shared libraries: pat.so: cannot open shared object file: No such file or directory`
Solution:
`export LD_LIBRARY_PATH=$CRAY_LD_LIBRARY_PATH:$LD_LIBRARY_PATH`


## Further Readings

- [NESRC CrayPat documentation](https://docs.nersc.gov/tools/performance/craypat/)
- [NERSC prepared detailed tutorial on Cray's perftools](https://www.nersc.gov/assets/Uploads/05-craypat-reveal-20170609.pdf)
- [Cray XC Series Application Programming and Optimization](https://www.nersc.gov/assets/Uploads/TR-CPO-NERSC-20190211-2.pdf) 
- [NERSC PerformanceTools](https://www.nersc.gov/assets/Uploads/PerformanceTools.pdf)