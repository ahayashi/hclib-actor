## What is Bale?

Bale provides a library-based distributed programming model with a special focus on optimizing fine-grained communications. 

`hclib-actor` mainly depends on the following libraries from Bale:

- `libgetput`: a library that enables one-sided communications, remote atomics, and colletives built on top of UPC/OpenSHMEM
- `spmat`: a library that facilitates the construction/manipulation of distributed sparse matrices, which is built on top of `libgetput`
- `conveyors`: a communication aggregation library, built on top of `libgetput`
- `exstack/exstack2`: a preliminary experimental version of `conveyors`.  

For more details, please see the github repo for Bale can be found [here](https://github.com/jdevinney/bale).

## How Bale is used in `hclib-actor`?

The key motivation for introducing `hclib-actor` is to simplify programming with `conveyors` while keeping the same performance. Specifically, note that `conveyors` requires ninja-level distributed programming skills as illustrated in [this Histogram with conveyors example](https://github.com/jdevinney/bale/blob/master/src/bale_classic/apps/histo_src/histo_conveyor.upc) and providing a higher-level programming model would benefit non-ninja programmers such as domain experts and scientists.

`hclib-actor` is mainly designed to provide an actor based distributed programming model and completely abstracts away `conveyors`. Additionally, many of kernels and benchmarks in `hclib-actor` use routines from `spmat` and `libgetput` libraries. 

For more details, please see the followings:

* [spmat](spmat.md)
* [libgetput](libgetput.md)

!!! note
   
    It is worth noting that `hclib-actor` does not necessarily depend on `spmat` or `libgetput` libraries. For example, for PGAS SPMD execution, bare OpenSHMEM and UPC can be used instead of `libgetput`. 

## Further Readings

- Jason DeVinney and John Gilbert. 2022. Bale: Kernels for irregular parallel computation (Not a benchmark) <https://github.com/jdevinney/bale/blob/master/docs/Bale-StGirons-Final.pdf>
- F. Miller Maley and Jason G. DeVinney. 2019. Conveyors for Many-to-Many Streaming Communication <https://github.com/jdevinney/bale/blob/master/docs/uconvey.pdf>
