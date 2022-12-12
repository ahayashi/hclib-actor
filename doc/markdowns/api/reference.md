## `hclib`'s Actor

| API                  | Freq    | Note |
| :-                   | :-      |:-   |
| `launch()`           | COMMON |  |
| `finish()`             | COMMON  |    |
| `send()`              | COMMON  |    |
| `done()`               | COMMON  |    |
| `yield()`              | OCCASIONAL  |    |


## `libgetput`

| API                  | Freq    | Note |
| :-                   | :-      |:-   |
| `lgp_barrier()`      | COMMON  | All-to-all barrier   |
| `lgp_all_alloc()`    | COMMON  | Same as `upc_all_alloc(N)`, which distributes N elements across nPEs, whereas `shmem_malloc(N)` allocates N elements per PE. This must be very confusing to OpenSHMEM programmers |
| `lgp_all_free()`     |  COMMON |     |
| `lgp_local_part()`   |  COMMON | Returns `(p+MYTHREAD)` (= the pointer to the first element of a UPC array `p` on `MYTHREAD`). This is more for keeping the compatibility with UPC. SHMEM backend does nothing.  |
| `lgp_atomic_add()`   | RARE   | histo  |
| `lgp_fetch_and_inc()`| RARE   | toposort_agi, transpose_agi, triangle_conveyor, triangle_selector (for data preparation?)|
| `lgp_fetch_and_add()`| RARE   | toposort_agi, transpose_agi |
| `lgp_cmp_and_swap`   | RARE   | randperm_agi     |
| `lgp_reduce_add_l()` | COMMON | Mostly used for 1) validating the output, and 2) accumulating per PE metrics (e.g., # of pulls/pushes)  |
| `lgp_reduce_max_l()` | RARE | Only used in toposort, but the selector version uses this in the kernel.    |
| `lgp_min_avg_max_d()`| COMMON | `libgetput`'s original collective that internally does `lgp_reduce_min_l`, `lgp_reduce_max_l`, and `lgp_reduce_add_l`. Mainly used to get the average of each PE's execution time. |
| `lgp_prior_add_l()`  | RARE | `libgetput`'s original collective that does ... randperm_agi,conveyor,selector toposort_conveyor,selector |
| `lgp_init()`         | COMMON | `shmem_init()` Used only in the AGI/Conveyors versions.  |
| `lgp_finalize()`     | COMMON |`shmem_finalize()` Used only in the AGI/Conveyors versions. |
| `lgp_global_exit()`  | OCCASIONAL| `shmem_global_exit()` Called when an error happens |
| `lgp_put_int64()` `lgp_get_int64()` | `libgetput` |     |

## `spmat`

| API                  | Freq    | Note |
| :-                   | :-      |:-   |
| `gen_erdos_renyi_graph_dist()` | COMMON  | `bale_old`  |
| `generate_kronecker_graph()`   | COMMON  | `bale_old`  |
| `read_matrix_mm_to_dist()`     |         |   |
| `is_lower_triangular` |        |         |   |

## `hclib`'s Actor

| API                  | Freq    | Note |
| :-                   | :-      |:-   |
| `launch()`           | COMMON |  |
| `finish()`             | COMMON  |    |
| `send()`              | COMMON  |    |
| `done()`               | COMMON  |    |
| `yield()`              | OCCASIONAL  |    |


!!! todo

    Add 1) a high-level summary of the user-facing routines and 2) javadoc/doxygen like API reference pages for each routine.
