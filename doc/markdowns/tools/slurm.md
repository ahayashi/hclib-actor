## Useful tips when using srun

### `cpu-bind` and `-c` 
`cpu-bind=<binding option>`

- `sockets` bind to sockets
- `cores`bind to cores
- `threads` bind to threads

When specifying cpu-bind=cores, each PE will be bind to a physical core

`-c <number of logical cores>` option sets the "number of logical cores (CPUs) per task" for the executable, it is optional for jobs that use one task per physical core.

!!! note

	On Perlmutter, each CPU-only compute node contains 2 sockets with a total of 128 physical cores where each core has 2 hardware threads, so there are 256 logical CPUs total. For more details, please refer to [Perlmutter Architecture](https://docs.nersc.gov/systems/perlmutter/architecture/)

### Examples at different scenarios

Here we used [NERSC Prebuilt Binary](https://docs.nersc.gov/jobs/affinity/#use-nersc-prebuilt-binaries) `check-mpi.cray.pm`  to show output at different scenarios

#### scenario  1
Witout specifying both `cpu-bind=cores` and `-c` with 4 PEs:

`srun -n 4 check-mpi.cray.pm`

As a result, each PE will spread across different physical cores.
```
Hello from rank 1, on nid004547. (core affinity = 0-255)
Hello from rank 3, on nid004547. (core affinity = 0-255)
Hello from rank 0, on nid004547. (core affinity = 0-255)
Hello from rank 2, on nid004547. (core affinity = 0-255)
```

#### scenario  2
When specifying `cpu-bind=cores` without setting `-c` with 4 PEs:

`srun -n 4 --cpu-bind=cores check-mpi.cray.pm`

As a result, each PE will be bind to one physical core while each PE may run on different logical core within the same physical core
```
Hello from rank 1, on nid004547. (core affinity = 64,192)
Hello from rank 3, on nid004547. (core affinity = 65,193)
Hello from rank 0, on nid004547. (core affinity = 0,128)
Hello from rank 2, on nid004547. (core affinity = 1,129)
```
!!! note

    On Perlmutter logical core #n and and #n+128 is on the same physical core, e.g. `core affinity = 0,128` means logical core #0 and #128 and they belong to the same physical core #0

#### scenario  3
When specifying `-c 1` without setting `cpu-bind=cores` with 4 PEs:

`srun -n 4 -c 1 check-mpi.cray.pm`
As a result, each PE will run on one logical core, but two different PE may run within one physical core
```
Hello from rank 0, on nid004547. (core affinity = 0)
Hello from rank 1, on nid004547. (core affinity = 128)
Hello from rank 3, on nid004547. (core affinity = 129)
Hello from rank 2, on nid004547. (core affinity = 1)
```
When specifying `-c 2` without setting `cpu-bind=cores` with 4 PEs:

`srun -n 4 -c 2 check-mpi.cray.pm`
As a result, each PE will run on two logical core within one physical core
```
Hello from rank 1, on nid004547. (core affinity = 16,144)
Hello from rank 3, on nid004547. (core affinity = 48,176)
Hello from rank 0, on nid004547. (core affinity = 0,128)
Hello from rank 2, on nid004547. (core affinity = 32,160)
```

#### scenario  4
When setting `cpu-bind=cores` and  `-c 1` with 4 PEs:

`srun -n 4 -c 1 --cpu-bind=cores check-mpi.cray.pm`
As a result, each PE will run on two logical core, but two different PE may run within one physical core
```
Hello from rank 0, on nid004547. (core affinity = 0,128)
Hello from rank 1, on nid004547. (core affinity = 1,129)
Hello from rank 3, on nid004547. (core affinity = 1,129)
Hello from rank 2, on nid004547. (core affinity = 0,128)
```

When setting `cpu-bind=cores` and  `-c 2` option:

`srun -n 4 -c 2 --cpu-bind=cores check-mpi.cray.pm`
Same with [scenario  2](https://hclib-actor.com/tools/slurm/#scenario-2), each PE will be bind to one physical core while each PE may run on different logical core within the same physical core
```
Hello from rank 1, on nid004547. (core affinity = 16,144)
Hello from rank 0, on nid004547. (core affinity = 0,128)
Hello from rank 3, on nid004547. (core affinity = 48,176)
Hello from rank 2, on nid004547. (core affinity = 32,160)
```

To make sure our goal here is to make sure **each PE bind to one physical core** and **each socket has an equal number of PEs**, we should make sure that we set 
`cpu-bind=cores` and **optionally set `-c 2`**
