## What is OpenSHMEM?
OpenSHMEM is a library-based PGAS programming model. OpenSHMEM is originally from SHMEM, which was firstly introduced by Cray back in 90s, and includes a specification for standarized SHMEM library routines. 

One of the interesting features of OpenSHMEM is *symmetric variables*. In an OpenSHMEM program, global variables and dynamically allocated variables (by `shmem_malloc`) exist with the same size, type, and relative address on all PEs, and can be directly fed into one-sided communication routines such as put/get, which significantly improves the programmability.

The following is a working example that 1) allocates a symmetric integer variable on each PE, 2) put the value to the next PE, and 3) prints the value on each PE. Note that, like MPI, an OpenSHMEM program is written in an SPMD manner.

``` c title="test.c" linenums="1"
#include <shmem.h>
#include <stdio.h>
// the main function is executed by multiple PEs
int main(void) {
  shmem_init();
  int npes = shmem_n_pes(); // get the number of the PEs
  int mype = shmem_my_pe(); // get my PE ID
  // dynamic symmetric variable allocation
  int* x = (int*)shmem_malloc(sizeof(int)); 
  // superstep
  {
    int val = mype; // local computation
    // communication (put to next PE in a circular way)
    shmem_p(x, val, (mype+1) % npes);
    // barrier
    shmem_barrier_all();
  }
  printf("x is %d on PE%d (out of %d PEs)\n", *x, mype, npes);
  shmem_free(x);
  shmem_finalize();
}
```

An example output with 2PEs is as follows:
```
oshcc test.c -o test
oshrun -n 2 ./test
x is 1 on PE0 (out of 2 PEs)
x is 0 on PE1 (out of 2 PEs)
```


## Further Readings
- Swaroop Pophale and Tony Curtis, 2011. OpenSHMEM tutorial. <http://www.openshmem.org/site/sites/default/site_files/OpenSHMEM_PGAS11_tutorial.pdf>
- OpenSHMEM Specification. <http://www.openshmem.org/site/specification>
- Barbara Chapman, Tony Curtis, Swaroop Pophale, Stephen Poole, Jeff Kuehn, Chuck Koelbel, and Lauren Smith. 2010. Introducing OpenSHMEM: SHMEM for the PGAS community. In Proceedings of the Fourth Conference on Partitioned Global Address Space Programming Model (PGAS '10). Association for Computing Machinery, New York, NY, USA, Article 2, 1–3. <https://doi.org/10.1145/2020373.2020375>
