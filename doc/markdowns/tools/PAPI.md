## Introduction

The Performance Application Programming Interface (PAPI) supplies a consistent interface and methodology for collecting performance counter information from various hardware and software components, including most major CPUs, GPUs, accelerators, interconnects, I/O systems, and power interfaces, as well as virtual cloud environments.

  In this section, we will give a brief intro on how to do PAPI analysis using CrayPat API

## PAPI Analysis with CrayPat API
CrayPat performance API can be use to identify the region of interest for PAPI analysis.

Here we will again take Triangle Counting selector for example

### Step 1: Load CrayPat necessary module
```
module unload darshan
module load perftools-base perftools
```

### step 2: Inserting CrayPat region API
Inserting  `PAT_region_begin(int id, char *label)` before the region of interest and  `PAT_region_end(int id)` after the region of interest
```
#include <pat_api.h>
...
PAT_record(PAT_STATE_ON);
PAT_region_begin(1,"selector_function");
triangle_selector();
PAT_region_end(1);
...
```

### step 3: Find available hardware counters 
Available hardware counters can be find by `papi_avail`

### step 4: Selecting the hardware counters that you want to collect.
Setting environment variable `PAT_RT_PERFCTR` to specific event/group
 - Predefined Counter Groups, e.g. `export PAT_RT_PERFCTR=0`
 - specify individual events (maximum of 4 event at a time), e.g. `export PAT_RT_PERFCTR="PAPI_L2_DCM,PAPI_L2_ICM"`
 
### step 5: Build and run the instrumented excutable with CrayPat
Same with the step in the CrayPat section, we need to 
- Generate the instrumented excutable with `pat_build` 
- Run the excutable to get performance data
- Generate human-readable content with `pat_report`

### Example sbatch script

Run with `triangle_selector+pat` instrumented excutable
```
#!/bin/bash
#SBATCH -q regular
#SBATCH -N 2
#SBATCH -C cpu
#SBATCH -t 0:05:00
#SBATCH -ooshmem_%j_tri_cout.out    

source ./oshmem-perlmutter.sh

module unload darshan
module load perftools-base perftools
export LD_LIBRARY_PATH=$CRAY_LD_LIBRARY_PATH:$LD_LIBRARY_PATH

cd ./hclib/modules/bale_actor/test
export PAT_RT_PERFCTR="PAPI_L2_DCM,PAPI_L2_ICM"

echo "--------------------------------------------"
srun  -n 128 --cpu-bind=cores ./triangle_selector+pat
echo "--------------------------------------------"
```

## Further Readings
[Cray XC Series Application Programming and Optimization](https://www.nersc.gov/assets/Uploads/TR-CPO-NERSC-20190211-2.pdf) 
[NERSC PerformanceTools](https://www.nersc.gov/assets/Uploads/PerformanceTools.pdf)