##Useful tips when using Srun

### `cpu-bind` and `-c` 
`cpu-bind=<binding option>`
- `sockets` bind to sockets
- `cores`bind to cores
- `threads` bind to threads

When specifying cpu-bind=cores, each PE will be bind to a physical core

`-c` option sets the "number of logical cores (CPUs) per task" for the executable, it is optional for jobs that use one task per physical core.

!!! note
On Perlmutter, each CPU-only compute node has a total of 128 physical cores with 2 hardware threads, so there are 256 logical CPUs total

### scenario  1
Witout specifying both `cpu-bind=cores` and `-c` option
`srun -n 2 check-mpi.cray.pm`
As a result, each PE will be spread across different physical cores.

### scenario  2
When specifying `cpu-bind=cores` without setting `-c` option
`srun -n 2 --cpu-bind=cores check-mpi.cray.pm`
As a result, each PE will be bind to one physical core. But it may run on different logical core within the physical core

### scenario  3
When specifying `-c 1` without setting `cpu-bind=cores`
`srun -n 2 -c 1 check-mpi.cray.pm`
As a result, each PE will run on one logical core, but may/may not run on one physical core

### scenario  4
When setting `cpu-bind=cores` and  `-c 1` option
`srun -n 2 check-mpi.cray.pm`
As a result, each PE will run on one logical core, but different PE may result in using same physical core

To make sure our goal in most scenario of **each PE bind to one physical core**, we should set 
`cpu-bind=cores` and optionally set `-c 2`