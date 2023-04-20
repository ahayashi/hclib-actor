
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
!!!notes
`pat_build` has different option that can trace specific function as user defined
	- `-u`: trace all user functions routine by routine
	- `-T -w`: trace function
		- eg. `pat_build –w –T <FUNCTION>`
  
### Step 4: Run the instrumented executable to get a performance data

Allocating resources to run an interactive batch job on a single node
```
salloc --nodes 1 --qos interactive --time 00:05:00 --constraint cpu --account=mxxx
```
Run the instrumented triangle counting excutable, it will generate a directory (e.g. `triangle_selector+pat+174621-8716327t`) containing performance data files with the`.xf` suffix. 
```
srun  -n 128 --cpu-bind=cores ./triangle_selector+pat
```

### Step 5: Generate human-readable content with `pat_report`
Run pat_report on the generated directory name, it will output atext report in the terminal and creates files with different suffices, `.ap2` and `.apa` inside the directory
`pat_report ./triangle_selector+pat+174621-8716327t`
!!!notes
`.ap2` is used to view performance data graphically with the Cray Apprentice2 tool
`.apa` is for suggested `pat_build` options for more detailed tracing experiments.

## Using Apprenyice2 for analyzing results

Cray Apprentice2 is a graphical analysis tool used to further explore visualize performance data instrumented with the CrayPat tool

For installing local Cray Apprentice2 visualizer, you can find the installer in Perlmutter as below
`$CRAYPAT_ROOT/share/desktop_installers`

After installing Apprentice2 visualizer, the open the corresponding generated folder can see the visual analyzing results.	

!!!notes
`/some/path/./a.out: error while loading shared libraries: pat.so: cannot open shared object file: No such file or directory`
Solution:
`export LD_LIBRARY_PATH=$CRAY_LD_LIBRARY_PATH:$LD_LIBRARY_PATH`


## Further Readings

- [NESRC CrayPat documentation](https://docs.nersc.gov/tools/performance/craypat/)
- [NERSC prepared detailed tutorial on Cray's perftools](https://www.nersc.gov/assets/Uploads/05-craypat-reveal-20170609.pdf)