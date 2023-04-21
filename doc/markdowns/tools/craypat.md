## Introduction

CrayPat (Cray Performance Measurement and Analysis toolset) is Cray’s performance analysis tool offered by Cray. Since CrayPat is only available on Cray systems, let us give a brief step-by-step guidance on how to use it on **Perlmutter**.

## Step-by-Step Guide
Here we will take Triangle Counting selector as an example:

### Step 0: Load compilers
It is important to load compiler modules before Step 1. In our case, `source` our setup script:
```
source ./oshmem-perlmutter.sh
```

### Step 1: Unload/load required modules
```
module unload darshan
module load perftools-base perftools
```
### Step 2: Build the application as normal but **keep `.o` files**
Go to the `test` directory to separately create an object file and executable for the triangle counting code:
```
cd $HCLIB_ROOT/../modules/bale_actor/test/
```
Create a tringle counting object file (.o file):
```
CC -g -O3 -std=c++11 -DUSE_SHMEM=1 -I$HCLIB_ROOT/include -I/$HOME/bale/src/bale_classic/build_ex/include -I$HCLIB_ROOT/../modules/bale_actor/inc -L$HCLIB_ROOT/lib -L/$HOME/bale/src/bale_classic/build_ex/lib -L$HCLIB_ROOT/../modules/bale_actor/lib -c triangle_selector.o triangle_selector.cpp -lhclib -lrt -ldl -lspmat -lconvey -lexstack -llibgetput -lhclib_bale_actor -lm
```
Build a triangle counting executable file:
```
CC -g -O3 -std=c++11 -DUSE_SHMEM=1 -I$HCLIB_ROOT/include -I/$HOME/bale/src/bale_classic/build_ex/include -I$HCLIB_ROOT/../modules/bale_actor/inc -L$HCLIB_ROOT/lib -L/$HOME/bale/src/bale_classic/build_ex/lib -L$HCLIB_ROOT/../modules/bale_actor/lib -o triangle_selector triangle_selector.o -lhclib -lrt -ldl -lspmat -lconvey -lexstack -llibgetput -lhclib_bale_actor -lm
```
!!! tip

    It is a good idea to do `make triangle_selector` first to see the full compilation command. Then, first, copy and paste the full command and change `-o triangle_selector triangle_selector.cpp` to `-c triangle_selector triangle_selector.cpp` to create an object file (.o file). Second, copy and paste the command again and change `-o triangle_selector triangle_selector.cpp` to `-o triangle_selector triangle_selector.o` to create an executable.

### Step 3: Instrument the application using `pat_build`
Generate a CrayPat instrumented executable using `pat_build`:
```
pat_build triangle_selector
```

!!! note

    By default, `triangle_selector+pat` is generated.

!!! note

    `pat_build` has different option that can trace a specific function(s)
     - `-u`: trace all user functions routine by routine
     - `-T -w`: trace function
        - e.g, `pat_build -w -T <FUNCTION>`

### Step 4: Run the instrumented executable to get performance data

#### Option 1: Run the executable with an interactive batch job
Allocating resources:
```
salloc --nodes 1 --qos interactive --time 00:05:00 --constraint cpu --account=mxxx
```
Run the excutable to generate a directory (e.g., `triangle_selector+pat+174621-8716327t`) containing performance data files with the`.xf` suffix:
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
Run `pat_report` with the generated directory name, which will output a text report on the terminal and creates files with different suffices, `.ap2` and `.apa` inside the directory:
```
pat_report ./triangle_selector+pat+174621-8716327t
```

!!! note

    `.ap2` is used to view performance data graphically with the Cray Apprentice2 tool.
    `.apa` is for suggested `pat_build` options for more detailed tracing experiments.

## Using Apprentice2 for analyzing results

Cray Apprentice2 is a GUI-based analysis tool that can be used to visualize performance data instrumented with the CrayPat tool. Cray offers a desktop version of the Cray Apprentice2 visualizer so you can do your analysis locally.

To install a desktop version, you can find the installer on Perlmutter as below:
`$CRAYPAT_ROOT/share/desktop_installers`

`scp` an approparite installer to your local machine and install it. After that, you will be able to open `.ap2` file with Apprentice2.

!!! tips

    If you encounter this error: `/some/path/./a.out: error while loading shared libraries: pat.so: cannot open shared object file: No such file or directory`
    Try this: `export LD_LIBRARY_PATH=$CRAY_LD_LIBRARY_PATH:$LD_LIBRARY_PATH`


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
This will generate a trace of interest in the performance data which can be found in the `pat_report`.

## Collecting hardware performance counters (HWPC)

The Performance Application Programming Interface (PAPI) allows you to programmatically collect hardware performance counters (HWPC) in your code. While the user is supposed to manually insert PAPI routines to specify what HWPCs are measured and when to start/stop measuing them, CrayPat dramatically facilitate that process. Specifically, all the user has to do is to just specify HWPC name(s) in an environment variable. Here are the steps to collect HWPCs with CrayPat:

### Step 1: Find available hardware counters
Available hardware counters can be find by `papi_avail`.

### Step 2: Selecting the hardware counters
Setting the environment variable `PAT_RT_PERFCTR` to specific events/group:

 - Predefined Counter Groups, e.g., `export PAT_RT_PERFCTR=0`.
 - Specify individual events (maximum of 4 event at a time), e.g. `export PAT_RT_PERFCTR="PAPI_L2_DCM,PAPI_L2_ICM"`.

!!! note

    Predefined Counter Groups can be found on slides 38 of [NERSC PerformanceTools](https://www.nersc.gov/assets/Uploads/PerformanceTools.pdf)

### Step 3: Build and run the instrumented excutable with CrayPat
Repeat same with the step in the above Step-by-Step section:

- Generate the instrumented excutable with `pat_build`
- Run the excutable to get performance data
- Generate human-readable content with `pat_report`

## Further Readings

- [NESRC CrayPat documentation](https://docs.nersc.gov/tools/performance/craypat/)
- [NERSC prepared detailed tutorial on Cray's perftools](https://www.nersc.gov/assets/Uploads/05-craypat-reveal-20170609.pdf)
- [Cray XC Series Application Programming and Optimization](https://www.nersc.gov/assets/Uploads/TR-CPO-NERSC-20190211-2.pdf)
- [NERSC PerformanceTools](https://www.nersc.gov/assets/Uploads/PerformanceTools.pdf)
