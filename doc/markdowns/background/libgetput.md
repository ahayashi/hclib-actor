## `libgetput` library

`libgetput` helps the user to write PGAS SPMD programs by offering different types of communication routines such as one-sided PUT/GET, remote atomics, barriers, and collectives. The library has two backends (UPC and OpenSHMEM) and the user can chose a backend when building bale.

Many of `libgetput` routines are influenced by UPC. For example, `THREADS` refers to the number of PEs (= `shmem_n_pes()`) and `MYTHREAD` refers to the current PE number (= `shmem_my_pe()`). Also, `lgp_all_alloc(N, sizeof(T))` distributes N elements across all the PEs in a cyclic way, which is the same as `upc_all_alloc(N, sizeof(T))`. This would require SHMEM programmers to carefully use the routine because `shmem_malloc(N*sizeof(T))` allocates N elements per PE. A list of `libgetput` routines can be found [here](https://github.gatech.edu/pages/Habanero/hclib-actor/api/reference/).


## Further Readings

- README.md for libgetput <https://github.com/jdevinney/bale/blob/master/src/bale_classic/libgetput/README.md>
