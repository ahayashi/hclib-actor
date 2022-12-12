## `spmat` library

`spmat` library helps the user to construct and manipulate distributed sparse matrices. It uses a distributed version of [the CSR format](https://en.wikipedia.org/wiki/Sparse_matrix), in which the rows are distributed across all the PEs in a cyclic way.

Suppose we have the following 4x4 matrix:

```
1 0 1 0
0 1 0 1
1 0 1 0
0 0 1 1
```

If there are 2PEs, since `spmat` does a cyclic distribution, PE0 owns ROW0 and ROW2, PE1 owns ROW1 and ROW3. Note that the ROW numbers are global and it is convenient to use a local ROW number to access a local portion of the array on each PE. Specifically, a local row number can be computed by doing `GLOBAL_ROW / nPEs`. Also, the owner of a global row can be identified by computing `GLOBAL_ROW % nPEs`.

```
// 2PEs
GLOBAL ROW 0, PE0's ROW0: 1 0 1 0
GLOBAL ROW 1, PE1's ROW0: 0 1 0 1
GLOBAL ROW 2, PE0's ROW1: 1 0 1 0
GLOBAL ROW 3, PE1's ROW1: 0 0 1 1
```

A typical idiom for iterating over non-zeros in a specific local row `i` of a sparse matrix `A` is as follows:

``` c++
for (int64_t j = A->loffset[i]; j < A->loffset[i+1]; j++) {
  // visit each non-zero
  int64_t nonzero = A->lnonzero[j];
}
```

Also, a typical idiom for iterating over remote non-zeros in a global row is as follows:

=== "OpenSHMEM"

    ``` c++
    int64_t global_row = 1;
    int64_t pe = global_row % shmem_n_pes(); // find the owner of "global_row"
    int64_t i = global_row / shmem_n_pes();  // compute the local row number
    int64_t start = shmem_int64_g(&A->loffset[i], pe);
    int64_t end = shmem_int64_g(&A->loffset[i+1], pe);
    for(int j = start; j < end; j++) {
      int64_t nonzero = shmem_int64_g(&A->lnonzero[j], pe);
    }
    ```
    
=== "libgetput"

    ``` c++
    int64_t global_row = 1;
    int64_t start = lgp_get_int64(A->offset, global_row);
    int64_t end = lgp_get_int64(A->offset, global_row+THREADS);
    for(int j = start; j < end; j++){
      int64_t nonzero = lgp_get_int64(A->nonzero, j*THREADS + global_row%THREADS);
    }
    ```

It is worth noting that, unlike the typical CSR format, `nonzero` stores a global column number (0, 1, 2, 3 in our example, see below), which reduces memory size (c.f. the CSR format uses three arrays). For algorithms in which actual values need to be stored, bale3's  `spmat` allows the user to use `A->value[j]`. The type of `value[]` is double.

```
1 0 1 0  our representation  0 - 2 -
0 1 0 1  ----------------->  - 1 - 3
1 0 1 0  ----------------->  0 - 2 -
0 0 1 1                      - - 2 3
```

Now let us use a working example that reads the following [matrix market format](https://math.nist.gov/MatrixMarket/formats.html) file, which is equivalent to the matrix above, load it into a `sparsemat_t` object, and finally prints the contents of it on each PE:

``` title="test.mtx"
%%MatrixMarket matrix coordinate pattern
4 4 8
1 1
1 3
2 2
2 4
3 1
3 3
4 3
4 4
```

Here is a OpenSHMEM/libget program that iterates over non-zeros on each PE and print it. Notice that the code uses all-to-all barrier (`shmem_barrier_all()` or `lgp_barrier()`) so PE0 first prints the contents, then PE1 does the printing:

=== "OpenSHMEM"

    ``` c++ linenums="1"
    #include <shmem.h>
    extern "C" {
      #include "spmat.h"
    }

    // SPMD
    int main(int argc, char * argv[]) {
      shmem_init();
    
      sparsemat_t *A;
      A = read_matrix_mm_to_dist("./test.mtx");
    
      for (int pe = 0; pe < shmem_n_pes(); pe++) {
          if (pe != shmem_my_pe()) continue;
          for (int64_t i = 0; i < A->lnumrows; i++) {
              for(int64_t j = A->loffset[i]; j < A->loffset[i+1]; j++) {
                  printf("[PE%d] localrow:%d, lnonzero[%d]: %ld\n", pe, i, j, A->lnonzero[j]);
              }
          }
          shmem_barrier_all();
      }
      shmem_barrier_all();
      // PE0 gets global row 1
      if (shmem_my_pe() == 0) {
          int64_t global_row = 1;
          int64_t pe = global_row % shmem_n_pes(); // find the owner of "global_row"
          int64_t i = global_row / shmem_n_pes();  // compute the local row number
          int64_t rowstart = shmem_int64_g(&A->loffset[i], pe);
          int64_t rowstart_next = shmem_int64_g(&A->loffset[i+1], pe);
          for(int j = rowstart; j < rowstart_next; j++) {
              printf("[PE0] non-zero at column %ld in PE%ld's local row %ld\n", shmem_int64_g(&A->lnonzero[j], pe), pe, i);
          }
      }
      shmem_barrier_all();
      shmem_finalize();

      return 0;
    }
    ```

=== "libgetput"

    ``` c++ linenums="1"
    #include <shmem.h>
    extern "C" {
      #include "spmat.h"
    }

    int main(int argc, char * argv[]) {
      lgp_init(argc, argv);

      sparsemat_t *A;
      A = read_matrix_mm_to_dist("./test.mtx");

      // iterating over local rows
      for (int pe = 0; pe < THREADS; pe++) {
          if (pe != MYTHREAD) continue;
          for (int i = 0; i < A->lnumrows; i++) {
              for(int j = A->loffset[i]; j < A->loffset[i+1]; j++) {
                  printf("[PE%d] localrow:%d, lnonzero[%d]: %ld\n", pe, i, j, A->lnonzero[j]);
              }
          }
          lgp_barrier();
      }
      lgp_barrier();

      // PE0 gets global row 1
      if (MYTHREAD == 0) {
          int64_t global_row = 1;
          int64_t pe = global_row % THREADS;
          int64_t i = global_row / shmem_n_pes();
          int64_t start = lgp_get_int64(A->offset, global_row);
          int64_t end = lgp_get_int64(A->offset, global_row+THREADS);
          for(int j = start; j < end; j++){
              printf("[PE0] non-zero at column %ld in PE%ld's local row %ld\n", lgp_get_int64(A->nonzero, j*THREADS + pe), pe, i);
          }
      }
      lgp_barrier();
      lgp_finalize();

      return 0;
    }
    ```

Example output on 2PEs:

```
[PE0] localrow:0, lnonzero[0]: 0
[PE0] localrow:0, lnonzero[1]: 2
[PE0] localrow:1, lnonzero[2]: 0
[PE0] localrow:1, lnonzero[3]: 2
[PE1] localrow:0, lnonzero[0]: 1
[PE1] localrow:0, lnonzero[1]: 3
[PE1] localrow:1, lnonzero[2]: 2
[PE1] localrow:1, lnonzero[3]: 3
[PE0] non-zero at column 1 in PE1's local row 0
[PE0] non-zero at column 3 in PE1's local row 0
```

You can also use `print_matrix(A)` from `spmat` library:

```
row 0: 0 2
row 1: 1 3
row 2: 0 2
row 3: 2 3
```

## Further Readings

- README.md for spmat <https://github.com/jdevinney/bale/blob/master/src/bale_classic/spmat/README.md>

